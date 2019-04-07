local options = {}
options.__index = options

function options.splitArgs(args)
    t = {}

    for _, arg in ipairs(args) do
        if arg:match("%-%-%a+") then
            t[#t + 1] = arg
        elseif arg:match("%-%a+") then
            for n = 2, #arg do
                t[#t + 1] = "-" .. arg:sub(n, n)
            end
        end
    end

    return t
end

function options:getOptions()
    return self.options
end

function options:new(...)
    local t = {}
    t.options = {}
    t.values = {}

    -- Fill options with default values
    for _, option in ipairs({...}) do
        t.options[#t.options + 1] = option
        t.values[#t.values + 1] = false
    end

    return setmetatable(t, options)
end

return options