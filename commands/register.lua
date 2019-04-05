_G.registerCommand({"register", "add"}, function(msg, args)
    local guild = msg.guild
    local player = msg.author

    if #args > 0 and guild:getMember(player.id):hasRole(_G.roles.admin) then
        if #msg.mentionedUsers > 0 then
            player = msg.mentionedUsers:toArray()[1]
        else
        end
    end

    local filename = "players.json"
    local file = io.open(filename, "w+")
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

    table.insert(data.players, {id = player.id})
    io.open(filename, "w"):close() -- Flush file content
    file:write(json.encode(data)) -- Rewrite using previous and new datas
    file:close()

    msg:reply((sameGuy and "Tu" or player.mentionString) .. " a" .. (sameGuy and "s" or "") .. " bien été enregistré en tant que joueur de Grofuri. " ..
    "Pour plus d'informations, tape `%help`")
end)