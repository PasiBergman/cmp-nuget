local Utils = {}

local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end

Utils.url_encode = function(value)
  return string.gsub(value, "([^%w _%%%-%.~])", char_to_hex)
end

local process_data = function(ok, parsed, items, handle_item)
  if not ok then
    vim.notify "Failed to parse cmp-nuget response"
    return items
  end

  for _, item in ipairs(parsed.data) do
    table.insert(items, handle_item(item))
  end

  return items
end

Utils.handle_response = function(response, handle_item)
  local items = {}

  if vim.json and vim.json.decode then
    local ok, parsed = pcall(vim.json.decode, response)
    items = process_data(ok, parsed, items, handle_item)
  else
    vim.schedule(function()
      local ok, parsed = pcall(vim.fn.json_decode, response)
      items = process_data(ok, parsed, items, handle_item)
    end)
  end

  return items
end

Utils.get_sort_text = function(config_val, item)
  if type(config_val) == "function" then
    return config_val(item)
  elseif type(config_val) == "string" then
    return item[config_val]
  end

  return nil
end

return Utils
