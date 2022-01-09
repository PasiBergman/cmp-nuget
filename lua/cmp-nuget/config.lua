local Config = {
  filetypes = {},
  file_extensions = { "csproj" },
  nuget = {
    packages = {
      limit = 100,
      prerelease = false,
      sem_ver_level = "2.0.0",
      package_type = "",
      sort_by = function(package)
        return string.format("%s", package)
      end,
      filter_fn = function(tricker_char, package)
        return string.format("%s %s", tricker_char, package)
      end,
    },
    versions = {
      prerelease = false,
      sem_ver_level = "2.0.0",
      sort_by = function(ver)
        return string.format("%s", ver)
      end,
      filter_fn = function(tricker_char, package)
        return string.format("%s %s", tricker_char, package)
      end,
    },
  },
  trigger_actions = {
    packages = {
      debug_name = "nuget_packages",
      -- trigger_character = [["]],
      action = function(sources, package, callback, params)
        return sources.nuget:get_packages(callback, package)
      end,
    },
    versions = {
      debug_name = "nuget_versions",
      -- trigger_character = [["]],
      action = function(sources, package_id, callback, params)
        return sources.nuget:get_versions(callback, package_id)
      end,
    },
  },
}

return Config
