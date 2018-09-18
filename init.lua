S = require "settings"
hs.loadSpoon("WacomScroll")
hs.loadSpoon("CustomMenu")

local wacomScroll = spoon.WacomScroll
local menu = spoon.CustomMenu

wacomScroll.enabled = S["middleMouseScrollEnabled"]
wacomScroll.exclusions = S["middleMouseExclusions"] or {}

_G.hyper = require "hyperkey"
local popup = require "popupMenu"
local imgur = require "imgur"
local hastebin = require "hastebin"
local trimIndent = require "trimIndent"
local deathToApps = require "deathToApps"

popup:add(imgur.choice)
popup:add(hastebin.choice)
popup:add(trimIndent.choice)

menu:add(imgur.menu)
menu:add(hastebin.menu)
menu:add(trimIndent.menu)
menu:add(deathToApps)
menu:add(function()
    local app = hs.application.frontmostApplication()
    local excluded = wacomScroll.exclusions[app:bundleID()]

    return {title="Middle Mouse to scroll", menu={
        {title="Enabled", checked=wacomScroll.enabled, fn=function(mods, item)
            item.checked = not item.checked
            S["middleMouseScrollEnabled"] = item.checked
            wacomScroll.enabled = item.checked
        end},
        {title="Disable in " .. app:name(), checked=excluded, fn=function(mods, item)
            if excluded then
                wacomScroll.exclusions[app:bundleID()] = nil
            else
                wacomScroll.exclusions[app:bundleID()] = true
            end
            S["middleMouseExclusions"] = wacomScroll.exclusions
        end}
    }}
end)

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
        print("Hyper-" .. hs.keycodes.map[keyEvent:getKeyCode()] .. " down")
        keyEvent:setFlags({ cmd = true, alt = true, shift = true, ctrl = true })
    end
end

function Hyperkey:keyUp(keyEvent)
    if self.event and self:isKey(keyEvent) then
        self.event = nil
        print("Hyper-" .. hs.keycodes.map[keyEvent:getKeyCode()] .. " up")
        keyEvent:setFlags({ cmd = true, alt = true, shift = true, ctrl = true })
    end
end

function Hyperkey:modifiersChanged()
    if self.event and not self:areModifiersPressed() then
        print("Hyper-" .. self.event:getCharacters() .. " up")
        self.event:setType(hs.eventtap.event.types.keyUp)
        self.event:setFlags({ cmd = true, alt = true, shift = true, ctrl = true })
        -- self.event:post()
        self.event = nil
    end
end

hyper:addShortcut({
    mods = { "hypershift" },
    key = hs.keycodes.map.space,
    pressedfn = function() 
        popup:openMenu()
    end
})

hyper:start()
menu:start()
popup:start()
wacomScroll:start()
