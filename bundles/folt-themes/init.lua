local moonshine = bundle_file('tm_moonshine.moon')
local name = 'Moonshine'

howl.ui.theme.register(name, moonshine)

local unload = function()
  howl.ui.theme.unregister(name)
end

return {
  info = {
    author = 'Moonshine themes adapted by Tavares <felipeoltavares at gmail.com>',
    description = [[
      Designed by Karolis Koncevicius.

      Adapted for the howl editor by @felipeoltavares
    ]],
    license = 'MIT',
  },
  unload = unload
}
