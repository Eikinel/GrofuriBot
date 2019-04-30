local opt = require("tools/options")
local history = require("tools/history")
require("tools/show_table")
require('tools/embed')
require("tools/bool")

_G.registerCommand({"display", "show"}, function(msg, args)
    local client = msg.client
    local guild = client:getGuild(_G.guildId)
    local players = {msg.author}

    if #msg.mentionedUsers > 0 then
        players = msg.mentionedUsers:toArray()
    end

    local options = opt:new(
        { "-d", "--day" },
        { "-w", "--week" },
        { "-m", "--month" },
        { "-y", "--year" }, 
        { "--in-pixel" }
    )

    args = options.splitArgs(args)
    showTable(args)

    -- Loop on arguments, get the option and set it appropriately
    for i, arg in ipairs(args) do
        -- Get table as key and option value (elipsed here)
        local t, _ = options:getOption(arg.arg)

        -- Set the option to true with specified value, if it exists
        if t then options:setOption(t, true, arg.value) end
    end

    print()
    showTable(options)

    local keys = options:getKeys()
    local now = os.date("*t")
    local start = os.time()
    local ending = start

    -- From "--year" to "--day"
    for i = #keys - 1, 1, -1 do
        local t, v = options:getOption(key[i][1])
    end

    local histories = history.findByPeriod("players.json", msg.author.id, start, ending)
    print()
    showTable(histories)
end)