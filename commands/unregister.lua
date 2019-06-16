registerCommand({"unregister", "remove"}, function(msg, args)
    local guild = msg.guild
    local player = msg.author
    local sameGuy = true

    if #msg.mentionedUsers > 0 then
        mention = msg.mentionedUsers:toArray()[1]
    
        -- Admin only
        if not guild:getMember(msg.author.id):hasRole(_G.roles.admin) and mention.id ~= msg.author.id then
            _G.log:print(msg.author.tag .. " doesn't have enough permission to unregister " .. mention.mentionString)
            msg:reply("Tu n'as pas les permissions suffisantes pour supprimer " .. mention.mentionString)
            return
        end
    
        player = mention
        sameGuy = player.id == msg.author.id
    end

    if not guild:getMember(player.id):hasRole(_G.roles.player) then
        _G.log:print(player.tag .. " doesn't have the role player", 2)
        msg:reply((sameGuy and "Tu" or player.mentionString) .. " n'a" .. (sameGuy and "s" or "") .. " pas le rôle joueur !")
        return
    end

    local file = io.open(_G.conf.playersFile, "a+")
    local buffer = file:read("*a")
    local data = json.decode(buffer) or {}
    if not data.players then data.players = {} end

    -- Check for matching ID
    for i, obj in ipairs(data.players) do
        if obj.id == player.id then
            table.remove(data.players, i)
        end
    end

    io.open(_G.conf.playersFile, "w"):close() -- Flush file content
    file:write(json.encode(data)) -- Rewrite using previous and new datas
    file:close()
    guild:getMember(player.id):removeRole(_G.roles.player)
    guild:getMember(player.id):removeRole(_G.roles.grofuri)

    _G.log:print("Player \"" .. player.tag .. "\" with ID " .. player.id .. " has been removed")
    msg:reply((sameGuy and "Tu" or player.mentionString) .. " a" .. (sameGuy and "s" or "") .. " été supprimé de la liste des joueurs.")
end)