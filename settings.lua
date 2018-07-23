local mt = {}
mt.__index = function(self, key) 
    return hs.settings.get(key)
end

mt.__newindex = function(self, key, value)
    hs.settings.set(key, value)
end

local settings = {}
setmetatable(settings, mt)
return settings
