--[[
  DiscordHook by HydroNitrogen
  Licenced under MIT
  Copyright (c) 2019 Wendelstein7 (a.k.a. HydroNitrogen)
  See: https://github.com/Wendelstein7/DiscordHook-CC
]]--

local DiscordHook = {
  ["name"] = "DiscordHook",
  ["author"] = "HydroNitrogen",
  ["date"] = "2019-01-30",
  ["version"] = 1,
  ["url"] = "https://github.com/Wendelstein7/DiscordHook-CC"
}

local function expect(func, arg, n, expected)
  if type(arg) ~= expected then
    return error(("%s: bad argument #%d (expected %s, got %s)"):format(func, n, expected, type(arg)), 2)
  end
end

function http.patch(url, body, headers)
  headers = headers or {}
  headers["Content-Type"] = headers["Content-Type"] or "application/json"

  -- Make the PATCH request
  local response, err = http.request({
      url = url,
      method = "PATCH",
      headers = headers,
      body = body,
      timeout = 2
  })

  if response then
      return true, err
  else
      return false, err
  end
end

local function getMessage(url)
  -- Construct the URL to fetch the message
  local apiUrl = url
  
  -- Prepare the headers (authentication may be required in some cases)
  local headers = {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bot " .. "YOUR_BOT_TOKEN" -- Optional, if needed
  }

  -- Send the GET request to fetch the message
  local response, err = http.get(apiUrl, headers)

  -- Check if the request was successful
  if response then
    local data = response.readAll() -- Read the entire response body
    response.close()  -- Always close the response after reading

    -- Parse the response JSON (this is the message data)
    local messageData = textutils.unserializeJSON(data)

    -- Return the message data
    return messageData
  else
    -- If the request failed, print the error
    print("Error fetching message: " .. (err or "Unknown error"))
    return nil
  end
end


local function send(url, data, headers)
  local request, message = http.post(url, data, headers)
  print(message)
  if not request then
    return false
  end
  return true
end


function DiscordHook.createWebhook(url)
  expect("createWebhook", url, 1, "string")
  local success, message = http.checkURL(url)
  if not success then
    return false, "createWebhook: Can't access invalid url - " .. message
  else
    local _ = {}
    _.url = url
    _.sentMessages = 0

    function _.send(message, username, avatar)
      expect("send", message, 1, "string")
      local data = "content=" .. textutils.urlEncode(message)
      if username then
        expect("send", username, 2, "string")
        data = data .. "&username=" .. textutils.urlEncode(username)
      end
      if avatar then
        expect("send", avatar, 3, "string")
        data = data .. "&avatar_url=" .. textutils.urlEncode(avatar)
      end

      
      local success = send(_.url, data, { ["Content-Type"] = "application/x-www-form-urlencoded", ["Source"] = "Minecraft/ComputerCraft/DiscordHook" })
      if success then _.sentMessages = _.sentMessages + 1 end
      return success
    end
    function _.edit(messageId, message, username, avatar)
      expect("edit", messageId, 1, "string")
      expect("edit", message, 2, "string")
  
      -- Construct the URL for editing the specific message
      local url = _.url.."/messages/"..messageId
  
      -- Build the JSON payload
      local data = { content = message }
      if username then
          expect("edit", username, 3, "string")
          data.username = username
      end
      if avatar then
          expect("edit", avatar, 4, "string")
          data.avatar_url = avatar
      end
  
      -- Convert the payload to JSON
      local jsonPayload = textutils.serializeJSON(data)
  
      -- Send the PATCH request
      local success = http.patch(url, jsonPayload, {
          ["Content-Type"] = "application/json",
          ["Source"] = "Minecraft/ComputerCraft/DiscordHook"
      })
  
      if success then _.sentMessages = _.sentMessages + 1 end
      return success
  end

    function _.get(messageId)
      expect("get", messageId, 1, "string")

      local url = _.url.."/messages/"..messageId

      return getMessage(url).content
    end

    function _.sendJSON(json)
      expect("sendJSON", json, 1, "string")

      local success = send(_.url, json, { ["Content-Type"] = "application/json", ["Source"] = "Minecraft/ComputerCraft/DiscordHook" })
      if success then _.sentMessages = _.sentMessages + 1 end
      return success
    end

    function _.sendEmbed(message, title, description, link, colour, image_large, image_thumb, username, avatar)
      expect("sendEmbed", message, 1, "string")
      local data = { ["content"] = message, ["embeds"] = { {} } }

      if title then
        expect("sendEmbed", title, 2, "string")
        data["embeds"][1]["title"] = title
      end
      if description then
        expect("sendEmbed", description, 3, "string")
        data["embeds"][1]["description"] = description
      end
      if link then
        expect("sendEmbed", link, 4, "string")
        data["embeds"][1]["url"] = link
      end
      if colour then
        expect("sendEmbed", colour, 5, "number")
        data["embeds"][1]["color"] = colour
      end
      if image_large then
        expect("sendEmbed", image_large, 6, "string")
        data["embeds"][1]["image"] = { ["url"] = image_large }
      end
      if image_thumb then
        expect("sendEmbed", image_thumb, 7, "string")
        data["embeds"][1]["thumbnail"] = { ["url"] = image_thumb }
      end
      if username then
        expect("sendEmbed", username, 8, "string")
        data["username"] = username
      end
      if avatar then
        expect("sendEmbed", avatar, 9, "string")
        data["avatar_url"] = avatar
      end
      
      local success = send(_.url, textutils.serializeJSON(data), { ["Content-Type"] = "application/json", ["Source"] = "Minecraft/ComputerCraft/DiscordHook" })
      if success then _.sentMessages = _.sentMessages + 1 end
      return success
    end

    return true, _
  end
end

return DiscordHook
