_G.registerCommand({"unregister", "remove"}, function(msg, args)
    local guild = msg.guild
    local player = msg.author
    local sameGuy = player.id == msg.author.id and true or false

    if #args > 0 then
        local oldPlayer = args[1]

        -- Admin only
        if not guild:getMember(player.id):hasRole(_G.roles.admin) then
            _G.log:print(msg.author.tag .. " doesn't have enough permission to unregister " .. oldPlayer)
            msg:reply("Tu n'as pas les permissions suffisantes pour supprimer " .. oldPlayer)
            return
        else
            if #msg.mentionedUsers > 0 then
                player = msg.mentionedUsers:toArray()[1]
            else
                _G.log:print(oldPlayer .. " is not a valid argument", 2)
                msg:reply(oldPlayer .. " n'est pas un argument valide")
                return
            end
        end
    end

    if not guild:getMember(player.id):hasRole(_G.roles.player) then
        _G.log:print(player.tag .. " doesn't have the role player", 2)
        msg:reply((sameGuy and "Tu" or player.mentionString) .. " n'a" .. (sameGuy and "s" or "") .. " pas le rôle joueur !")
        return
    end

    local filename = "players.json"
    local file = io.open(filename, "a+")
    local buffer = file:read("*a")
    local data = json.decode(buffer) or {}
    if not data.players then data.players = {} end

    -- Check for matching ID
    for i, obj in ipairs(data.players) do
        if obj.id == player.id then
            table.remove(data.players, i)
        end
    end

    io.open(filename, "w"):close() -- Flush file content
    file:write(json.encode(data)) -- Rewrite using previous and new datas
    file:close()
    guild:getMember(player.id):removeRole(_G.roles.player)
    guild:getMember(player.id):removeRole(_G.roles.grofuri)

    _G.log:print("Player \"" .. player.tag .. "\" with ID " .. player.id .. " has been removed")
    msg:reply((sameGuy and "Tu" or player.mentionString) .. " a" .. (sameGuy and "s" or "") .. " été supprimé de la liste des joueurs.")
end)