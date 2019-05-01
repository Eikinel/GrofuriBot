require('tools/copy')
require("tools/show_table")

local M = {
    all = {},
    available = {},
    current = nil
}
M.__index = M

function M:parse(filepath)
    local file = io.open(filepath, "r")

    if not file then
        _G.log:print("Cannot read " .. filepath .. " : file not found", 3)
        return nil
    end

    local buffer = file:read("*a")
    self.all = json.parse(buffer)
    self.available = copy(self.all) -- Duplicate all challenge to keep trace of the file's first state
    file:close()
    
    if not self.all then
        _G.log:print("challenges.json exists but is empty", 3)
        return
    end

    -- Remove done challenges to keep only available ones
    if not self.all.done then self.all.done = {} end
    for _, id in ipairs(self.all.done) do
        for i, chall in ipairs(self.available.standard) do
            if id == chall.id then
                table.remove(self.available.standard, i)
            end
        end
    end

    return true
end

function M:selectChallenge(challengeId)
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

    if not challengeId and #self.available.standard == 0 then
        _G.log:print("No challenge left. Fill the JSON with content to continue challenging.", 2)
        return nil
    end

    -- Pseudo randomize using seed before returning random challenge
    math.randomseed(os.time())

    -- Check if challengeId is valid
    if challengeId then
        -- Pick a challenge between *all* challenges
        if not self.all.standard[challengeId] then
            _G.log:print("Standard challenge with ID " .. challengeId .. " doesn't exist", 3)
            return
        end

        self.current = copy(self.all.standard[challengeId])
    else
        challengeId = math.random(#self.available.standard)
        self.current = copy(self.available.standard[challengeId])
    end

    _G.log:print("Challenge n°" .. self.current.id .. " selected", 1)

    return true
end

function M:update(filepath)
    -- No need to update if the id is already in the array
    -- This can happen if the admin manually start a challenge using an ID
    for _, id in ipairs(self.all.done) do
        if id == self.current.id then
            return
        end
    end
   
    table.insert(self.all.done, self.current.id)

    local updated = json.encode(self.all)
    local file = io.open(filepath, "w")

    file:write(updated)
    file:close()
    _G.log:print("Updated file " .. filepath)

    -- Flush previously read challenges
    self.all = {}
    self.available = {}
end

function M:getCurrent()
    return self.current
end

function M:getChallengeById(id)
    local file = io.open(_G.conf.challengesFile, "r")
    local buffer = file:read("*a")
    local all = json.parse(buffer)

    file:close()

    for _, challenge in ipairs(all.standard) do
        if challenge.id == id then
            return challenge 
        end
    end
end

return M