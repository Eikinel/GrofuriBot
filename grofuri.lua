-- Add discordia and various variables to the global scope
_G.discordia = require('discordia')
_G.log = require('tools/log')
_G.json = require('json')
_G.challenge = require('challenge')
_G.commands = {}
_G.colorChart = {
    default = 0xF02E89
}
_G.roles = {
    admin = "563731669912387625",
    bot = "563710698979459072",
    grofuri = "563739629795409961",
    player = "563739379529547817",
    gropd = "581023529231712256"
}
_G.channels = {
    challenge = "563852208932651010",
    bot = "564029644257361920",
    suggestions = "573868679519797269",
    test_bot = "563713704282030081"
}
_G.guildId = "563708262369984522"
_G.conf = {
    playersFile = "players.json",
    challengesFile = "challenges.json",
    gotchaFile = "gotcha.json"
}

-- Internal variables
require('tools/split')
local client = discordia.Client({cacheAllMembers = true})
local clock = discordia.Clock()
local history = require('tools/history')
local trigger = "%"

-- Internal function for suggestion validation
local function validate(bool, pos, message, title, description, challId)
    if bool then
        _G.log:print("Added challenge n°" .. challId .. " with title \"" .. title .. "\" and description \"" .. description .. "\"")
        message:setContent("**Le challenge n°" .. challId .. " \"Si tu " .. title .. " aujourd'hui\" a été validé !**")
    else
        _G.log:print("Challenge with title \"" .. title .. "\" and description \"" .. description .. "\" has been rejected")
        message:setContent("*Le challenge \"Si tu " .. title .. " aujourd'hui\" a été rejeté.*")
    end
    message:setEmbed()
    message:clearReactions()
    message:unpin()
    table.remove(_G.challenge:getPending(), pos)
end

client:once('ready', function()
    -- List all files in /commands
    local files = io.popen("ls commands","r")

    -- Process each file and store function in _G.commands using pcall
    for file in files:lines() do
        local f, err = loadfile("commands/" .. file)

        if not f then
            _G.log:print("Error while loading command file : " .. err, 3)
        else
            local func, err = pcall(f)

            if not func then
                _G.log:print("Error in pcall while parsing command files : " .. err, 3)
            end
        end
    end

    _G.log:print('Logged in as '.. client.user.username .. " on server " .. client:getGuild(guildId).name)
    _G.log:print('Starting time events')
    clock:start()
end)

client:on('messageCreate', function(msg)    
    if string.sub(msg.content, 0, #trigger) == trigger and
    (msg.channel.id == _G.channels.bot or
    msg.channel.id == _G.channels.test_bot or
    msg.channel.id == _G.channels.suggestions) then
        local sep = string.find(msg.content, " ")
        if sep then sep = sep - 1 end
        local command = string.sub(msg.content, #trigger + 1, sep)
        local args = string.sub(msg.content, #trigger + #command + 2):split(" ", true) -- true preserves quotes

        -- Execute the command if it exists
        if _G.commands[command] then
            _G.log:print(msg.author.tag .. " called function " .. command)
            _G.commands[command](msg, args)
        else
            _G.log:print(msg.author.tag .. " : command " .. command .. " does not exist", 2)
		end
    end
end)

client:on('reactionAdd', function(reaction, userId)
    local message = reaction.message
    local guild = message.guild
    local user = guild:getMember(userId)

    -- Pending carries both message information and options
    for pos, pending in ipairs(_G.challenge:getPending()) do
        if message.id == pending.message.id then
            local title = pending.options:getValue("--title")
            local description = pending.options:getValue("--description")

            _G.log:print("Reaction \"" .. reaction.emojiHash .. "\" added by " ..
                guild:getMember(userId).name .. " on message with title \"" .. title .. "\"")

            local agree = message.reactions:find(function(r) if r.emojiHash == "✅" then return r end end)
            local disagree = message.reactions:find(function(r) if r.emojiHash == "❌" then return r end end)
            local nplayers = guild.members:count(function(m) if m:hasRole(_G.roles.player) then return m end end)

            -- Add challenge to the JSON if more than 50% of players agree
            if agree and agree.count > 1 then--math.floor(nplayers / 2) + 1 then
                if not _G.challenge:parse(_G.conf.challengesFile) then return end
                local challId = #_G.challenge.all.standard + 1

                table.insert(_G.challenge.all.standard,
                    { 
                        title = title,
                        description = description,
                        id = challId,
                        authorId = pending.authorId
                    }
                )

                _G.challenge:update(_G.conf.challengesFile)
                validate(true, pos, message, title, description, challId)
            elseif disagree and disagree.count > 1 then--math.floor(nplayers / 2) + 1 then
                validate(false, pos, message, title, description)
            end

            break
        end
    end
end)

client:on('reactionRemove', function(reaction, userId)
    local message = reaction.message
    local user = message.guild:getMember(userId)

    -- Pending carries both message information and options
    for _, pending in ipairs(_G.challenge:getPending()) do
        if message.id == pending.message.id then
            _G.log:print("Reaction \"" .. reaction.emojiHash .. "\" removed by " .. user.name .. " on message with title \"" .. pending.options:getValue("--title") .. "\"")
        end
    end
end)

clock:on('hour', function()
    local now = os.date("*t")

    -- Delivers new challenge everyday at midnight
    if (now.hour == 0) and _G.commands["start"] then
        local file = io.open(_G.conf.playersFile, "a+")
        local data = json.decode(file:read("*a"))

        -- Empty player file (should not happend)
        if not data or not data.players then
            _G.log:print("No players available (empty file)", 3)
            return
        end

        for _, playerData in ipairs(data.players) do
            local player = history.searchPlayerById(data.players, playerData.id)

            -- Goes 1 hour back to add the win to history for yesterday's challenge
            history.addToHistory(player, os.date(history.dateFormat, os.time() - 60 * 60), true, _G.challenge:getCurrent().id)
        end

        io.open(_G.conf.playersFile, "w"):close() -- Flush file content
        file:write(json.encode(data)) -- Rewrite using previous and new data
        file:close()

        _G.commands["start"](client)
    else
        _G.log:print("H-" .. 25 - (now.hour + 1) .. " before starting a new challenge")
    end
end)


-- TOOLS FOR PROPER EVENT HANDLING

-- Security measure to not let the token hard coded
function getBotToken(filename)
    local file = io.open(filename)

    if not file then
        _G.log:print("Cannot open file " .. filename)
        return ""
    end

    local token = file:read()

    file:close()

	return token
end

-- Register command using its name and code
function _G.registerCommand(aliases, callback)
    local name = aliases[1]

    _G.commands[name] = function(msg, args) callback(msg, args) end
    _G.log:print("Command '" .. name .. "' registered")

    for i = 2, #aliases do
        _G.commands[aliases[i]] = _G.commands[name]
        _G.log:print("Alias '" .. aliases[i] .. "' of command '" .. name .. "' registered")
    end
end

client:run('Bot ' .. getBotToken("token.txt"))