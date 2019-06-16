registerCommand({"register", "add"}, function(msg, args)
    local guild = msg.guild
    local player = msg.author

    if #msg.mentionedUsers > 0 then
        mention = msg.mentionedUsers:toArray()[1]

        -- Admin only
        if not guild:getMember(msg.author.id):hasRole(_G.roles.admin) and mention.id ~= msg.author.id then
            _G.log:print(msg.author.tag .. " doesn't have enough permission to register " .. mention.mentionString)
            msg:reply("Tu n'as pas les permissions suffisantes pour ajouter " .. mention.mentionString)
            return
        end

        player = mention
        sameGuy = player.id == msg.author.id
    end

    local file = io.open(_G.conf.playersFile, "a+")
    local buffer = file:read("*a")
    local data = json.decode(buffer) or {}
    if not data.players then data.players = {} end
    local sameGuy = player.id == msg.author.id and true or false

    -- Check for matching ID
    for _, obj in ipairs(data.players) do
        if obj.id == player.id then
            _G.log:print("Player \"" .. player.tag .. "\" with ID " .. player.id .. " already exists", 2)
            msg:reply((sameGuy and "Tu" or player.mentionString) .. " es" .. (sameGuy and "" or "t") .. " déjà enregistré en tant que joueur !")
            return
        end
    end

    table.insert(data.players, {id = player.id, history = {}})
    io.open(_G.conf.playersFile, "w"):close() -- Flush file content
    file:write(json.encode(data)) -- Rewrite using previous and new datas
    file:close()
    guild:getMember(player.id):addRole(_G.roles.player)

    msg:reply((sameGuy and "Tu" or player.mentionString) .. " a" .. (sameGuy and "s" or "") .. " bien été enregistré en tant que joueur de Grofuri. " ..
    "Pour plus d'informations, tape `%help`")
    _G.log:print("Player \"" .. player.tag .. "\" with ID " .. player.id .. " is now a player")
end)