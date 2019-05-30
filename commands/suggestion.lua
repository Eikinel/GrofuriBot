local opt = require("tools/options")
require('tools/embed')
require("tools/show_table")

_G.registerCommand({"suggestion", "suggest"}, function(msg, args)
    local client = msg.client
    local guild = client:getGuild(_G.guildId)
    local options = opt:new(
        { "--title" },
        { "--description" }
    )

    options:splitArgs(args)

    if args == {} then
        _G.log:print("No argument provided", 2)
        msg:reply("Aucun argument donné. Pour obtenir l'aide, tapez `%help`")
        return
    end

    local membed = embed.new()
    local title = options:getValue("--title")
    local description = options:getValue("--description")
    local isneg = title:find("(n[e'].+pas)")

    membed:setColor(_G.colorChart.default)
    membed:setAuthor("Nouveau challenge !", "", client.user:getAvatarURL())
    membed:setThumbnail(msg.author and msg.author:getAvatarURL() or nil)
    membed:setDescription("La challenge du jour est...")
    membed:addField(
        "Si tu __**" .. title .. "**__ aujourd'hui, tu es *furry* !",
        description)
    membed:addField(
        "Si vous avez " .. (isneg and "gagné" or "perdu") .. ", pensez à utiliser la commande `%g" .. (isneg and "gagné" or "perdu") .. "` pour enregistrer votre score de grofuri",
        [[\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_]])
    membed:setFooter("Proposé par " .. (msg.author and msg.author.tag or "Unknown"))
    membed:setTimestamp(os.date("!%Y-%m-%dT%TZ"))

    newmsg = msg:reply({
        content = "Challenge preview : Réagissez avec ✅ pour valider, ou ❌ pour rejeter la proposition",
        embed = membed
    })

    _G.challenge:addPending(newmsg, msg.author.id, options)
    newmsg:pin()
    newmsg:addReaction("✅")
    newmsg:addReaction("❌")
end)