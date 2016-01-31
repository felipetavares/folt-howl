import Sandbox from howl.aux

describe 'Sandbox', ->
  it 'allows running a function with a specified environment', ->
    box = Sandbox foo: -> 'bar!'
    assert.equal 'bar!', box -> return foo!

  it 'allows passing parameters to the function', ->
    box = Sandbox!
    f = (...) -> return ...
    assert.equal 'bar!', box(f, 'bar!')

  it '.put allows modifiying the environment', ->
    box = Sandbox!
    box\put what: -> 'bar!'
    assert.equal 'bar!', box -> return what!

  it 'allows global access by default', ->
    box = Sandbox!
    assert.equal table, box -> return table

  it 'disallows global access if options.no_globals is set', ->
    box = Sandbox nil, no_globals: true
    assert.is_nil box -> return table

  context 'when options.no_implicit_globals is set', ->
    it 'raises an error upon implicit global writes', ->
      box = Sandbox nil, no_implicit_globals: true
      renegade = -> export frob = 'bar!'
      assert.raises 'implicit global', -> box renegade

  context 'when options.no_implicit_globals is not set', ->
    it 'collects exports into .exports', ->
      box = Sandbox!
      box -> export foo = 'bar'
      assert.equal box.exports.foo, 'bar'
