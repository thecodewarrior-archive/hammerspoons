local imgurClientID = "ea0ec39d48f4030"

local obj = {}
obj.__index = obj
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
obj.choiceIcon = hs.image.imageFromPath(script_path() .. "/hastebin-icon.png")

local function formatSize(size)
    if size > 1000000000 then
        return string.format("%.1f GB", size/1000000000.0)
    elseif size > 1000000 then
        return string.format("%.1f MB", size/1000000.0)
    elseif size > 1000 then
        return string.format("%.1f KB", size/1000.0)
    else
        return string.format("%d Bytes", size)
    end
end

function obj:init()
    self.menu = function()
        return {
            title="Upload to Imgur",
            fn=function()
                self:upload()
            end,
            disabled = not hs.pasteboard.readImage() 
        }
    end

    self.choice = function()
        print("Creating imgur choices")
        local image = hs.pasteboard.readImage()
        if image then
            local tempfile = "/tmp/tmp.png"
            image:saveToFile(tempfile)
            local size = hs.fs.attributes(tempfile, "size")

            print("Image in clipboard, returning choice")
            local size = image:size()
            return {
                {
                    text = "Upload copied image to imgur",
                    subText = size.w .. "×" .. size.h .. " - " .. formatSize(size),
                    image = image,
                    fire = function()
                        self:upload()
                    end
                }
            }
        end
        print("No image in clipboard, returning empty table")
        return {}
    end
end

function obj:upload() 
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
                hs.pasteboard.setContents(imageURL)
            end
        end)
    end
end
obj:init()

return obj
