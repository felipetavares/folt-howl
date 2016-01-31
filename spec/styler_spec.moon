import style from howl.ui
import styler, Scintilla, Buffer from howl

describe 'styler', ->
  sci = Scintilla!
  buffer = Buffer {}, sci
  sci.listener = buffer.sci_listener
  style.define 's1', color: '#334455'
  style.define 's2', color: '#334466'
  style.define 's3', color: '#114466'

  describe 'apply(buffer, start_pos, end_pos, styles)', ->

    it 'styles the buffer text according to the styles', ->
      buffer.text = 'foo'
      styler.apply buffer, 1, buffer.size, { 1, 's1', 2, 2, 's2', 4 }
      assert.equal 's1', (style.at_pos(buffer, 1))
      assert.equal 's2', (style.at_pos(buffer, 2))
      assert.equal 's2', (style.at_pos(buffer, 3))

    it 'styles any holes with the default style', ->
      buffer.text = 'foo'
      styler.apply buffer, 1, buffer.size, { 2, 's2', 3 }
      assert.equal 'default', (style.at_pos(buffer, 1))
      assert.equal 's2', (style.at_pos(buffer, 2))
      assert.equal 'default', (style.at_pos(buffer, 3))

    it 'uses "default" for undefined styles', ->
      buffer.text = 'foo'
      styler.apply buffer, 1, buffer.size, { 1, 'wat', 4 }
      assert.equal 'default', (style.at_pos(buffer, 1))

    context 'sub lexing', ->
      it 'automatically styles using extended styles when requested', ->
        buffer.text = '>foo'
        styler.apply buffer, 1, buffer.size, {
          1, 'operator', 2,
          2, { 1, 's2', 2, 2, 's3', 3 }, 'my_sub|s1',
          4, 's2', 5
        }
        assert.equal 'operator', (style.at_pos(buffer, 1))
        assert.equal 's1:s2', (style.at_pos(buffer, 2))
        assert.equal 's1:s3', (style.at_pos(buffer, 3))
        assert.equal 's2', (style.at_pos(buffer, 4))

      it 'styles any holes with the base style', ->
        buffer.text = 'foo'
        styler.apply buffer, 1, buffer.size, {
          1, { 2, 's3', 3 }, 'my_sub|s1'
        }
        assert.equal 's1', (style.at_pos(buffer, 1))
        assert.equal 's1:s3', (style.at_pos(buffer, 2))
        assert.equal 'default', (style.at_pos(buffer, 3))

      it 'resets the base style afterwards', ->
        buffer.text = 'foo'
        styler.apply buffer, 1, buffer.size, {
          1, { 1, 's3', 2 }, 'my_sub|s1'
        }
        assert.equal 's1:s3', (style.at_pos(buffer, 1))
        assert.equal 'default', (style.at_pos(buffer, 2))

  describe 'reverse(buffer, start_pos, end_pos)', ->
    it 'returns a table of styles and positions for the given range, same as styles argument to apply', ->
      buffer.text = 'foo'
      styles = { 1, 's1', 2, 2, 's2', 4 }
      styler.apply buffer, 1, buffer.size, styles
      assert.same styles, styler.reverse buffer, 1, #buffer

    it 'handles "gaps" for characters with the default style', ->
      buffer.text = 'foobar'
      styles = { 1, 's1', 2, 4, 's2', 7 }
      styler.apply buffer, 1, buffer.size, styles
      assert.same styles, styler.reverse buffer, 1, #buffer

    it 'end_pos is inclusive', ->
      buffer.text = 'foo'
      styles = { 1, 's1', 2, 2, 's2', 4 }
      styler.apply buffer, 1, buffer.size, styles
      assert.same { 1, 's1', 2 }, styler.reverse buffer, 1, 1

    it 'indexes are byte offsets', ->
      buffer.text = 'Liñe'
      styles = { 1, 's1', 2 }
      styler.apply buffer, buffer.size, buffer.size, styles
      assert.same { 1, 'unstyled', 2 }, styler.reverse buffer, 4, 4
