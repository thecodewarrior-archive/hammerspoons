hs.loadSpoon("WacomScroll")
hs.loadSpoon("CustomMenu")
--spoon.WacomScroll.debugEnabled = true
spoon.WacomScroll:start()

local menu = spoon.CustomMenu

require "imgur"
require "hastebin"
require "deathToApps"

spoon.CustomMenu:start()
