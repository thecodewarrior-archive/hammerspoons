local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local p = script_path()

local killList = {}

local function killApp(name, bundleID)
    killList[bundleID] = true
    local table = { title = name, checked=true }
    table.fn = function(mods, item)
        if killList[bundleID] then
            killList[bundleID] = false
            table.checked = false
        else 
            killList[bundleID] = true
            table.checked = true
        end
    end
    return table
end

local apps = {
    killApp("iTunes", 'com.apple.iTunes'),
    killApp("Photos", 'com.apple.Photos')
}

local circleSlashImage = hs.image.imageFromPath(p .. '/circle-slash.png')

spoon.CustomMenu:add({title="Kill On Launch", menu=apps})

local watcher = hs.application.watcher.new(function(name, eventType, app)
    if eventType == hs.application.watcher.launching and killList[app:bundleID()] then
        print("Killing " .. app:bundleID())
        local screenRect = hs.screen.primaryScreen():frame()
        local center = {x=screenRect.x2-32-5, y=screenRect.y1+32+5}
        local appIcon = hs.drawing.appImage(hs.geometry(center.x-20, center.y-20, 40, 40), app:bundleID())
        local circleSlash = hs.drawing.image(hs.geometry(center.x-32, center.y-32, 64, 64), circleSlashImage)
        appIcon:show()
        circleSlash:show()

        local isBright = true
        circleSlash:setAlpha(0.9)
        local flashTimer = hs.timer.doEvery(0.5, function()
            isBright = not isBright
            if isBright then
                circleSlash:setAlpha(0.9)
            else
                circleSlash:setAlpha(0.5)
            end
        end)

        hs.timer.doAfter(4, function()
            flashTimer:stop()
            appIcon:delete()
            circleSlash:delete()
        end)
        app:kill9()
    end
end)
watcher:start()

