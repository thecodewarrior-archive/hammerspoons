S = require "settings"
hs.loadSpoon("WacomScroll")
hs.loadSpoon("CustomMenu")
--spoon.WacomScroll.debugEnabled = true
spoon.WacomScroll:start()

local menu = spoon.CustomMenu

menu:add(require "imgur")
menu:add(require "hastebin")
menu:add(require "deathToApps")
spoon.WacomScroll.enabled = S["middleMouseScrollEnabled"]
spoon.WacomScroll.exclusions = S["middleMouseExclusions"] or {}
menu:add(function()
    local app = hs.application.frontmostApplication()
    local excluded = spoon.WacomScroll.exclusions[app:bundleID()]

    return {title="Middle Mouse to scroll", menu={
        {title="Enabled", checked=spoon.WacomScroll.enabled, fn=function(mods, item)
            item.checked = not item.checked
            S["middleMouseScrollEnabled"] = item.checked
            spoon.WacomScroll.enabled = item.checked
        end},
        {title="Disable in " .. app:name(), checked=excluded, fn=function(mods, item)
            if excluded then
                spoon.WacomScroll.exclusions[app:bundleID()] = nil
            else
                spoon.WacomScroll.exclusions[app:bundleID()] = true
            end
            S["middleMouseExclusions"] = spoon.WacomScroll.exclusions
        end}
    }}
end)
spoon.CustomMenu:start()
