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

function embed:setUrl(color)
    self.color = color
end

function embed:setUrl(timestamp)
    self.timestamp = timestamp
end

function embed:setAuthor(name, url, icon_url)
    if not name then
        _G.log:print("Cannot add author for embed " .. self.title .. " : name is empty")
        return
    end

    self.author = {}
    self.author.name = name
    self.author.url = url
    self.author.icon_url = icon_url
end

function embed:setFooter(text, icon_url)
    if not text then
        _G.log:print("Cannot add footer for embed " .. self.title .. " : text is empty")
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

function embed:addField(name, content)
    local field = {}

    field.name = name
    field.value = content

    table.insert(embed.fields, field)
end

function embed:new(title)
    return setmetatable({title = title or "Default title"}, embed)
end

return embed