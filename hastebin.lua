return {title="Upload to Hastebin", fn=function()
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

end}
