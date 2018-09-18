--- === WacomScroll ===

local obj={}
obj.__index = obj

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
print("loaded WacomScroll")
obj.spoonPath = script_path()

-- Metadata
obj.name = "WacomScroll"
obj.version = "1.0"
obj.author = "TheCodeWarrior <pierce@plasticcow.com.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.refreshRate = 60
obj.iconSize = 30
obj.mouseButton = 2
obj.scrollSpeed = 7
obj.enabled = true
obj.exclusions = {}

obj.cursorImage = nil
obj.cursorImageX = nil
obj.cursorImageY = nil
obj.cursorImageXY = nil

obj.icon = nil
obj.currentStartPosition = nil

obj.mouseDown = nil
obj.mouseUp = nil
obj.mouseMove = nil

function obj:init()
    print("Initializing WacomScroll")

    self.cursorImage = hs.image.imageFromPath(self.spoonPath .. "/cursor.png")
    self.cursorImageX = hs.image.imageFromPath(self.spoonPath .. "/cursor-x.png")
    self.cursorImageY = hs.image.imageFromPath(self.spoonPath .. "/cursor-y.png")
    self.cursorImageXY = hs.image.imageFromPath(self.spoonPath .. "/cursor-xy.png")

    self.mouseDown = hs.eventtap.new({
        hs.eventtap.event.types.otherMouseDown
        -- hs.eventtap.event.types.rightMouseDown,
        -- hs.eventtap.event.types.leftMouseDown
    }, function(e)
        local button = e:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
        -- print("button pressed: ", button)
        local excluded = self.exclusions[self:applicationUnderMouse():bundleID()]
        if excluded then
            print("Application " .. self:applicationUnderMouse():bundleID() .. " is on the exclusion list")
        end
        if self.enabled and button == self.mouseButton and not excluded then
            -- print("Starting scrolling")
            self:startScrolling()
            return true, {}
        end
        return false, {}
    end)
    self.mouseUp = hs.eventtap.new({
        hs.eventtap.event.types.otherMouseUp
        -- hs.eventtap.event.types.rightMouseUp,
        -- hs.eventtap.event.types.leftMouseUp
    }, function(e)
        local button = e:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
        -- print("button released: ", button)
        if button == self.mouseButton and self.currentStartPosition then
            -- print("Stopping scrolling")
            self:stopScrolling()
            return true, {}
        end
        return false, {}
    end)
end

--- WacomScroll:start()
--- Method
--- (re)start WacomScroll
---
function obj:start()
    print("Starting WacomScroll")
    self:clear()
    self.mouseDown:start()
    self.mouseUp:start()
    if self.mouseMove then
        self.mouseMove:stop()
    end
    self.mouseMove = hs.timer.new(1/self.refreshRate, function()
        self:updateScrolling()
    end)
    self.mouseMove:start()
end

--- WacomScroll:stop()
--- Method
--- (re)start WacomScroll
---
function obj:stop()
    print("Stopping WacomScroll")
    self:clear()
    self.mouseDown:stop()
    self.mouseUp:stop()
    if self.mouseMove then
        self.mouseMove:stop()
    end
end

function obj:clear()
    -- print("Clearing WacomScroll icon and start position")
    if self.icon then
        self.icon:delete()
        self.icon = nil
    end
    self.currentStartPosition = nil
end

function obj:startScrolling()
    -- print("Starting WacomScroll scrolling")
    self:clear()
    local pos = hs.mouse.getAbsolutePosition()
    self.currentStartPosition = pos
    self.icon = hs.drawing.image(hs.geometry(pos.x-self.iconSize/2, pos.y-self.iconSize/2, self.iconSize, self.iconSize), self.cursorImage)
    self.icon:show()
end

function obj:stopScrolling()
    -- print("Stopping WacomScroll scrolling")
    obj:clear()
end

function obj:updateScrolling()
    if self.currentStartPosition then
        -- print("WacomScroll scroll update")
        local currentPos = hs.mouse.getAbsolutePosition()
        local offset = {
            x=self.currentStartPosition.x - currentPos.x,
            y=self.currentStartPosition.y - currentPos.y
        }
        local absOffset = {x=math.abs(offset.x), y=math.abs(offset.y)}
        if absOffset.x > 2*absOffset.y then
            -- print("WacomScroll snapped to x axis")
            offset.y = 0
            absOffset.y = 0
            self.icon:setImage(self.cursorImageX)
        elseif absOffset.y > 2*absOffset.x then
            -- print("WacomScroll snapped to y axis")
            offset.x = 0
            absOffset.x = 0
            self.icon:setImage(self.cursorImageY)
        -- else
            -- if absOffset.x < self.iconSize and absOffset.y < self.iconSize then 
                -- offset = {x=0, y=0}
                -- absOffset = {x=0, y=0}
            -- end
            -- self.icon:setImage(self.cursorImageXY)
        end
        if absOffset.x > self.iconSize/2 or absOffset.y > self.iconSize/2 then
            -- print("WacomScroll threshold breached. scrolling")
            local scrollAmount = {
                math.floor(offset.x/self.refreshRate * self.scrollSpeed + 0.5),
                math.floor(offset.y/self.refreshRate * self.scrollSpeed + 0.5)
            }
            -- print("x: " .. scrollAmount[1] .. " y: " .. scrollAmount[2])
            hs.mouse.setAbsolutePosition(self.currentStartPosition)
            local scroll = hs.eventtap.event.newScrollEvent(scrollAmount,{},'pixel')
            scroll:post()
            hs.mouse.setAbsolutePosition(currentPos)
        else
            -- print("WacomScroll threshold not met. setting image to blank image")
            self.icon:setImage(self.cursorImage)
        end
    end
end

function obj:applicationUnderMouse()
    -- print("Getting app under mouse")
    -- Invoke `hs.application` because `hs.window.orderedWindows()` doesn't do it
    -- and breaks itself
    local _ = hs.application

    local my_pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
    local my_screen = hs.mouse.getCurrentScreen()

    -- print("Got mouse pos and mouse screen")
    local window = hs.fnutils.find(hs.window.orderedWindows(), function(w)
        return my_screen == w:screen() and my_pos:inside(w:frame())
    end)
    local app
    if window == nil then
        -- print("No window under cursor")
        app = hs.application.frontmostApplication()
    else 
        -- print("Got window under cursor")
        app = window:application()
    end
    return app
end

return obj
