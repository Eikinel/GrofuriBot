local function searchPlayerById(players, id)
    for i, player in ipairs(players) do
        if player.id == id then
            return player
        end
    end
end

local function selectRandomSentence(data, msg) -- Select a random author, other than the loser himself
    local i = math.random(#data)

    while #data > 1 and data[i].authorId == msg.author.id do
        i = math.random(#data)
    end

    return msg.client:getUser(data[i].authorId), data[i].sentences[math.random(#data[i].sentences)] 
end

local function hasAlreadyLost(history)
    for _, v in ipairs(history) do
        if v.date == os.date("%y/%m/%d") then return true end
    end

    return false
end

_G.registerCommand({"gperdu", "perdu", "jeu", "lejeu"}, function(msg, args)
    local guild = msg.guild
    local author = msg.author
    local filename = "players.json"

    if not guild:getMember(author.id):hasRole(_G.roles.player) then
        _G.log:print(author.tag .. " doesn't have the player role")
        msg:reply("Tu n'as pas le rôle Joueur ! Pour t'enregistrer, tapes `%register`")
        return
    end

    local file = io.open(filename, "a+")
    local data = json.decode(file:read("*a"))
    local player = searchPlayerById(data.players, author.id)

    -- Add the lose to history
    if player then
        if not player.history then player.history = {} end -- Create empty history we'll fill
        if not hasAlreadyLost(player.history) then -- Don't duplicate data
            table.insert(player.history, {date = os.date("%y/%m/%d"), win = false, challengeId = _G.challenge:getCurrent().id})
            _G.log:print("Add lose at date " .. os.date("%y/%m/%d") .. " for player " .. author.name, 1)
        else
            msg:reply("Tu as déjà perdu, ce serait dommage d'être furry ET con...")
            _G.log:print("Player " .. author.name .. " has already lost", 2)
            return
        end
    else
        _G.log:print(player.name .. " with ID " .. player.id .. " is a player but don't have its id registered", 3)
        msg:reply("Oups, une erreur est survenue, je vais vite prévenir " .. msg.client.owner.mentionString .. " !")
        return
    end

    io.open(filename, "w"):close() -- Flush file content
    file:write(json.encode(data)) -- Rewrite using previous and new data
    file:close()
    guild:getMember(author.id):addRole(_G.roles.grofuri)

    file = io.open("gotcha.json", "r")

    if not file then
        _G.log:print("No gotcha phrases found. If you want custom sentences, write an array in \"gotcha.json\"", 2)
    end

    data = json.decode(file:read("*a"))

    if #data == 0 then
        _G.log:print("Empty array found in " .. filename .. ". Default sentence will be used", 2)
        msg:reply("Gott'em !")
    else
        math.randomseed(os.time())
        local a, s = selectRandomSentence(data, msg)
        local membed = embed:new()

        membed:setColor(_G.colorChart.default)
        membed:setAuthor("🔔 ALERTE FURRY 🔔", "", msg.client.user:getAvatarURL())
        membed:setThumbnail(msg.author:getAvatarURL())
        membed:addField(msg.author.name .. " est un **grofuri**", "*\"" .. s .. "\"*")
        membed:setFooter("- " .. a.name .. ", " .. os.date("%Y"))
        
        guild:getChannel(_G.channels.challenge):send({embed = membed})
    end
end)