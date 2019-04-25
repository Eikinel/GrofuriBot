function table:getKey(value)
    for k, v in pairs(self) do
        if v == value then return k end
    end
end