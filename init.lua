hs.loadSpoon("WacomScroll")
hs.loadSpoon("CustomMenu")
--spoon.WacomScroll.debugEnabled = true
spoon.WacomScroll:start()

local imgurClientID = "ea0ec39d48f4030"
local menu = spoon.CustomMenu

menu:add({title="Upload to Imgur", fn=function()
    local image = hs.pasteboard.readImage()

    if image then
        local tempfile = "/tmp/tmp.png"
        image:saveToFile(tempfile)
        local b64 = hs.execute("base64 -i "..tempfile)
        b64 = hs.http.encodeForQuery(string.gsub(b64, "\n", ""))

        local url = "https://api.imgur.com/3/image"
        local headers = {
            Authorization = "Client-ID " .. imgurClientID
        }
        local payload = "type='base64'&image=" .. b64

        hs.http.asyncPost(url, payload, headers, function(status, body, headers)
            print(status, headers, body)
            if status == 200 then
                local response = hs.json.decode(body)
                local imageURL = response.data.link
                hs.urlevent.openURLWithBundle(imageURL, hs.urlevent.getDefaultHandler("http"))
            end
        end)
    end

end})

menu:add({title="Upload to Hastebin", fn=function()
    local text = hs.pasteboard.readString()

    if text then
        local url = "https://hastebin.com/documents"
        local headers = {}
        local payload = text

        hs.http.asyncPost(url, payload, headers, function(status, body, headers)
            print(status, headers, body)
            if status == 200 then
                local response = hs.json.decode(body)
                local imageURL = "https://hastebin.com/" .. response.key
                hs.urlevent.openURLWithBundle(imageURL, hs.urlevent.getDefaultHandler("http"))
            end
        end)
    end

end})

spoon.CustomMenu:start()
