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
    local xor = function(a, b)
        a = btoi(a)
        b = btoi(b)
        return itob(a + b - 2 * a * b)
    end

    args = options.splitArgs(args)
    showTable(args)

    -- Loop on arguments, get the option and set it appropriately
    for _, arg in ipairs(args) do
        -- Loop on options
        for i, opts in ipairs(options:getOptions()) do
            -- Loop on aliases of current option
            for _, opt in ipairs(opts) do
                if opt == arg then
                    options:getState(i) = true
                    -- Break the for loop because we reached the correct alias
                    break
                end
            end
        end
    end

    print()
    showTable(options:getState())

    local values = options:getState()
    local opts = options:getOptions()
    local now = os.date("*t")
    local start = os.time()
    -- Substract x days from start depending on year/month/week/day
    local ending = os.difftime(start, os.time({
        year = now.year - btoi(values[opts[4]]),
        month = now.month - btoi(values[opts[3]]),
        day = now.day - btoi(values[opts[2]]) * 7 - btoi(values[opts[1]])
    }))

    print (now.year - btoi(values[opts[4]]))
    print (now.month - btoi(values[opts[3]]))
    print (now.day - btoi(values[opts[2]]) * 7 - btoi(values[opts[1]]))

    print()
    showTable(os.date("*t", start))
    showTable(os.date("*t", ending))

    local histories = history.findByPeriod("players.json", msg.author.id, start, ending)
    print()
    showTable(histories)
end)