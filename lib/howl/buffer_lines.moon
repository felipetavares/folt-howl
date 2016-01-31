-- Copyright 2012-2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

import string, type from _G
append = table.insert

line_mt =
  __index: (k) =>
    getter = @_getters[k]
    return getter self if getter

    v = @text[k]
    if v != nil
      return v unless type(v) == 'function'
      return (_, ...) -> v @text, ...

  __newindex: (k, v) =>
    setter = @_setters[k]
    if setter
      setter self, v
      v
    else
      rawset self, k, v

  __tostring: => @text
  __len: => @text.ulen
  __eq: (op1, op2) -> tostring(op1) == tostring(op2)

Line = (nr, buffer, sci) ->
  text = ->
    contents = sci\get_line nr - 1
    (contents\gsub '[\n\r]*$', '')

  setmetatable {
    :nr
    :buffer
    indent: => @indentation += buffer.config.indent
    unindent: =>
      new_indent = @indentation - buffer.config.indent
      if new_indent >= 0
        @indentation = new_indent

    _getters:
      text: => text!
      byte_start_pos: => sci\position_from_line(nr - 1) + 1
      byte_end_pos: => math.max(sci\position_from_line(nr), 1)
      start_pos: => buffer\char_offset @byte_start_pos
      end_pos: => buffer\char_offset @byte_end_pos
      indentation: =>  sci\get_line_indentation nr - 1
      previous: => if nr > 1 then Line nr - 1, buffer, sci
      next: => if nr < sci\get_line_count! then Line nr + 1, buffer, sci
      chunk: =>
        start_pos = @start_pos
        end_pos = @end_pos
        end_pos -= #buffer.eol unless nr == sci\get_line_count!
        buffer\chunk start_pos, end_pos

      previous_non_blank: =>
        prev_line = @previous
        while prev_line and prev_line.is_blank
          prev_line = prev_line.previous
        prev_line

      next_non_blank: =>
        next_line = @next
        while next_line and next_line.is_blank
          next_line = next_line.next
        next_line

    _setters:
      text: (value) =>
        error 'line text can not be set to nil', 2 if value == nil
        line = nr - 1
        start = sci\position_from_line line
        end_pos = sci\get_line_end_position line
        sci\delete_range start, end_pos - start
        sci\insert_text start, value
      indentation: (indent) =>  sci\set_line_indentation nr - 1, indent

  }, line_mt

BufferLines = (buffer, sci) ->
  setmetatable {
      :buffer
      :sci

      delete: (start_line, end_line) =>
        start_pos = sci\position_from_line(start_line - 1)
        end_pos = sci\position_from_line(end_line)
        @sci\delete_range start_pos, end_pos - start_pos

      range: (start_line, end_line) =>
        s = math.min start_line, end_line
        e = math.max start_line, end_line
        lines = {}
        for line = s, e
          append lines, self[line]
        lines

      for_text_range: (start_pos, end_pos) =>
        s = math.min start_pos, end_pos
        e = math.max start_pos, end_pos
        start_line = @at_pos s
        return { start_line } if s == e
        end_line = @at_pos e

        start_line = start_line.next if start_line.end_pos == s
        end_line = end_line.previous if end_line.start_pos == e
        @range start_line.nr, end_line.nr

      at_pos: (pos) =>
        b_pos = buffer\byte_offset pos
        nr = @sci\line_from_position(b_pos - 1) + 1
        self[nr]

      insert: (line_nr, text) =>
        cur_line = self[line_nr]
        if not cur_line
          return @append(text) if line_nr == #@ + 1
          error('Invalid line number "' .. line_nr .. '"', 2) if not cur_line

        text ..= @buffer.eol if not text\match '[\r\n]$'
        @buffer\insert text, cur_line.start_pos
        self[line_nr]

      append: (line_text) =>
        line_text ..= @buffer.eol if not line_text\match '[\r\n]$'
        last_line = self[#self]

        if #last_line > 0 and not last_line.text\match '[\r\n]$'
          line_text = @buffer.eol .. line_text

        @buffer\append line_text
        self[#self - 1]
    },
      __len: => @sci\get_line_count!

      __index: (key) =>
        if type(key) == 'number'
          return nil if key < 1 or key > #self
          Line key, @buffer, @sci

      __newindex: (key, value) =>
        if type(key) != 'number' or (key < 1) or (key > #self)
          error 'Invalid index: "' .. key .. '"', 2

        if value
          self[key].text = value
        else
          start_pos = @sci\position_from_line(key - 1)
          end_pos = @sci\position_from_line(key)
          @sci\delete_range start_pos, (end_pos - start_pos)

      __ipairs: =>
        iterator = (lines, index) ->
          index += 1
          line = lines[index]
          return nil if not line
          return index, line

        return iterator, self, 0

      __pairs: => ipairs self

return setmetatable {}, __call: (_, buffer, sci) -> BufferLines buffer, sci
