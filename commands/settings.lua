local opt = require("tools/options")
local fs = require("fs")
require("tools/verify_roles")

registerCommand({"settings", "parameters"}, function(msg, args)
    local client = msg.client
    local guild = client:getGuild(msg.guild.id)

    -- Check if it's a message
    if msg.author then
        -- Check for permissions
        if not verifyRole(guild:getMember(msg.author.id), { _G.roles.admin }) then
            _G.log:print(msg.author.tag .. " attempted to start a challenge", 2)
            msg:reply("Tu n'as pas les permissions suffisantes pour changer les paramètres du bot")
            return
        end
    end

    local options = opt:new(
        { "--locale" },
        { "--gmt" },
        { "--channels" },
        { "--trigger" }
    )

    options:splitArgs(args)

    if args == {} then
        _G.log:print("No argument provided", 2)
        msg:reply("Aucun argument donné. Pour obtenir l'aide, tapez `%help`")
        return
    end

    local filepath = _G.conf.guildsFolder .. guild.id
    local err = fs.mkdirSync(filepath)

    if err then
        _G.log:print("Cannot execute lfs \"mkdir " .. filepath .. "\" : " .. err)
        msg:reply("Une erreur est survenue à la création du dossier des fichiers de guilde." ..
        "Veuillez notifier " .. client.owner.mentionString .. " du problème.")
        return
    end

    filepath = filepath .. "/" .. _G.conf.settingsFile
    local file = io.open(filepath, "w")
    local buffer = file:read("*a")
    local settings = json.parse(buffer)

    -- Three possible values for either precised in argument, already set in the JSON or on settings creation
    settings.locale = options:getValue("--locale") or settings.locale or "en_US"
    settings.gmt = options:getValue("--gmt") or settings.gmt
    settings.channels = options:getValue("--channels") or settings.channels
    settings.trigger = options:getValue("--trigger") or settings.trigger or "%"
    
    -- Set new Grofuri's settings
    io.open(filepath, "w"):close() -- Flush file content
    file:write(json.encode(data)) -- Rewrite using previous and new data
    file:close()
end)