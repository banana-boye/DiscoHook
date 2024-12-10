local expect = require("cc.expect")
local expectVariable, expectField = expect.expect, expect.field
local WEBHOOK = {} -- READ ONLY, TRY NOT TO SAVE TO THIS IF YOU USE MULTIPLE INSTANCES.

---@returns WEBHOOK
---@param url string
function WEBHOOK.create(url)
    ---@class WEBHOOK
    local webhookClass = {
        url = url,
        lastMessage = 0
    }
    function webhookClass.getMessageId(self)
        local response, err = http.get(self.url, {
            ["Content-Type"] = "application/json"
        })

        if response then
            print(response.readAll())
            response.close()
            return true
        else
            return false
        end
    end
    
    function webhookClass.sendMessage(self, messageContent)
        local response, err = http.post(self.url,
        textutils.serialiseJSON(
            {content = messageContent}
        ),
        {
            ["Content-Type"] = "application/json"
        }
    )

        if response then
            -- Read and parse the response
            local responseBody = response.readAll()
            response.close()

            local responseData = textutils.unserialiseJSON(responseBody)
            if responseData and responseData.id then
                return responseData.id -- Return the message ID
            else
                return nil, "Failed to get message ID"
            end
        else
            return nil, err -- Return the error if the request failed
        end
    end

    return webhookClass
end


return WEBHOOK