local history = {}
history.__index = history
history.dateFormat = "%Y/%m/%d"

function history.searchPlayerById(players, id)
    for i, player in ipairs(players) do
        if player.id == id then
            return player
        end
    end
end

function history.hasAlreadyPlayed(history, date)
    for _, v in ipairs(history) do
        if v.date == date then return true end
    end

    return false
end

function history.addToHistory(player, date, win, challengeId)
    -- Use player's data from players.json and add the win event to history
    if player then
        if not player.history then player.history = {} end -- Create empty history we'll fill
        if not history.hasAlreadyPlayed(player.history, date) then -- Don't duplicate data
            local entry = history:new(date, win, challengeId)

            table.insert(player.history, entry)
            _G.log:print("Add " .. (win and "win" or "lose") .. " at date " .. entry.date .. " for player " .. player.id)
        else
            _G.log:print("Player " .. player.id .. " has already played", 2)
            return -1
        end
    else
        _G.log:print("Player with ID " .. player.id .. " is a player but don't have its id registered", 3)
        return nil
    end

    return 1
end

function history.fromDateFormatToTime(date)
    local yy, mm, dd = date:match("(%d+)/(%d+)/(%d+)")

    return os.time({year = yy, month = mm, day = dd})
end

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

    local histories = {}
    -- Find for current player and retrieve history
    for _, player in ipairs(content.players) do
        if player.id == playerId then
            -- Loop inside history and fetch info within the period
            for _, info in ipairs(player.history) do
                local current = history.fromDateFormatToTime(info.date) -- Convert from string to time in seconds

                -- Store player's information if the date is within the period
                if current >= start and current <= ending then
                    histories[#histories + 1] = info
                end
            end

            break
        end
    end

    return histories
end

function history:new(date, win, challengeId)
    local tmp = {}

    tmp.date = date
    tmp.win = win
    tmp.challengeId = challengeId

    return setmetatable(tmp, history)
end

return history