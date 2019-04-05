local M = {}
M.challenge = {}
M.__index = M

local challenges = {}

function M:selectChallenge(timestamp)
    if not challenges then
        _G.log:print("There's no challenge. Did you call start() before selecting a challenge ?")
        return
    end

    for i, event in ipairs(challenges.events) do
        local now = os.date("*t")
        local eventDate = event.date:split("/")

        if tonumber(eventDate[1]) == now.year
        and tonumber(eventDate[2]) == now.month
        and tonumber(eventDate[3]) == now.day then
            self.challenge = event
            return
        end
    end

    -- Pseudo randomize using seed before returning random challenge
    math.randomseed(os.time())
    self.challenge = challenges.standard[math.random(#challenges.standard)]
end

function M:parse(client)
    local filepath = "challenges.json"
    local file = io.open(filepath, "r")

    if not file then
        _G.log:print("Cannot read " .. filepath .. " : file not found")
        return
    end

    local buffer = file:read("*a")
    challenges = json.parse(buffer)

    file:close()
end

return M