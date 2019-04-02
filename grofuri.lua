-- Add discordia and various variables to the global scope
_G.discordia = require('discordia')
_G.log = require('log')
_G.tools = require('tools')
_G.embed = require('embed')
_G.commands = {}
_G.colorChart = {
    default = 0xF02E89
}

-- Internal variables
local client = discordia.Client()
local clock = discordia.Clock()
local trigger = "%"

client:on('ready', function()
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

    _G.log:print('Logged in as '.. client.user.username)
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