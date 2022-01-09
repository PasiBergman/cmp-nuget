local Job = require "plenary.job"
local utils = require "cmp-nuget.utils"

local NuGet = {
  cache = {
    packages = {},
    versions = {},
  },
  config = {},
}

NuGet.new = function(overrides)
  local self = setmetatable({}, {
    __index = NuGet,
  })

  local ok, cfg = pcall(require, "cmp-nuget.config")
  if not ok or cfg.nuget == nil then
    vim.notify "Unable to load cmp-nuget config."
    return self
  end

  self.config = vim.tbl_extend("force", cfg.nuget, overrides or {})

  return self
end

local add_curl_header = function(command, header, value_format, env_value)
  if vim.fn.exists("$" .. env_value) ~= 1 then
    return command
  end

  local value = vim.fn.getenv(env_value)
  local val_format = value_format or "%s"
  local curl_header = header .. ": " .. string.format(val_format, value)
  table.insert(command, "-H")
  table.insert(command, curl_header)

  return command
end

local get_command = function(callback, curl_url, handle_item)
  if vim.fn.executable "curl" ~= 1 then
    vim.notify "curl executable not found. cmp-nuget requires curl. See https://curl.se"
    return
  end

  if not curl_url then
    vim.notify "Missign url for the action."
    return
  end

  local command = {
    "curl",
    "-s",
    "-X",
    "GET",
    curl_url,
  }

  command = add_curl_header(command, "X-NuGet-ApiKey", "%s", "NUGET_APIKEY")
  command = add_curl_header(command, "X-NuGet-Client-Version", "%s", "NUGET_CLIENT_VERSION")
  command = add_curl_header(command, "X-NuGet-Protocol-Version", "%s", "NUGET_PROTOCOL_VERSION")
  command = add_curl_header(command, "X-NuGet-Session-Id", "%s", "NUGET_SESSION_ID")

  command.on_exit = vim.schedule_wrap(function(job)
    local result = table.concat(job:result(), "")
    local items = utils.handle_response(result, handle_item)
    callback { items = items, isIncomplete = true }
  end)

  return command
end

local get_packages_job = function(callback, package, config)
  local url = string.format(
    "https://api-v2v3search-0.nuget.org/autocomplete?q=%s&take=%s&prerelease=%s&semVerLevel=%s&packageType=%s",
    utils.url_encode(package),
    config.limit or "100",
    config.prerelease or "false",
    config.sem_ver_level or "2.0.0",
    config.package_type or ""
  )
  return Job:new(get_command(
    callback,
    url,
    -- handle_item
    function(pg)
      return {
        label = pg,
        -- insertText = pg,
        -- filterText = config.filter_fn(package, pg),
        -- sortText = pg,
        -- documentation = nil,
        -- data = pg,
      }
    end
  ))
end

local get_versions_job = function(callback, package_id, config)
  local url = string.format(
    "https://api-v2v3search-0.nuget.org/autocomplete?id=%s&prerelease=%s&semVerLevel=%s",
    utils.url_encode(package_id),
    config.prerelease or "false",
    config.sem_ver_level or "2.0.0"
  )
  return Job:new(get_command(
    callback,
    url,
    -- handle_item
    function(ver)
      return {
        label = ver,
        -- insertText = ver,
        -- filterText = config.filter_fn(version, ver),
        sortText = utils.get_version_sort_text(ver),
        -- documentation = nil,
        -- data = ver,
      }
    end
  ))
end

local _get_packages = function(self, callback, package, config)
  if self.cache.packages[package] then
    callback { items = self.cache.packages[package], isIncomplete = true }
    return nil
  end

  config = vim.tbl_extend("force", self.config.packages, config or {})

  local packages_job = get_packages_job(function(args)
    self.cache.packages[package] = args.items
    callback(args)
  end, package, config)

  return packages_job
end

local _get_versions = function(self, callback, package_id, config)
  if self.cache.versions[package_id] then
    callback { items = self.cache.versions[package_id], isIncomplete = true }
    return nil
  end

  config = vim.tbl_extend("force", self.config.versions, config or {})

  local versions_job = get_versions_job(function(args)
    self.cache.packages[package_id] = args.items
    callback(args)
  end, package_id, config)

  return versions_job
end

function NuGet:get_packages(callback, package, config)
  local job = _get_packages(self, callback, package, config)

  if job then
    job:start()
  end

  return true
end

function NuGet:get_versions(callback, package_id, config)
  local job = _get_versions(self, callback, package_id, config)

  if job then
    job:start()
  end

  return true
end

return NuGet
