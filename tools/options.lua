local options = {}
options.__index = options

function options:splitArgs(args)
    for i, arg in ipairs(args) do
        local key = arg:match("^(%-%-[%a-]+)")

        if key then
            -- Get next arg as value temporarily, if exists
            local value = i < #args and args[i + 1] or nil
            local isarg = nil
            local t = self:getTableKey(key)

            -- Double check tmp value to check if it does not match argument format
            -- It can be bypassed by wrapping text between quotes (i.e --arg "--value")
            if value then isarg = value:match("^(%-%-%a+)") or value:match("%-%a+$") end

            self.options[t] = {}
            self.options[t].arg = key
            self.options[t].value = (value and isarg == nil) and value or nil
        elseif arg:match("%-%a+$") then
            local t = self:getTableKey(key)

            for n = 2, #arg do
                self.options[t] = {}
                self.options[t].arg = "-" .. arg:sub(n, n)
            end
        end
    end
end

function options:getKeys()
    return self.keys
end

function options:getOptions()
    return self.options
end

function options:getTableKey(key)
    -- Loop inside "keys" table, that contains the different options aliases
    -- Because aliases are used as a table key (i.e {"-j", "--jaj"} is a key), we have to retrieve the table adress through "keys" table
    for _, t in ipairs(self.keys) do
        -- Current state is ipairs(t.keys) = {[0] = table 0xJAJ, [1] = table 0xWHU}
        for _, v in ipairs(t) do
            -- Current state is ipairs(t) = {[0] = "-shortoption", [1] = "--longoption"}
            -- Returns the corresponding table, using table as key
            if v == key then return t end
        end
    end
end

function options:getValue(key)
    -- Loop inside "keys" table, that contains the different options aliases
    -- Because aliases are used as a table key (i.e {"-j", "--jaj"} is a key), we have to retrieve the table adress through "keys" table
    for _, t in ipairs(self.keys) do
        -- Current state is ipairs(t.keys) = {[0] = table 0xJAJ, [1] = table 0xWHU}
        for _, v in ipairs(t) do
            -- Current state is ipairs(t) = {[0] = "-shortoption", [1] = "--longoption"}
            -- Returns the corresponding table, using table as key
            if v == key then return self.options[t].value end
        end
    end
end

function options:setOption(key, ...)
    local t = {}

    -- true/false, value
    self.options[key] = {...}
end

function options:new(...)
    local t = {}
    t.options = {}
    t.keys = {}

    -- Fill options with default values
    for _, options in ipairs({...}) do
        t.keys[#t.keys + 1] = options -- Keep trace of original option table
        t.options[t.keys[#t.keys]] = { } -- Table as key value
    end

    return setmetatable(t, options)
end

return options