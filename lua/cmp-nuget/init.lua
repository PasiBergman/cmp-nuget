local source = require "cmp-nuget.source"

local cmp_nuget = {}

cmp_nuget.setup = function(overrides)
  require("cmp").register_source("nuget", source.new(overrides))
end

return cmp_nuget
