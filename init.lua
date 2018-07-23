S = require "settings"
hs.loadSpoon("WacomScroll")
hs.loadSpoon("CustomMenu")
--spoon.WacomScroll.debugEnabled = true
spoon.WacomScroll:start()

local menu = spoon.CustomMenu

menu:add(require "imgur")
menu:add(require "hastebin")
menu:add(require "deathToApps")
menu:add({title="Middle Mouse to scroll", checked=S["middleMouseScroll"], fn=function(mods, item)
    item.checked = not item.checked
    S["middleMouseScroll"] = item.checked
    spoon.WacomScroll.enabled = item.checked
end})
spoon.CustomMenu:start()
