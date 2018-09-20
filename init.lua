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
local hypercombo = require "hypercombo"
local panic = require "panic"

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
        {title=app:name(), checked=excluded, fn=function(mods, item)
            if excluded then
                wacomScroll.exclusions[app:bundleID()] = nil
            else
                wacomScroll.exclusions[app:bundleID()] = true
            end
            S["middleMouseExclusions"] = wacomScroll.exclusions
        end}
    }}
end)
menu:add(panic.menu)

hyper:start()
menu:start()
popup:start()
wacomScroll:start()
