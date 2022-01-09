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

local split_version = function(version)
  local t = {}
  if version == nil or version == "" then
    return t
  end

  local period = "."
  local dash = "-"
  for str in string.gmatch(version, "([^" .. period .. "]+)") do
    for str2 in string.gmatch(str, "([^" .. dash .. "]+)") do
      if str2 == "rc" then
        str2 = "1rc"
      end
      if str2 == "preview" then
        str2 = "2preview"
      end
      table.insert(t, str2)
    end
  end

  return t
end

local reverse_version = function(version_table)
  if type(version_table) ~= "table" then
    return version_table
  end

  local numbers = {}

  for _, ver_part in ipairs(version_table) do
    local number = tonumber(ver_part)
    if number ~= nil then
      number = 999999 - number
      table.insert(numbers, number)
    else
      table.insert(numbers, ver_part)
    end
  end

  return numbers
end

local version_for_sort = function(rev_numbers)
  if type(rev_numbers) ~= "table" then
    return rev_numbers
  end

  local version = ""

  for _, ver_part in ipairs(rev_numbers) do
    version = version .. ver_part .. "."
  end

  return version
end

Utils.get_version_sort_text = function(item)
  local version = split_version(item)
  local rev_numbers = reverse_version(version)
  local rev_version = version_for_sort(rev_numbers)

  return rev_version
end

return Utils
