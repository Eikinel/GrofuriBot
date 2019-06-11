local history = require('tools/history')

local function selectRandomSentence(data, msg) -- Select a random author, other than the loser himself
    math.randomseed(os.time())

    local i = math.random(#data)

    while #data > 1 and data[i].authorId == msg.author.id do
        i = math.random(#data)
    end

    return msg.client:getUser(data[i].authorId), data[i].sentences[math.random(#data[i].sentences)] 
end

_G.registerCommand({"gperdu", "perdu", "lejeu", "ggagné", "gagné", "palejeu"}, function(msg, args)
    local guild = msg.guild
    local author = msg.author
    local current = _G.challenge:getCurrent()

    -- No challenge inbound
    if not current then
        _G.log:print("No challenge is running.", 2)
        msg:reply("Il n'y a aucun challenge en cours. Reviens plus tard !")
        return
    end

    -- The message author is not a player
    if not guild:getMember(author.id):hasRole(_G.roles.player) then
        _G.log:print(author.tag .. " doesn't have the player role")
        msg:reply("Tu n'as pas le rôle Joueur ! Pour t'enregistrer, tapes `%register`")
        return
    end
    
    local sep = msg.content:find(" ")
    if sep then sep = sep - 1 end
    local command = msg.content:sub(2, sep)
    local iscommandwin = command == "ggagné" or command == "gagné" or command == "palejeu"

    -- Force the player to use one command or its opposite according to challenge type
    if current.type == "win" and not iscommandwin or
    current.type == "lose" and iscommandwin then
        local iswin = current.type == "win" and true or false

        _G.log:print("Player " .. author.name .. " used the command " .. command .. " but the challenge type is " .. current.type)
        msg:reply("Utilisez la commande inverse `%g" .. (iswin and "gagné" or "perdu") ..
        "` car le challenge indique une action de type **" .. (iswin and "gagneable" or "perdable") .. "**.\n" ..
        "Vous " .. (iswin and "perdrez" or "gagnerez") .. " **automatiquement** à la fin de la journée si la commande n'a pas été tapée.")
        return
    end

    local file = io.open(_G.conf.playersFile, "a+")
    local data = json.decode(file:read("*a"))

    -- Empty player file (should not happend)
    if not data or not data.players then
        _G.log:print("No players available (empty file)", 3)
        return
    end

    local player = history.searchPlayerById(data.players, author.id)
    local set = history.addToHistory(player, os.date(history.dateFormat), iscommandwin, current.id)
    if set == -1 then msg:reply("Tu as déjà complété ce challenge.") return end

    io.open(_G.conf.playersFile, "w"):close() -- Flush file content
    file:write(json.encode(data)) -- Rewrite using previous and new data
    file:close()

    local membed = embed:new()

    membed:setColor(_G.colorChart.default)
    membed:setThumbnail(msg.author:getAvatarURL())

    if iscommandwin then
        guild:getMember(author.id):addRole(_G.roles.pafuri)
        membed:setAuthor("🔔 NOUS AVONS UN GAGNANT 🔔", "", msg.client.user:getAvatarURL())
        membed:addField("Notre camarade " .. msg.author.name .. " s'est battu vaillament et ne deviendra pas Grofuri aujourd'hui.", "Bravo mon con.")
        membed:setTimestamp(os.date("!%Y-%m-%dT%TZ"))
    else
        membed:setAuthor("🔔 ALERTE FURRY 🔔", "", msg.client.user:getAvatarURL())
        
        guild:getMember(author.id):addRole(_G.roles.grofuri)
        file = io.open("gotcha.json", "r")

        if not file then
            _G.log:print("No gotcha phrases found. If you want custom sentences, write an array in \"gotcha.json\"", 2)
        end

        data = json.decode(file:read("*a"))

        if #data == 0 then
            _G.log:print("Empty array found in " .. _G.conf.playersFile .. ". Default sentence will be used", 2)
    
            membed:addField("Gott'em !", "Grofuri spotted !")
            membed:setTimestamp(os.date("!%Y-%m-%dT%TZ"))
        else
            local a, s = selectRandomSentence(data, msg)

            membed:addField(msg.author.name .. " est un **grofuri**", "*\"" .. s .. "\"*")
            membed:setFooter("- " .. a.name .. ", " .. os.date("%Y"))
        end
    end
            
    guild:getChannel(_G.channels.challenge):send({embed = membed})
end)