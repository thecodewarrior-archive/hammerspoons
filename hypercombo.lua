hyperkey = {}
hyperkey.pressed = false
hyper:addShortcut(hyperkey)

Hyperkey = {}
Hyperkey.__index = Hyperkey
setmetatable(hyperkey, Hyperkey)

function Hyperkey:areModifiersPressed() 
    return self.hyperkeys.modifiers.hypershift
end

function Hyperkey:isKey(keyEvent)

    return not (
    keyEvent:getKeyCode() == hs.keycodes.map.shift or
    keyEvent:getKeyCode() == hs.keycodes.map.cmd   or
    keyEvent:getKeyCode() == hs.keycodes.map.alt   or
    keyEvent:getKeyCode() == hs.keycodes.map.ctrl  or

    keyEvent:getKeyCode() == hs.keycodes.map.rightshift or
    keyEvent:getKeyCode() == hs.keycodes.map.rightcmd   or
    keyEvent:getKeyCode() == hs.keycodes.map.rightalt   or
    keyEvent:getKeyCode() == hs.keycodes.map.rightctrl  or

    keyEvent:getKeyCode() == hs.keycodes.map.fn
    )
end

function Hyperkey:keyDown(keyEvent)
    if self:areModifiersPressed() and self:isKey(keyEvent) then
        self.event = keyEvent:copy()
        -- print("Hyper-" .. hs.keycodes.map[keyEvent:getKeyCode()] .. " down")
        keyEvent:setFlags({ cmd = true, alt = true, shift = true, ctrl = true })
    end
end

function Hyperkey:keyUp(keyEvent)
    if self.event and self:isKey(keyEvent) then
        self.event = nil
        -- print("Hyper-" .. hs.keycodes.map[keyEvent:getKeyCode()] .. " up")
        keyEvent:setFlags({ cmd = true, alt = true, shift = true, ctrl = true })
    end
end

function Hyperkey:modifiersChanged()
    if self.event and not self:areModifiersPressed() then
        -- print("Hyper-" .. self.event:getCharacters() .. " up")
        self.event:setType(hs.eventtap.event.types.keyUp)
        self.event:setFlags({ cmd = true, alt = true, shift = true, ctrl = true })
        -- self.event:post()
        self.event = nil
    end
end
