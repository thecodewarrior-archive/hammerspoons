--- === EjectShortcut ===

local obj={}
obj.__index = obj

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
obj.spoonPath = script_path()

-- Metadata
obj.name = "EjectShortcut"
obj.version = "1.0"
obj.author = "TheCodeWarrior <pierce@plasticcow.com.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.keyHandler = nil

function obj:init()
    self.keyHandler = hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
        -- http://www.hammerspoon.org/docs/hs.eventtap.event.html#systemKey
        event = event:systemKey()
        -- http://stackoverflow.com/a/1252776/1521064
        local next = next
        -- Check empty table
        local shouldCancel = false
        if next(event) then
            if event.key == 'EJECT' and event.down then
                print('This is my EJECT key event')
                shouldCancel = true
            end
        end
        return shouldCancel
    end)
end

--- EjectShortcut:start()
--- Method
--- (re)start EjectShortcut
---
function obj:start()
    self.keyHandler:start()
end

--- EjectShortcut:stop()
--- Method
--- (re)start EjectShortcut
---
function obj:stop()
    self.keyHandler:stop()
end

return obj
