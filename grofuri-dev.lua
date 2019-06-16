-- Dev entry point of GrofuriBot
-- Discordia variables
local discordia = require('discordia')
local client = discordia.Client({cacheAllMembers = true})
local clock = discordia.Clock()

-- Tools & conf
require('tools/split')
local log = require('tools/log')
local challenge = require('challenge')
local conf = require('conf')
local trigger = "dev%"
local commands = {}

-- Register command using its name and code
local function registerCommand(aliases, callback)
    local name = aliases[1]

    commands[name] = function(msg, args) callback(msg, args) end
    log:print("Command '" .. name .. "' registered")

    for i = 2, #aliases do
        commands[aliases[i]] = commands[name]
        log:print("Alias '" .. aliases[i] .. "' of command '" .. name .. "' registered")
    end
end

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

-- Cleaned env for command files
local subenv = {}
subenv.require = require -- Luvit require != lua require
subenv.registerCommand = registerCommand
subenv.log = log
subenv.conf = conf

client:once('ready', function()
    -- List all files in /commands
    local files = io.popen("ls commands","r")

    -- Process each file and store function in commands using pcall
    for file in files:lines() do
        local f, err = pcall(loadfile("commands/" .. file, "t", subenv))

        if err then log:print("Error in pcall while parsing command files : " .. err, 3) end
    end

    log:print("Logged in as ".. client.user.username)
    log:print("Starting time events")
    clock:start()
end)

client:on('messageCreate', function(msg)    
    if string.sub(msg.content, 0, #trigger) == trigger then
        local sep = string.find(msg.content, " ")
        if sep then sep = sep - 1 end
        local command = string.sub(msg.content, #trigger + 1, sep)
        local args = string.sub(msg.content, #trigger + #command + 2):split(" ", true) -- true preserves quotes

        -- Execute the command if it exists
        if commands[command] then
            log:print(msg.author.tag .. " called function " .. command)
            commands[command](msg, args)
        else
            log:print(msg.author.tag .. " : command " .. command .. " does not exist", 2)
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
            local type = pending.options:getValue("--type") or "lose"

            log:print("Reaction \"" .. reaction.emojiHash .. "\" added by " ..
                guild:getMember(userId).name .. " on message with title \"" .. title .. "\"")

            local agree = message.reactions:find(function(r) if r.emojiHash == "✅" then return r end end)
            local disagree = message.reactions:find(function(r) if r.emojiHash == "❌" then return r end end)
            local nplayers = guild.members:count(function(m) if m:hasRole(_G.roles.player) then return m end end)

            -- Add challenge to the JSON if more than 50% of players agree
            if agree and agree.count > math.floor(nplayers / 2) + 1 then
                if not _G.challenge:parse(_G.conf.challengesFile) then return end
                local challId = #_G.challenge.all.standard + 1

                table.insert(_G.challenge.all.standard,
                    { 
                        id = challId,
                        title = title,
                        description = description,
                        type = type,
                        authorId = pending.authorId
                    }
                )

                _G.challenge:update(_G.conf.challengesFile)
                validate(true, pos, message, title, description, challId)
            elseif disagree and disagree.count > math.floor(nplayers / 2) + 1 then
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
            log:print("Reaction \"" .. reaction.emojiHash .. "\" removed by " .. user.name .. " on message with title \"" .. pending.options:getValue("--title") .. "\"")
        end
    end
end)

clock:on('hour', function()
    local now = os.date("*t")

    -- Delivers new challenge everyday at midnight
    if (now.hour - 2 == 0) and commands["start"] then
        local file = io.open(_G.conf.playersFile, "a+")
        local data = json.decode(file:read("*a"))
        local current = _G.challenge:getCurrent()
        local state = current.type == "lose" and true or false

        -- Empty player file (should not happend)
        if not data or not data.players then
            log:print("No players available (empty file)", 3)
            return
        end

        for _, playerData in ipairs(data.players) do
            local player = history.searchPlayerById(data.players, playerData.id)

            -- Goes 1 hour back to add the win or lose to history for yesterday's challenge
            history.addToHistory(player, os.date(history.dateFormat, os.time() - 60 * 60), state, current.id)
        end

        io.open(_G.conf.playersFile, "w"):close() -- Flush file content
        file:write(json.encode(data)) -- Rewrite using previous and new data
        file:close()

        commands["start"](client)
    else
        log:print("H-" .. 25 - (now.hour + 1) .. " before starting a new challenge")
    end
end)


-- TOOLS FOR PROPER EVENT HANDLING

-- Security measure to not let the token hard coded
function getBotToken(filename)
    local file = io.open(filename)

    if not file then
        log:print("Cannot open file " .. filename)
        return ""
    end

    local token = file:read()

    file:close()

	return token
end

client:run('Bot ' .. getBotToken("token.txt"))