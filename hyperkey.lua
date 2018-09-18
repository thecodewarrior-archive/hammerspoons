local obj={}
obj.__index = obj
local Shortcut = {}
Shortcut.__index = Shortcut

local lCtrl  = 1 << 0
local lShift = 1 << 1
local rShift = 1 << 2
local lCmd   = 1 << 3
local rCmd   = 1 << 4
local lAlt   = 1 << 5
local rAlt   = 1 << 6
local rCtrl  = 1 << 13
local fn     = 1 << 23
local anyCtrl = lCtrl | rCtrl
local anyCmd = lCmd | rCmd
local anyShift = lShift | rShift
local anyAlt = lAlt | rAlt

obj.modifiers = {
    cmd = false,
    ctrl = false,
    shift = false,
    alt = false,
    hypercmd = false, 
    hyperctrl = false,
    hypershift = false,
    hyperalt = false,
    fn = false
}

obj.cmd   = false
obj.ctrl  = false
obj.shift = false
obj.alt   = false
obj.fn    = false
obj.shortcuts = {}

function obj:start()
    self.flagsChanged = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function (event)
        flags = event:getFlags()

        self.modifiers.cmd = flags.cmd
        self.modifiers.ctrl = flags.ctrl
        self.modifiers.shift = flags.shift
        self.modifiers.alt = flags.alt
        self.modifiers.fn = flags.fn

        if not flags.ctrl then self.modifiers.hyperctrl = false end
        if not flags.shift then self.modifiers.hypershift = false end
        if not flags.cmd then self.modifiers.hypercmd = false end
        if not flags.alt then self.modifiers.hyperalt = false end

        flags = event:rawFlags()

        self.modifiers.hyperctrl  = self.modifiers.hyperctrl  or (flags & lCtrl  ~= 0 and flags & rCtrl  ~= 0)
        self.modifiers.hypershift = self.modifiers.hypershift or (flags & lShift ~= 0 and flags & rShift ~= 0)
        self.modifiers.hypercmd   = self.modifiers.hypercmd   or (flags & lCmd   ~= 0 and flags & rCmd   ~= 0)
        self.modifiers.hyperalt   = self.modifiers.hyperalt   or (flags & lAlt   ~= 0 and flags & rAlt   ~= 0)

        self.ctrl  = self.modifiers.hyperctrl
        self.shift = self.modifiers.hypershift
        self.cmd   = self.modifiers.hypercmd
        self.alt   = self.modifiers.hyperalt
        self.fn    = self.modifiers.fn

        for i, shortcut in ipairs(self.shortcuts) do
            shortcut:modifiersChanged()
        end
    end)
    self.flagsChanged:start()

    self.keyDown = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function (event)
        for i, shortcut in ipairs(self.shortcuts) do
            shortcut:keyDown(event)
        end
    end)
    self.keyDown:start()

    self.keyUp = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function (event)
        for i, shortcut in ipairs(self.shortcuts) do
            shortcut:keyUp(event)
        end
    end)
    self.keyUp:start()
end

-- shortcut is in the format { mods: <mod string>, key: <keycode>, pressedfn: <pressed>, releasedfn: <released>? }
-- shortcut mods is a list containing any number of `cmd`, `ctrl`, `shift`, `alt`, `hypercmd`, `hyperctrl`, `hypershift`, `hyperalt`, and `fn`
-- Incompatible shortcuts so far:
--   hypershift + EIOPQRTU 
--   hyperalt + ADFGHJKLS
function obj:addShortcut(shortcut) 
    setmetatable(shortcut, Shortcut)
    shortcut.hyperkeys = self
    table.insert(self.shortcuts, shortcut)
end

function Shortcut:areModifiersPressed() 
    for i, mod in ipairs(self.mods) do
        if self.hyperkeys.modifiers[mod] == nil then
            print("unknown modifier" .. hs.insepect(mod))
            return false
        elseif self.hyperkeys.modifiers[mod] == false then
            return false
        end
    end
    return true
end

function Shortcut:isKey(keyEvent)
    return keyEvent:getKeyCode() == self.key
end

function Shortcut:keyDown(keyEvent)
    if self:isKey(keyEvent) and self:areModifiersPressed() then
        self.pressed = true
        if self.pressedfn then
            self.pressedfn()
        end
    end
end

function Shortcut:keyUp(keyEvent)
    if self:isKey(keyEvent) and self.pressed then
        self.pressed = false
        if self.releasedfn then
            self.releasedfn()
        end
    end
end

function Shortcut:modifiersChanged()
    if self.pressed and not self:areModifiersPressed() then
        self.pressed = false
        if self.releasedfn then
            self.releasedfn()
        end
    end
end

-- local function numberToBinStr(x)
-- 	ret=""
-- 	while x~=1 and x~=0 do
-- 		ret=tostring(x%2)..ret
-- 		x=math.modf(x/2)
-- 	end
-- 	ret=tostring(x)..ret
-- 	return ret
-- end
-- 
-- local function lpad(str, len, char)
--     if char == nil then char = ' ' end
--     return string.rep(char, len - #str) .. str
-- end

return obj
