-- Copyright 2012-2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)
append = table.insert

new = (options = {}) ->
  spy =
    called: false
    reads: {}
    writes: {}
    called_with: {}

  setmetatable spy,
    __call: (_, ...) ->
      spy.called = true
      rawset spy, 'called_with', {...}
      options.with_return

    __index: (t,k) ->
      append spy.reads, k
      if options.as_null_object
        sub = new options
        rawset spy, k, sub
        return sub
      spy.writes[k]

    __newindex: (t,k,v) ->
      spy.writes[k] = v
  spy

return setmetatable {}, __call: (_, options) -> new options
