-- Global conf for all guilds
local conf = {}
conf.__index = conf

conf.colorChart = {
    default = 0xF02E89
}

conf.folders = {
    commands = "commands/",
    guilds = "guilds/",
    tools = "tools/"
}

conf.files = {
    settings = conf.folders.guilds .. "{guildID}/settings.lua",
    players = conf.folders.guilds .. "{guildID}/players.lua",
    challenges = conf.folders.guilds .. "{guildID}/challenges.lua",
    gotcha = conf.folders.guilds .. "{guildID}/gotcha.lua",
    roles = conf.folders.guilds .. "{guildID}/roles.lua"
}

-- 
conf.roles = {
    bot = "Bot",
    admin = "Admin",
    players = "Players",
    grofuri = "Grofuri",
    pafuri = "Pafuri"
}

function conf.getFilePath(filepath, guildID)
    return filepath:gsub("{guildID}", guildID)
end

return conf