local fs = requireLuvit("fs")
local serpent = require("deps/serpent/serpent")
local roles = require("tools/roles")

registerCommand({"register", "add"}, function(msg, args)
    local guild = msg.guild
    local player = msg.author
    local rfilepath = conf.getFilePath(conf.files.roles, guild.id)
    local pfilepath = conf.getFilePath(conf.files.players, guild.id)


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

    
    if not fs.existsSync(rfilepath) then
        -- Create roles file
        io.open(rfilepath, "w"):close()
        log:print("File with path " .. rfilepath .. " created")
    end

    if not roles.getRoleByIndex(conf.roles.players, guild.id) then
        msg:reply("Le rôle \"" .. conf.roles.players .. "\" n'existe pas encore. Création du rôle...")
        log:print("Role \"" .. conf.roles.players .. "\" doesn't exist yet", 2)
        roles.createRole(guild, conf.roles.players)
    end


    -- Check for existing file
    if not fs.existsSync(pfilepath) then
        -- Create players file
        io.open(pfilepath, "w"):close()
        log:print("File with path " .. pfilepath .. " created")
    end

    local data = dofile(pfilepath) or {}
    if not data.players then data.players = {} end
    local sameGuy = player.id == msg.author.id and true or false

    -- Check for matching ID
    for _, obj in ipairs(data.players) do
        if obj.id == player.id then
            log:print("Player \"" .. player.tag .. "\" with ID " .. player.id .. " already exists", 2)
            msg:reply((sameGuy and "Tu" or player.mentionString) .. " es" .. (sameGuy and "" or "t") .. " déjà enregistré en tant que joueur !")
            return
        end
    end
    
    data.players[#data.players + 1] = { id = player.id, history = {} }
    
    local file = io.open(pfilepath, "w")

    file:write("local data = ")
    file:write(serpent.block(data))
    file:write("\n\nreturn data")
    file:close()

    data = dofile(rfilepath)
    guild:getMember(player.id):addRole(data.roles.players.id)

    msg:reply((sameGuy and "Tu" or player.mentionString) .. " a" .. (sameGuy and "s" or "") .. " bien été enregistré en tant que joueur de Grofuri. " ..
    "Pour plus d'informations, tape `%help`")
    log:print("Player \"" .. player.tag .. "\" with ID " .. player.id .. " is now a player")
end)