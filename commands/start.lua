require('tools/embed')

_G.registerCommand({"start"}, function(msg, args)
    local client = msg.client or msg
    local guild = client:getGuild(_G.guildId)
    local challengeId = nil

    -- Check if it's a message
    if msg.author then
        -- Check for permissions
        if not guild:getMember(msg.author.id):hasRole(_G.roles.admin) then
            _G.log:print(msg.author.tag .. " attempted to start a challenge", 2)
            msg:reply("Tu n'as pas les permissions suffisantes pour démarrer un challenge")
            return
        end
    end

    if not guild then
        _G.log:print("No guild matching requirements with id " .. guildId .. " found.", 3)
        return
    end

    local channel = guild:getChannel(_G.channels.challenge)
    
    if not channel then
        _G.log:print("Cannot send challenge : channel not found", 3)
        return
    end

    -- If it's a message and args are passed, select challenge by this ID
    if args and #args > 0 then
        challengeId = tonumber(args[1])
        
        if not challengeId then
            _G.print:log(args[1] .. " is not a number.", 2)
            msg:reply(args[1] .. " n'est pas un nombre.")
            return
        end
    end

    -- Parse the appropriate JSON and select a challenge
    _G.log:print("Selecting new challenge")
    if not challenge:parse(_G.conf.challengesFile) then return end
    if not challenge:selectChallenge(challengeId) then
        local error = "Oops, je n'ai plus de challenge à vous proposer ! Donnez-moi de quoi vous challenger !"

        -- Answer either on the challenge channel or directly to the person who called the %start command
        if msg.client then
            msg:reply(error)
        else
            channel:send(error)
        end

        return
    end

    challenge:update(_G.conf.challengesFile)

    -- Reset grofuri roles for every players
    for _, player in pairs(guild.members) do
        if not player.user.bot then
            if player:hasRole(_G.roles.grofuri) then
                player:removeRole(_G.roles.grofuri)
                _G.log:print("Flush role grofuri for player " .. player.tag)
            end
        end
    end

    -- Construct new message to send to the guild
    local current = challenge:getCurrent()
    local author = client:getUser(current.authorId)
    local membed = embed.new()
    
    membed:setColor(_G.colorChart.default)
    membed:setAuthor("Nouveau challenge !", "", client.user:getAvatarURL())
    membed:setThumbnail(author and author:getAvatarURL() or nil)
    membed:setDescription("La challenge du jour est...")
    membed:addField(
        "Si tu __**" .. current.title .. "**__ aujourd'hui, tu es *furry* !",
        current.description)
    membed:addField(
        "Si vous avez perdu, pensez à utiliser la commande `%gperdu` pour enregistrer votre score de grofuri",]]--
        [[\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_]])
    membed:setFooter("Proposé par " .. (author and author.tag or "Unknown"))
    membed:setTimestamp(os.date("!%Y-%m-%dT%TZ"))
    channel:send({embed = membed})
    _G.log:print("Challenge n°" .. current.id .. " sent to the guild \"" .. guild.name .. "\"")
end)