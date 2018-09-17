S = require "settings"
hs.loadSpoon("WacomScroll")
hs.loadSpoon("CustomMenu")

local wacomScroll = spoon.WacomScroll
local menu = spoon.CustomMenu

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

hyper:start()
wacomScroll.enabled = S["middleMouseScrollEnabled"]
wacomScroll.exclusions = S["middleMouseExclusions"] or {}
wacomScroll:start()
menu:start()
popup:start()
