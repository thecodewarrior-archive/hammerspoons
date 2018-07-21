--- === CustomMenu ===

local obj={}
obj.__index = obj

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
obj.spoonPath = script_path()

-- Metadata
obj.name = "CustomMenu"
obj.version = "1.0"
obj.author = "TheCodeWarrior <pierce@plasticcow.com.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.menus = {}
obj.imgurClientID = nil

function obj:init()
end

--- CustomMenu:add(name, fn)
--- Method
--- Add a menu item. Refer to http://www.hammerspoon.org/docs/hs.menubar.html#setIcon for info
function obj:add(item)
    table.insert(self.menus, item)
end

--- CustomMenu:start()
--- Method
--- (re)start CustomMenu
---
function obj:start()
    self.menuItem = hs.menubar.new()
    self.menuItem:setIcon(self.spoonPath .. "/menuicon.pdf")
    self.menuItem:setMenu(function() return self.menus end)
end

--- CustomMenu:stop()
--- Method
--- (re)start CustomMenu
---
function obj:stop()
    self.menuItem:delete()
    self.menus = {}
end

return obj
