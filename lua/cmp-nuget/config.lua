local Config = {
  filetypes = {},
  file_extensions = { "csproj" },
  nuget = {
    packages = {
      limit = 100,
      prerelease = false,
      sem_ver_level = "2.0.0",
      package_type = "",
    },
    versions = {
      prerelease = true,
      sem_ver_level = "2.0.0",
    },
  },
}

return Config
