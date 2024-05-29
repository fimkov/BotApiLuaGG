json = require("json")

Bot = {
    BotInfo = {
        token = "",
        offset = 0,
        handlers = {}
    },

    updates = {
        ---@return table | nil
        getUpdates = function()
            local url = Bot.base_url .. "getUpdates"
            local params = "offset=" .. Bot.BotInfo["offset"] .. "&timeout=60&allowed_updates=[\"message\",\"edited_message\",\"callback_query\"]"
    
            local response = gg.makeRequest(url, {["Content-Type"] = "application/x-www-form-urlencoded"}, params)
    
            if response.code == 200 then
                local updates = json.decode(response.content)
                if updates and updates.ok then
                    return updates.result
                else
                    return nil
                end
            else
                return nil
            end
        end
    },

    handlers = {
        register_handler = function(handler)
            table.insert(Bot.BotInfo["handlers"], handler)
        end
    },

    ---@param token string
    ---@return table | string
    create = function(token)
        Bot.BotInfo["token"] = token
        Bot.base_url = "https://api.telegram.org/bot" .. token .. "/"
        return Bot
    end,

    ---@return table | nil
    ---@param chat_id number
    ---@param text string
    ---@param parse_mode string
    ---@param message_thread_id number | nil
    ---@param protect_content boolean | nil
    ---@param disable_notification boolean | nil
    ---@param message_effect_id string | nil
    send_message = function(chat_id, text, parse_mode, message_thread_id, protect_content, disable_notification, message_effect_id)
        local parse_mode = parse_mode or "HTML"
        local url = Bot.base_url .. "sendMessage"
        local params = "chat_id=" .. chat_id .. "&text=" .. text .. "&parse_mode=" .. parse_mode

        if message_thread_id ~= nil then
            params = params .. "&message_thread_id=" .. message_thread_id
        end

        if protect_content ~= nil then
            params = params .. "&protect_content=" .. tostring(protect_content)
        end

        if disable_notification ~= nil then
            params = params .. "&disable_notification=" .. tostring(disable_notification)
        end

        if message_effect_id ~= nil then
            params = params .. "&message_effect_id=" .. message_effect_id
        end

        local response = gg.makeRequest(url, {["Content-Type"] = "application/x-www-form-urlencoded"}, params)

        if response.code == 200 then
            local message = json.decode(response.content)
            return message
        else
            return nil
        end
    end,

    ---@return table | nilss
    get_me = function()
        local url = Bot.base_url .. "getMe"

        local response = gg.makeRequest(url, {["Content-Type"] = "application/x-www-form-urlencoded"}, nil)

        if response.code == 200 then
            local User = json.decode(response.content)
            return User
        else
            return nil
        end
    end,

    ---@return boolean | nil
    log_out = function()
        local url = Bot.base_url .. "logOut"

        local response = gg.makeRequest(url, {["Content-Type"] = "application/x-www-form-urlencoded"}, nil)

        if response.code == 200 then
            local is_true = json.decode(response.content).success
            return is_true
        else
            return nil
        end
    end,

    forward_message = function(chat_id, from_chat_id, message_id)
        local url = Bot.base_url .. "forwardMessages"
        local params = "chat_id=" .. chat_id .. "&from_chat_id=" .. from_chat_id .. "&message_id=" .. message_id

        local response = gg.makeRequest(url, {["Content-Type"] = "application/x-www-form-urlencoded"}, params)

        if response.code == 200 then
            local message = json.decode(response.content)
            return message
        else
            return nil
        end
    end,

    ---@param delay number
    mainloop = function(delay)
        while true do
            local updates = Bot.updates.getUpdates()
            if updates then
                for _, update in ipairs(updates) do
                    Bot.BotInfo["offset"] = update.update_id + 1 
                    for _, handler in ipairs(Bot.BotInfo["handlers"]) do
                        if handler["type"] == "message" then
                            if update.message and update.message.text then
                                if update.message.text == handler["text"] then
                                    handler["function"](update.message)
                                elseif handler["text"] == "any" then
                                    handler["function"](update.message)
                                end
                            end
                        end
                    end
                end
            end
            gg.sleep(delay * 1000)
        end
    end
}