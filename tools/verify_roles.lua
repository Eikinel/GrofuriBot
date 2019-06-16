function verifyRole(user, roles)
    for _, role in ipairs(roles) do
        if user:hasRole(role) then return true end
    end

    return false
end