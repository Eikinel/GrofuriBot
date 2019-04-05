_G.registerCommand({"start"}, function(msg)
    local client = msg.client or msg
    local guild = client:getGuild(_G.guildId)

    -- Check if it's a message
    if msg.author then
        -- Check for permissions
        if not guild:getMember(msg.author.id):hasRole(_G.roles.admin) then
            _G.log:print(msg.author.tag .. " attempted to start a challenge", 2)
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

    -- Reset grofuri roles for every players
    for _, player in pairs(guild.members) do
        if not player.user.bot and player:hasRole(_G.roles.grofuri) then
            player:removeRole(_G.roles.grofuri)
            _G.log:print("Flush role grofuri for player " .. player.tag)
        end
    end

    -- Parse the appropriate JSON and select a challenge
    local challengeFile = "challenges.json"

    _G.log:print("Selecting new challenge")
    if not challenge:parse(challengeFile) then return end
    if not challenge:selectChallenge(os.time()) then
        channel:send("Oops, je n'ai plus de challenge à vous proposez ! Donnez-moi de quoi vous challenger !")
        return
    end

    challenge:update(challengeFile)
    _G.log:print("Updated file " .. challengeFile)
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
        "Si vous avez perdu, pensez à utiliser la commande `%gperdu` pour enregistrer votre score de grofuri",
        [[\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_]])
    membed:setFooter("Proposé par " .. (author and author.tag or "Unknown"))
    membed:setTimestamp(os.date("!%Y-%m-%dT%TZ"))
    channel:send({embed = membed})
    _G.log:print("Challenge n°" .. current.id .. " sent to the guild \"" .. guild.name .. "\"")
end)