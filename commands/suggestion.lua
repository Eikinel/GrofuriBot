local opt = require("tools/options")
require('tools/embed')
require("tools/show_table")

_G.registerCommand({"suggestion", "suggest"}, function(msg, args)
    local client = msg.client
    local guild = client:getGuild(_G.guildId)
    local options = opt:new(
        { "--title" },
        { "--description" },
        { "--type" }
    )

    showTable(args)

    options:splitArgs(args)

    showTable(options)

    if args == {} then
        _G.log:print("No argument provided", 2)
        msg:reply("Aucun argument donné. Pour obtenir l'aide, tapez `%help`")
        return
    end

    local membed = embed.new()
    local title = options:getValue("--title")
    local description = options:getValue("--description")
    local type = options:getValue("--type") or "lose"

    if type ~= "win" and type ~= "lose" and type ~= "both" then
        _G.log:print("Type argument is not valid : \"" .. type .. "\" passed", 3)
        msg:reply("Le type \"" .. type .. "\" n'est pas valide. Les types autorisés sont \"win\", \"lose\" et \"both\".")
        return
    end

    _G.log:print("Challenge with title " .. title .. " and type " .. type .. " suggested.")

    local which = type == "win" and "gagné" or (type == "lose" and "perdu" or "gagné/perdu")

    membed:setColor(_G.colorChart.default)
    membed:setAuthor("Nouveau challenge !", "", client.user:getAvatarURL())
    membed:setThumbnail(msg.author and msg.author:getAvatarURL() or nil)
    membed:setDescription("La challenge du jour est...")
    membed:addField(
        "Si tu __**" .. title .. "**__ aujourd'hui, tu es *furry* !",
        description)
    membed:addField(
        "Si vous avez " .. which .. ", pensez à utiliser la commande `%g" .. which .. "` pour enregistrer votre score de grofuri",
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