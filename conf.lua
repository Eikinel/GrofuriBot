-- Global conf for all guilds

local conf = {}

conf.colorChart = {
    default = 0xF02E89
}

conf.folders = {
    commands = "commands/",
    guilds = "guilds/",
    tools = "tools/"
}

conf.files = {
    guilds = {
        settings = "settings.lua",
        players = "players.lua",
        challenges = "challenges.lua",
        gotcha = "gotcha.lua"
    }
}

return conf