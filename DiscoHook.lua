local expect = require("cc.expect")
local expectVariable, expectField = expect.expect, expect.field
local WEBHOOK = {} -- READ ONLY, TRY NOT TO SAVE TO THIS IF YOU USE MULTIPLE INSTANCES.

---@returns WEBHOOK
---@param url string
function WEBHOOK.create(url)
    ---@class WEBHOOK
    local webhookClass = {
        url = url,
        lastMessage = 0,
        messages = {}
    }
    
    ---Send a message to the webhook, returning the messageId
    ---@param self WEBHOOK
    ---@param messageContent string|nil
    ---@param embedContent table|nil
    ---@return integer|nil sentMessageId
    function webhookClass.sendMessage(self, messageContent, embedContent)
        if not messageContent then
            expectVariable(3, embedContent, "table")
        elseif not embedContent then
            expectVariable(2, messageContent, "string")
        end
        local messageData = {}
        if messageContent then
            messageData.content = messageContent
        end
        if embedContent then
            messageData.embeds = {{}}
            messageData.embeds[1].title = embedContent.title and expectField(embedContent, "title", "string") or nil
            messageData.embeds[1].description = embedContent.description and expectField(embedContent, "description", "string") or nil
            messageData.embeds[1].url = embedContent.url and expectField(embedContent, "url", "string") or nil
            messageData.embeds[1].color = embedContent.color and expectField(embedContent, "color", "number") or nil
            messageData.embeds[1].image = embedContent.image and {url = expectField(embedContent, "image", "string")} or nil
            messageData.embeds[1].thumbnail = embedContent.thumbnail and {url = expectField(embedContent, "thumbnail", "string")} or nil
            messageData.embeds[1].username = embedContent.username and expectField(embedContent, "username", "string") or nil
            messageData.embeds[1].avatar_url = embedContent.avatar_url and expectField(embedContent, "avatar_url", "string") or nil
        end
        local lastMessageInfo, err = http.post(self.url.."?wait=true",
        textutils.serialiseJSON(
                messageData
            ),
            {
                ["Content-Type"] = "application/json"
            }
        )
        if lastMessageInfo then
            local lastMessageBody = lastMessageInfo.readAll()
            lastMessageInfo.close()

            local lastMessage = textutils.unserialiseJSON(lastMessageBody)
            
            if lastMessage and lastMessage.id then
                self.lastMessage = lastMessage.id
                table.insert(self.messages, self.lastMessage)
                return lastMessage.id
            else
                return nil
            end
        else
            return err
        end
    end

    ---Deletes message, defaults to last message sent
    ---@param self WEBHOOK
    ---@param messageId integer|string
    ---@return boolean success
    function webhookClass.deleteMessage(self, messageId)
        local response, err = http.request({url = self.url.."/messages/"..(messageId and messageId or self.lastMessage), method = "DELETE"})
        
        table.remove(self.messages, #self.messages)
        self.lastMessage = self.messages[#self.messages]
        if response then
            return true
        else
            return err
        end
    end

    ---Edit message, defaults to last message sent
    ---@param self WEBHOOK
    ---@param messageId integer|string|nil
    ---@param messageContent string|nil
    ---@param embedContent table|nil
    ---@return boolean success
    function webhookClass.editMessage(self, messageId, messageContent, embedContent)
        if not messageContent then
            expectVariable(3, embedContent, "table")
        elseif not embedContent then
            expectVariable(2, messageContent, "string")
        end
        local messageData = {}
        messageData.content = messageContent
        if embedContent then
            messageData.embeds = {{}}
            messageData.embeds[1].title = embedContent.title and expectField(embedContent, "title", "string") or nil
            messageData.embeds[1].description = embedContent.description and expectField(embedContent, "description", "string") or nil
            messageData.embeds[1].url = embedContent.url and expectField(embedContent, "url", "string") or nil
            messageData.embeds[1].color = embedContent.color and expectField(embedContent, "color", "number") or nil
            messageData.embeds[1].image = embedContent.image and {url = expectField(embedContent, "image", "string")} or nil
            messageData.embeds[1].thumbnail = embedContent.thumbnail and {url = expectField(embedContent, "thumbnail", "string")} or nil
            messageData.embeds[1].username = embedContent.username and expectField(embedContent, "username", "string") or nil
            messageData.embeds[1].avatar_url = embedContent.avatar_url and expectField(embedContent, "avatar_url", "string") or nil
        else
            messageData.embeds = {}
        end
        local response, err = http.request(
            {
                url = self.url.."/messages/"..(messageId and messageId or self.lastMessage), 
                method = "PATCH",
                body = textutils.serialiseJSON(
                        messageData
                    ),
                headers = {
                    ["Content-Type"] = "application/json"
                }
                
            }
        )
        
        if response then
            return true
        else
            return err
        end
    end

    ---Get a message, returns table with all message data, defaults to lastmessage
    ---@param self WEBHOOK
    ---@param messageId integer|string
    ---@return table|nil lastMessageData
    function webhookClass.getMessage(self, messageId)
        local lastMessageInfo, err = http.get(self.url.."/messages/"..(messageId and messageId or self.lastMessage))
        if lastMessageInfo then
            local lastMessageBody = lastMessageInfo.readAll()
            lastMessageInfo.close()

            local lastMessage = textutils.unserialiseJSON(lastMessageBody)
            
            if lastMessage and lastMessage.id then
                return lastMessage
            else
                return nil
            end
        else
            return err
        end
    end

    return webhookClass
end


return WEBHOOK