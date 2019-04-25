function string.addSeparation(self, char, len)
    for i = 1, len do
        self = self .. char
    end

    self = self .. "\n"

    return self
end

function string.addSpace(self, len)
    local ret = ""

    for i = 1, 3 * len - #self do
        ret = ret .. " "
    end
    
    ret = ret .. self

    return ret
end

_G.registerCommand({"crab", "rave"}, function(msg, args)
    local ret = ""
    local crab = "🦀"
    local len = 5

    if #args < 0 then
        msg:reply("Aucun argument donné")
        _G.log:print("msg.author.tag" .. " hasn't send argument", 2)
        return
    end
    
    local up = args[1]:upper()
    local down = args[2] and args[2]:upper() or "IS GONE"

    ret = ret:addSeparation(crab, len)
    ret = ret .. up:addSpace(len) .. "\n"
    ret = ret:addSeparation('-', len * 4)
    ret = ret .. down:addSpace(len) .. "\n"
    ret = ret:addSeparation(crab, len)

    msg:reply(ret)
end)