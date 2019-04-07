local history = {}
history.__index = history
history.today = os.date("%Y/%m/%d")
history.yesterday = os.date("%Y/%m/%d", os.time() - 24 * 60 * 60) -- Goes back 24 hours in time

function history:new(date, win, challengeId)
    local tmp = {}

    tmp.date = date
    tmp.win = win
    tmp.challengeId = challengeId

    return setmetatable(tmp, history)
end

return history