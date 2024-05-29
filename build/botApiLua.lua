local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("botAPILua", function(require, _LOADED, __bundle_register, __bundle_modules)
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

    ---@return table | nil
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

    ---@param chat_id number
    ---@param user_id number
    get_chat_member = function(chat_id, user_id)
        local url = Bot.base_url .. "getChatMember"
        local params = "chat_id=" .. chat_id .. "&user_id=" .. user_id

        local response = gg.makeRequest(url, {["Content-Type"] = "application/x-www-form-urlencoded"}, params)

        if response.code == 200 then
            local User = json.decode(response.content)
            return User
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
end)
__bundle_register("json", function(require, _LOADED, __bundle_register, __bundle_modules)
local json = {}


-- Internal functions.

local function kind_of(obj)
  if type(obj) ~= 'table' then return type(obj) end
  local i = 1
  for _ in pairs(obj) do
    if obj[i] ~= nil then i = i + 1 else return 'table' end
  end
  if i == 1 then return 'table' else return 'array' end
end

local function escape_str(s)
  local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
  local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
  for i, c in ipairs(in_char) do
    s = s:gsub(c, '\\' .. out_char[i])
  end
  return s
end

-- Returns pos, did_find; there are two cases:
-- 1. Delimiter found: pos = pos after leading space + delim; did_find = true.
-- 2. Delimiter not found: pos = pos after leading space;     did_find = false.
-- This throws an error if err_if_missing is true and the delim is not found.
local function skip_delim(str, pos, delim, err_if_missing)
  pos = pos + #str:match('^%s*', pos)
  if str:sub(pos, pos) ~= delim then
    if err_if_missing then
      error('Expected ' .. delim .. ' near position ' .. pos)
    end
    return pos, false
  end
  return pos + 1, true
end

-- Expects the given pos to be the first character after the opening quote.
-- Returns val, pos; the returned pos is after the closing quote character.
local function parse_str_val(str, pos, val)
  val = val or ''
  local early_end_error = 'End of input found while parsing string.'
  if pos > #str then error(early_end_error) end
  local c = str:sub(pos, pos)
  if c == '"'  then return val, pos + 1 end
  if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
  -- We must have a \ character.
  local esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}
  local nextc = str:sub(pos + 1, pos + 1)
  if not nextc then error(early_end_error) end
  return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
end

-- Returns val, pos; the returned pos is after the number's final character.
local function parse_num_val(str, pos)
  local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
  local val = tonumber(num_str)
  if not val then error('Error parsing number at position ' .. pos .. '.') end
  return val, pos + #num_str
end


-- Public values and functions.

function json.stringify(obj, as_key)
  local s = {}  -- We'll build the string as an array of strings to be concatenated.
  local kind = kind_of(obj)  -- This is 'array' if it's an array or type(obj) otherwise.
  if kind == 'array' then
    if as_key then error('Can\'t encode array as key.') end
    s[#s + 1] = '['
    for i, val in ipairs(obj) do
      if i > 1 then s[#s + 1] = ', ' end
      s[#s + 1] = json.stringify(val)
    end
    s[#s + 1] = ']'
  elseif kind == 'table' then
    if as_key then error('Can\'t encode table as key.') end
    s[#s + 1] = '{'
    for k, v in pairs(obj) do
      if #s > 1 then s[#s + 1] = ', ' end
      s[#s + 1] = json.stringify(k, true)
      s[#s + 1] = ':'
      s[#s + 1] = json.stringify(v)
    end
    s[#s + 1] = '}'
  elseif kind == 'string' then
    return '"' .. escape_str(obj) .. '"'
  elseif kind == 'number' then
    if as_key then return '"' .. tostring(obj) .. '"' end
    return tostring(obj)
  elseif kind == 'boolean' then
    return tostring(obj)
  elseif kind == 'nil' then
    return 'null'
  else
    error('Unjsonifiable type: ' .. kind .. '.')
  end
  return table.concat(s)
end

json.null = {}  -- This is a one-off table to represent the null value.

function json.parse(str, pos, end_delim)
  pos = pos or 1
  if pos > #str then error('Reached unexpected end of input.') end
  local pos = pos + #str:match('^%s*', pos)  -- Skip whitespace.
  local first = str:sub(pos, pos)
  if first == '{' then  -- Parse an object.
    local obj, key, delim_found = {}, true, true
    pos = pos + 1
    while true do
      key, pos = json.parse(str, pos, '}')
      if key == nil then return obj, pos end
      if not delim_found then error('Comma missing between object items.') end
      pos = skip_delim(str, pos, ':', true)  -- true -> error if missing.
      obj[key], pos = json.parse(str, pos)
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '[' then  -- Parse an array.
    local arr, val, delim_found = {}, true, true
    pos = pos + 1
    while true do
      val, pos = json.parse(str, pos, ']')
      if val == nil then return arr, pos end
      if not delim_found then error('Comma missing between array items.') end
      arr[#arr + 1] = val
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '"' then  -- Parse a string.
    return parse_str_val(str, pos + 1)
  elseif first == '-' or first:match('%d') then  -- Parse a number.
    return parse_num_val(str, pos)
  elseif first == end_delim then  -- End of an object or array.
    return nil, pos + 1
  else  -- Parse true, false, or null.
    local literals = {['true'] = true, ['false'] = false, ['null'] = json.null}
    for lit_str, lit_val in pairs(literals) do
      local lit_end = pos + #lit_str - 1
      if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
    end
    local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
    error('Invalid json syntax starting at ' .. pos_info_str)
  end
end

return json
end)
return __bundle_require("botAPILua")
