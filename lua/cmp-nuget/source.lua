local nuget = require "cmp-nuget.nuget"

local Source = {
  config = {},
  file_extensions = {},
  filetypes = {},
}

Source.new = function(overrides)
  local self = setmetatable({}, {
    __index = Source,
  })

  self.config = vim.tbl_extend("force", require "cmp-nuget.config", overrides or {})

  for _, item in ipairs(self.config.filetypes) do
    self.filetypes[item] = true
  end

  for _, item in ipairs(self.config.file_extensions) do
    self.file_extensions[string.lower(item)] = true
  end

  self.nuget = nuget.new(self.config.nuget)

  self.trigger_characters = {}
  self.trigger_characters_str = table.concat(self.trigger_characters, "")
  if self.trigger_characters_str ~= "" then
    self.keyword_pattern = string.format("[%s]\\S*", self.trigger_characters_str)
  else
    self.keyword_pattern = [[\k\+]]
  end

  return self
end

function Source:complete(params, callback)
  local cursor_line = string.lower(params.context.cursor_line or "")
  local cur_col = params.context.cursor.col
  local package = string.match(cursor_line, '%s*packagereference.*include="([^"]*)"?')

  local _, idx_after_version = string.find(cursor_line, '.*%sversion="')
  local _, idx_after_version_passed = string.find(cursor_line, '.*%sversion="[^"]*"')

  local find_version = false
  -- Does line contain Version="
  if idx_after_version then
    -- Does line contain Version="*"
    if idx_after_version_passed then
      -- is cursor between quotes on Version=""
      find_version = cur_col >= idx_after_version and cur_col <= idx_after_version_passed
    else
      -- is cursor after quote on Version="
      find_version = cur_col >= idx_after_version
    end
  end

  if package ~= nil and #package > 2 and not find_version then
    self.nuget:get_packages(callback, string.lower(package))
  elseif package ~= nil and #package > 2 and find_version then
    self.nuget:get_versions(callback, package)
  else
    callback { items = {}, isIncomplete = true }
  end
end

function Source:get_keyword_pattern()
  return self.keyword_pattern
end

function Source:get_trigger_characters()
  return self.trigger_characters
end

function Source:get_debug_name()
  return "nuget"
end

function Source:is_available()
  return self.filetypes["*"] ~= nil
    or self.filetypes[vim.bo.filetype] ~= nil
    or self.file_extensions["*"] ~= nil
    or self.file_extensions[string.lower(vim.fn.expand "%:e")] ~= nil
end

return Source
