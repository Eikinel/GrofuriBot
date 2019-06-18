local conf = require("conf")
local serpent = require("deps/serpent/serpent")
require("tools/show_table")

local roles = {}
roles.__index = roles

function roles.getRoleByIndex(index, guildID)
    local filepath = conf.getFilePath(conf.files.roles, guildID)
    local data = dofile(filepath)
 
    if data and data.roles then return data.roles[index:lower()] end
end

function roles.createRole(guild, index, file)
    local role = guild:createRole(index)
    local filepath = conf.getFilePath(conf.files.roles, guild.id)
    local data = dofile(filepath) or {}

    if not data.roles then data.roles = {} end
    data.roles[index:lower()] = { name = index, id = role.id }
    
    local file = io.open(filepath, "w")

    file:write("local data = ")
    file:write(serpent.block(data))
    file:write("\nreturn data")
    file:close()
end

return roles