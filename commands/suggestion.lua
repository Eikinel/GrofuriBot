local opt = require("tools/options")
require('tools/embed')
require("tools/show_table")

_G.registerCommand({"suggestion", "suggest"}, function(msg, args)
    local client = msg.client
    local guild = client:getGuild(_G.guildId)
    local options = opt:new(
        { "-t", "--title" },
        { "-d", "--description" })

    showTable(args)

    args = options.splitArgs(args)

    showTable(args)

    if args == {} then
        _G.log:print("No argument provided", 2)
        msg:reply("Aucun argument donné. Pour obtenir l'aide, tapez `%help`")
        return
    end
end)