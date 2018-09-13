local activityFile = io.open(os.getenv("HOME") .. "/activity.log", "a")
local currentStart = hs.settings.get("activity.currentStart")
local lastTime = hs.settings.get("activity.lastTime")
local timeout = 5*60
print(hs.inspect(activityFile))

function SecondsToClock(seconds) -- https://gist.github.com/jesseadams/791673
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end
local function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end
local eventTypesInverse = table_invert(hs.eventtap.event.types)

local function endSession()
    local line = os.date("%x - %a %X", lastTime) .. " } Session ended\n"
    if currentStart then
        line = line .. " - duration: " .. SecondsToClock(lastTime - currentStart)
    end
    print(line)
    activityFile:write(line)
    activityFile:flush()
    lastTime = nil
    currentStart = nil
    hs.settings.clear("activity.lastTime")
    hs.settings.clear("activity.currentStart")
end
local timeoutDelay = hs.timer.delayed.new(timeout, endSession)
if lastTime then
    endSession()
end

local function startSession(e) 
    local thisTime = os.time()
    if not lastTime then
        currentStart = thisTime
        hs.settings.setDate("activity.currentStart", currentStart)

        local line = os.date("%x - %a %X", thisTime) .. ": Session started by a " .. eventTypesInverse[e:getType()] .. " event\n"
        print(line)
        activityFile:write(line)
        activityFile:flush()
    end
    timeoutDelay:start()

    lastTime = thisTime
    hs.settings.setDate("activity.lastTime", lastTime)
end

local activityListener = hs.eventtap.new({
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.rightMouseDown,
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.flagsChanged,
    hs.eventtap.event.types.otherMouseDown
}, startSession)
activityListener:start()
