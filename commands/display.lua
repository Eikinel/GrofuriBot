--[[local opt = require("tools/options")
local history = require("tools/history")
require("tools/show_table")
require('tools/embed')

_G.registerCommand({"display", "show"}, function(msg, args)
    local client = msg.client
    local guild = client:getGuild(_G.guildId)
    local players = {msg.author}

    if #msg.mentionedUsers > 0 then
        players = msg.mentionedUsers:toArray()
    end

    local options = opt:new(
        { "-d", "--day" },
        { "-m", "--month" },
        { "-y", "--year" },
        { "--in-pixel" }
    )

    options:splitArgs(args)

    if args == {} then
        _G.log:print("No argument provided", 2)
        msg:reply("Aucun argument donné. Pour obtenir l'aide, tapez `%help`")
        return
    end

    -- local keys = options:getKeys()
    local xyear = options:getValue("--year")
    local xmonth = options:getValue("--month")
    local xday = options:getValue("--day")

    showTable(xmonth)

    local now = os.date("*t")
    local start = os.time({
        year = xyear[2] or now.year,
        month = xyear[1] and 1 or xmonth[2] or now.month,
        day = xyear[1] and 1 or xday[2] or now.day, 
        hour = 0, min = 0, sec = 0
    })
    local startDate = os.date("*t", start)
    local ending = os.time({
        year = startDate.year + (xyear[1] and 1 or 0),
        month = startDate.month + (xmonth[1] and 1 or 0),
        day = startDate.day + (xday[1] and 0 or -1),
        hour = 23, min = 59, sec = 59
    })

    _G.log:print("Fetching history and creating embeded messages")
    -- Fetch history and send message for each tagged players
    for _, player in ipairs(players) do
        local histories = history.findByPeriod(_G.conf.playersFile, player.id, start, ending)
        local membed = embed.new()
        local format = function(strdate)
            local ret = ""
            local t = strdate:split(" ")
            local months = { "Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre" }

            ret = (t[1]:sub(1, 1) == "0" and t[1]:sub(2, #t[1]) or t[1]) .. " " .. months[tonumber(t[2])] .. " " .. t[3]
            return ret
        end

        showTable(histories)

        membed:setColor(_G.colorChart.default)
        membed:setAuthor("Résultats de " .. player.name, "", client.user:getAvatarURL())
        membed:setThumbnail(player:getAvatarURL())
        membed:setDescription(
            xday[1] 
            and "Le " .. format(os.date("%d %m %Y", start))
            or "Dans la période du " .. format(os.date("%d %m %Y", start)) .. " au " .. format(os.date("%d %m %Y", ending))
        )

        for _, h in ipairs(histories) do
            local chall = _G.challenge:getChallengeById(h.challengeId)

            if not chall then
                _G.log:print("No challenge with id " .. h.challengeId .. " found", 3)
                membed:addField(
                    "Erreur: challenge n°" .. h.challengeId .. " non trouvé",
                    "*Oups...*")
            else
                membed:addField(
                    "Challenge n°" .. h.challengeId .. " **" .. (h.win and "gagné" or "perdu") ..
                    "** le " .. format(os.date("%d %m %Y", history.fromDateFormatToTime(h.date))),
                    "*Si tu " .. chall.title .. "*")
            end
        end

        msg:reply({embed = membed})
    end

    _G.log:print("Results sent")
end)--]]