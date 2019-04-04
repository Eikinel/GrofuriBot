embed = {}
embed.__index = embed

function embed:setTitle(title)
    self.title = title
end

function embed:setDescription(description)
    self.description = description
end

function embed:setUrl(url)
    self.url = url
end

function embed:setColor(hex)
    if not hex then
        _G.log.print("Cannot add color for embed : no hexadecimal color given")
        return
    end

    -- Compute colors from separate decimal to 16M colors
    self.color = hex
end

function embed:setTimestamp(timestamp)
    self.timestamp = timestamp
end

function embed:setAuthor(name, url, icon_url)
    if not name then
        _G.log:print("Cannot add author for embed : name is empty")
        return
    end

    self.author = {}
    self.author.name = name
    self.author.url = url
    self.author.icon_url = icon_url
end

function embed:setFooter(text, icon_url)
    if not text then
        _G.log:print("Cannot add footer for embed : text is empty")
        return
    end

    self.footer = {}
    self.footer.text = text
    self.footer.icon_url = icon_url
end

function embed:setThumbnail(url)
    self.thumbnail = {}
    self.thumbnail.url = url
end

function embed:setImage(url)
    self.image = {}
    self.image.url = url
end

function embed:addField(name, value, inline)
    local field = {}

    field.name = name
    field.value = value
    field.inline = inline or false

    if not self.fields then self.fields = {} end
    self.fields[#self.fields + 1] = field
end

function embed:new(title)
    return setmetatable({}, embed)
end

return embed