import signal from howl

describe 'signal', ->
  describe '.register(name, options)', ->
    it 'raises an error if mandatory fields are missing', ->
      assert.raises 'description', -> signal.register 'foo'

  it '.all contains all registered signals', ->
    signal.register 'foo', description: 'bar'
    assert.same description: 'bar', signal.all.foo

  describe '.unregister(name)', ->
    it 'unregisters the specified signal', ->
      signal.register 'frob', description: 'bar'
      signal.unregister 'frob'
      assert.is_nil signal.all.frob

  context 'trying to use a non-registered signal', ->
    it 'emit raises an error', ->
      assert.raises 'none', -> signal.emit 'none'

    it 'connect raises an error', ->
      assert.raises 'none', -> signal.connect 'none', -> true

  context 'with a registered signal', ->
    before_each -> signal.register 'foo', description: 'bar'
    after_each -> signal.unregister 'foo'

    it 'allows name based signals to be broadcasted to any number of handlers', ->
      handler1 = spy.new -> nil
      handler2 = spy.new -> nil
      signal.connect 'foo', handler1
      signal.connect 'foo', handler2
      signal.emit 'foo'
      assert.spy(handler1).was_called!
      assert.spy(handler2).was_called!

    it 'allows connecting handlers before existing handlers', ->
      value = nil
      signal.connect 'foo', -> value = 'first'
      signal.connect 'foo', (-> value = 'second'), 1
      signal.emit 'foo'
      assert.equal value, 'first'

    it 'allows disconnecting handlers', ->
      handler = spy.new -> true
      signal.connect 'foo', handler
      signal.disconnect 'foo', handler
      signal.emit 'foo'
      assert.spy(handler).was.not_called!

    describe '.emit', ->
      it 'raises an error when called with more than two parameters', ->
        assert.raises 'parameter', -> signal.emit 'foo', {}, 2

      it 'raises an error when the second parameter is not a table', ->
        assert.raises 'table', -> signal.emit 'foo', 2

      context 'when a handler returns true', ->
        it 'skips invoking subsequent handlers', ->
          handler2 = spy.new -> true
          signal.connect 'foo', -> true
          signal.connect 'foo', handler2
          signal.emit 'foo'
          assert.spy(handler2).was.not_called!

        it 'returns true', ->
          signal.connect 'foo', -> true
          assert.is_true signal.emit 'foo'

      context 'when a handler raises an error', ->
        it 'logs an error message', ->
          signal.connect 'foo', -> error 'BOOM'
          signal.emit 'foo'
          assert.match log.last_error.message, 'BOOM'

        it 'continues processing subsequent handlers', ->
          handler2 = spy.new -> true
          signal.connect 'foo', -> error 'BOOM'
          signal.connect 'foo', handler2
          signal.emit 'foo'
          assert.spy(handler2).was_called!

      it 'returns false if no handlers returned true', ->
        assert.is_false signal.emit 'foo'
        signal.connect 'foo', -> 'this is fortunately not true'
        assert.is_false signal.emit 'foo'

      it 'invokes all handlers in their own coroutines', ->
        coros = {}
        coro_register = ->
          co, main = coroutine.running!
          coros[co] = true unless main

        handler1 = spy.new coro_register
        handler2 = spy.new coro_register
        signal.connect 'foo', handler1
        signal.connect 'foo', handler2
        signal.emit 'foo'
        assert.equal 2, #[v for _, v in pairs coros]

      context 'when a handler yields', ->
        it 'continues on invoking subsequent handlers', ->
          handler2 = spy.new -> true
          signal.connect 'foo', -> coroutine.yield false
          signal.connect 'foo', handler2
          signal.emit 'foo'
          assert.spy(handler2).was_called!

        it 'returns false', ->
          signal.connect 'foo', -> coroutine.yield true
          assert.is_false signal.emit 'foo'
