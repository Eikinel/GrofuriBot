local options = {}
options.__index = options

function options.splitArgs(args)
    local t = {}

    for _, arg in ipairs(args) do
        local key = arg:match("^(%-%-%a+)")

        if key then
            local value = arg:match("(=%w+)$")

            t[#t + 1] = {}
            t[#t].arg = key
            t[#t].value = value and value:sub(2, #value) or nil
        elseif arg:match("%-%a+$") then
            for n = 2, #arg do
                t[#t + 1] = {}
                t[#t].arg = "-" .. arg:sub(n, n)
            end
        end
    end

    return t
end

function options:getKeys()
    return self.keys
end

function options:getOptions()
    return self.options
end

function options:getOption(key)
    -- Loop inside "keys" table, that contains the different options aliases
    -- Because aliases are used as a table key (i.e {"-j", "--jaj"} is a key), we have to retrieve the table adress through "keys" table
    for _, t in ipairs(self.keys) do
        -- Current state is ipairs(t.keys) = {[0] = table 0xJAJ, [1] = table 0xWHU}
        for _, v in ipairs(t) do
            -- Current state is ipairs(t) = {[0] = "-shortoption", [1] = "--longoption"}
            -- Returns the corresponding table, using table as key
            if v == key then return t, self.options[t] end
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
        t.options[t.keys[#t.keys]] = { false, nil } -- Table as key value
    end

    return setmetatable(t, options)
end

return options