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
    player = "563739379529547817"
}
_G.channels = {
    challenge = "563852208932651010",
    bot = "564029644257361920",
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
local trigger = "%"

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
    msg.channel.id == _G.channels.test_bot) then
        local sep = string.find(msg.content, " ")
        if sep then sep = sep - 1 end
        local command = string.sub(msg.content, #trigger + 1, sep)
        local args = string.sub(msg.content, #trigger + #command + 2):split(" ")

        -- Execute the command if it exists
        if _G.commands[command] then
            _G.log:print(msg.author.tag .. " called function " .. command)
            _G.commands[command](msg, args)
        else
            _G.log:print(msg.author.tag .. " : command " .. command .. " does not exist", 2)
		end
    end
end)

clock:on('hour', function()
    local now = os.date("*t")

    -- Delivers new challenge everyday at midnight
    if (now.hour == 0) and _G.commands["start"] then
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