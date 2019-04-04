local M = {
    all = {},
    available = {},
    current = {}
}
M.__index = M
require('tools/copy')

function M:parse(filepath)
    local file = io.open(filepath, "r")

    if not file then
        _G.log:print("Cannot read " .. filepath .. " : file not found", 3)
        return nil
    end

    local buffer = file:read("*a")
    self.all = json.parse(buffer)
    self.available = json.parse(buffer) -- Duplicate all challenge to keep trace of the file's first state
    file:close()
    
    -- Remove done challenges to keep only available ones
    for _, id in ipairs(self.all.done) do
        for i, chall in ipairs(self.available.standard) do
            if id == chall.id then
                table.remove(self.available.standard, i)
            end
        end
    end

    return true
end

function M:selectChallenge(timestamp)
    if not self.available then
        _G.log:print("There's no challenge at all. Did you call parse() before selecting a challenge ?")
        return nil
    end

    for _, event in ipairs(self.available.events) do
        local now = os.date("*t")
        local eventDate = event.date:split("/")

        if tonumber(eventDate[1]) == now.year
        and tonumber(eventDate[2]) == now.month
        and tonumber(eventDate[3]) == now.day then
            self.current = event
            return
        end
    end

    if #self.available.standard == 0 then
        _G.log:print("No challenge left. Fill my JSON with content to continue challenging !", 2)
        return nil
    end

    -- Pseudo randomize using seed before returning random challenge
    math.randomseed(os.time())
    self.current = copy(self.available.standard[math.random(#self.available.standard)])

    return true
end

function M:update(filepath)
    table.insert(self.all.done, self.current.id)

    local updated = json.encode(self.all)
    local file = io.open(filepath, "w")

    file:write(updated)
    file:close()

    -- Flush previously read challenges
    self.all = {}
    self.available = {}
end

function M:getAvailable()
    return self.available
end

function M:getCurrent()
    return self.current
end

return M