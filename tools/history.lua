local history = {}
history.__index = history
history.today = os.date("%Y/%m/%d")
history.yesterday = os.date("%Y/%m/%d", os.time() - 24 * 60 * 60) -- Goes back 24 hours in time

function history.findByPeriod(file, playerId, start, ending)
    local file = io.open(file, "r")
    if not file then
        _G.log:print("No file with name " .. file .. " found.", 3)
        return
    end

    local buffer = file:read("*a")
    if not buffer then
        _G.log:print("No content in file " .. file .. " found.", 2)
    end

    local content = json.parse(buffer)
    if not content.players then
        _G.log:print("No players in " .. file, 2)
    end

    -- Find for current player and retrieve history
    for _, player in content.players do
        if player.id == playerId then
            local histories = {}

            return histories
        end
    end
end

function history:new(date, win, challengeId)
    local tmp = {}

    tmp.date = date
    tmp.win = win
    tmp.challengeId = challengeId

    return setmetatable(tmp, history)
end

return history