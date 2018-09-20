local obj = {}
obj.__index = obj
obj.panics = S["panicApps"] or {}

local function hideUnHide()
    local allApps = hs.application.runningApplications()
    local anyOpen = false
    for i, app in ipairs(allApps) do
        if obj.panics[app:bundleID()] and not app:isHidden() then
            anyOpen = true
        end
    end
    for i, app in ipairs(allApps) do
        if obj.panics[app:bundleID()] then
            if anyOpen then
                app:hide()
            else
                app:unhide()
            end
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

local function toggle(app)
    if obj.panics[app:bundleID()] then
        print("Toggle " .. app:bundleID() .. " off")
        obj.panics[app:bundleID()] = false
    else
        print("Toggle " .. app:bundleID() .. " on")
        obj.panics[app:bundleID()] = true
    end
    S["panicApps"] = obj.panics
end

local function menuFor(app)
    local isPanic = obj.panics[app:bundleID()]
    return {
        title=app:name(),
        checked=isPanic,
        fn=function(mods, item)
            toggle(app)
        end
    }
end

obj.clickHandler = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function()
    if obj.isClicking then
        local app = obj:applicationUnderMouse()
        print("selected " .. app:bundleID())
        obj.isClicking = false
        toggle(app)
    end
end)
obj.clickHandler:start()

obj.menu = function()
    local front = hs.application.frontmostApplication()
    local menu = {
        {
            title="Click...",
            checked = false,
            fn=function(mods, item)
                print("start selecting")
                obj.isClicking = true
            end
        },
        menuFor(front)
    }

    for i, app in ipairs(hs.application.runningApplications()) do
        if obj.panics[app:bundleID()] and app:bundleID() ~= front:bundleID() then
            table.insert(menu, menuFor(app))
        end
    end

    return {title="Close", menu=menu}
end


hyper:addShortcut({
    mods = { "hypershift" },
    key = hs.keycodes.map.f,
    pressedfn = function() 
        hideUnHide()
    end
})

return obj
