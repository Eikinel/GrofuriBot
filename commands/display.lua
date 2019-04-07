local opt = require("tools/options")
local debug = require("tools/show_table")

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
    for _, arg in ipairs(args) do
        -- Loop on options
        for i, opts in ipairs(options:getOptions()) do
            -- Loop on aliases of current option
            for _, opt in ipairs(opts) do
                if opt == arg then
                    options.values[i] = true
                end
            end
        end
    end

    print()
    showTable(options.values)

end)