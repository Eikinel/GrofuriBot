-- Add discordia and various variables to the global scope
_G.discordia = require('discordia')
_G.log = require('tools/log')
_G.split = require('tools/split')
_G.embed = require('tools/embed')
_G.json = require('json')
_G.challenge = require('select_challenge')
_G.commands = {}
_G.colorChart = {
    default = 0xF02E89
}
_G.roles = {
    admin = "563731669912387625",
    bot = "563710698979459072",
    grofuri = "563739629795409961",
    player = "563739379529547817"
}
_G.channels = {
    challenge = "563709792150093843"
}

-- Internal variables
local client = discordia.Client({cacheAllMembers = true})
local clock = discordia.Clock()
local trigger = "%"
local guildId = "563708262369984522"

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

    _G.log:print('Logged in as '.. client.user.username .. " sur le serveur " .. client:getGuild(guildId).name)
    _G.log:print('Starting time events')
    clock:start()
end)

client:on('messageCreate', function(msg)    
    if string.sub(msg.content, 0, #trigger) == trigger then
        local sep = string.find(msg.content, " ")
        if sep then sep = sep - 1 end
        local command = string.sub(msg.content, #trigger + 1, sep)
        local args = string.sub(msg.content, #trigger + #command + 2):split(" ")

        -- Execute the command if it exists
        if _G.commands[command] then
            _G.commands[command](msg, args)
            _G.log:print(msg.author.tag .. " called function " .. command)
        else
            _G.log:print(msg.author.tag .. " : command " .. command .. " does not exist", 2)
		end
    end
end)

clock:on('hour', function()
    local now = os.date("*t")
    local challengeFile = "challenges.json"

    -- Delivers new challenge everyday at midnight
    if (now.hour == 0) then
        local guild = client:getGuild(guildId)

        if not guild then
            _G.log:print("No guild matching requirements with id " .. guildId .. " found.", 3)
            return
        end

        local channel = guild:getChannel(_G.channels.challenge)
        
        if not channel then
            _G.log:print("Cannot send challenge : channel not found", 3)
            return
        end

        -- Parse the appropriate JSON and select a challenge
        _G.log:print("Selecting new challenge")
        if not challenge:parse(challengeFile) then return end
        if not challenge:selectChallenge(os.time()) then
            channel:send("Oops, je n'ai plus de challenge à vous proposez ! Donnez-moi de quoi vous challenger !")
            return
        end

        challenge:update(challengeFile)
        _G.log:print("Updated file " .. challengeFile)

        -- Construct new message to send to the guild
        local current = challenge:getCurrent()
        local author = client:getUser(current.authorId)
        local membed = embed.new()

        membed:setColor(_G.colorChart.default)
        membed:setAuthor("Nouveau challenge !", "", client.user:getAvatarURL())
        membed:setThumbnail(author and author:getAvatarURL() or nil)
        membed:setDescription("La challenge du jour est...")
        membed:addField(
            "Si tu __**" .. current.title .. "**__ aujourd'hui, tu es *furry* !",
            current.description)
        membed:addField(
            "Si vous avez perdu, pensez à utiliser la commande `%gperdu` pour enregistrer votre score de grofuri",
            [[\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_]])
        membed:setFooter("Proposé par " .. (author and author.tag or "Unknown"))
        membed:setTimestamp(os.date("!%Y-%m-%dT%TZ"))

        channel:send({embed = membed})
        _G.log:print("Challenge n°" .. current.id .. " sent to the guild \"" .. guild.name .. "\"")
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