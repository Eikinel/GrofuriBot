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
        local yma = event.date:split("/")
        local eventTimestamp = os.time({year=yma[1], month=yma[2], day=yma[3]})
        local deltaTime = os.difftime(eventTimestamp, timestamp) / (24 * 60 * 60) -- seconds in a day

        if math.floor(deltaTime) >= 0 and math.floor(deltaTime) <= 1 then
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