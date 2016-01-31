-- Copyright 2012-2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

Gdk = require 'ljglibs.gdk'
Gtk = require 'ljglibs.gtk'
import PropertyObject from howl.aux.moon
import Status, CommandLine, theme from howl.ui
import signal from howl
append = table.insert

to_gobject = (o) ->
  status, gobject = pcall -> o\to_gobject!
  return status and gobject or o

placements = {
  left_of: 'POS_LEFT'
  right_of: 'POS_RIGHT'
  above: 'POS_TOP'
  below: 'POS_BOTTOM'
}

class Window extends PropertyObject
  new: (properties = {}) =>
    @status = Status!
    @command_line = CommandLine self

    @grid = Gtk.Grid
      row_spacing: 4
      column_spacing: 4
      column_homogeneous: true
      row_homogeneous: true

    alignment = Gtk.Alignment {
      top_padding: 5,
      left_padding: 5,
      right_padding: 5,
      bottom_padding: 5,
      Gtk.Box Gtk.ORIENTATION_VERTICAL, {
        spacing: 3,
        { expand: true, @grid },
        @command_line\to_gobject!
        @status\to_gobject!,
      }
    }

    @win = Gtk.Window Gtk.Window.TOPLEVEL
    @win[k] = v for k,v in pairs properties
    @win\on_focus_in_event self\_on_focus
    @win\on_focus_out_event self\_on_focus_lost

    @win\add alignment
    @win.style_context\add_class 'main'
    theme.register_background_widget @win

    @data = {}
    super @win

  @property views: get: =>
    views = {}

    for c in *@grid.children
      props = @grid\properties_for c
      append views, {
        x: props.left_attach + 1
        y: props.top_attach + 1
        width: props.width
        height: props.height
        view: c
      }

    table.sort views, (a, b) ->
      return a.y < b.y if a.y != b.y
      a.x < b.x

    views

  @property focus_child: get: =>
    fc = @grid.focus_child
    @data.focus_child = nil if fc
    fc or @data.focus_child

  @property current_view: get: =>
    focused = @focus_child
    return nil unless focused
    @get_view focused

  @property fullscreen:
    get: => @win.window and @win.window.state.FULLSCREEN

    set: (state) =>
      if state and not @fullscreen
        @win\fullscreen!
      elseif not state and @fullscreen
        @win\unfullscreen!

  @property maximized:
    get: => @win.window and @win.window.state.MAXIMIZED

    set: (state) =>
      if state and not @maximized
        @win\maximize!
      elseif not state and @maximized
        @win\unmaximize!

  siblings: (view, wraparound = false) =>
    current = @get_view to_gobject(view or @focus_child)
    views = @views
    return {} unless current and #views > 1

    local left, right, up, down, index
    gobject = to_gobject view
    vertical_siblings = {}

    for i = 1, #views
      v = views[i]
      if v.view == current.view
        index = i
      elseif v.x <= current.x and v.x + v.width > current.x
        if v.y == current.y - 1
          up = v.view
        elseif v.y == current.y + 1
          down = v.view

        append vertical_siblings, v.view

    before = views[index - 1]
    left = if before and before.y == current.y then before

    after = views[index + 1]
    right = if after and after.y == current.y then after

    if wraparound
      left or= before or views[#views]
      right or= after or views[1]
      up = vertical_siblings[#vertical_siblings] unless up
      down = vertical_siblings[1] unless down

    {
      left: left and left.view
      right: right and right.view
      :up
      :down
    }

  to_gobject: => @win

  add_view: (view, placement = 'right_of', anchor) =>
    gobject = to_gobject view
    @_place gobject, placement, anchor
    gobject\show_all!
    @_reflow!
    @get_view gobject

  remove_view: (view = nil) =>
    view = @focus_child unless view
    gobject = to_gobject view
    error "Missing view to remove", 2 unless gobject

    siblings = @siblings gobject
    focus_target = siblings.right or siblings.left
    focus_target or= @siblings(gobject, true).left
    gobject\destroy!
    @_reflow!
    focus_target\grab_focus! if focus_target

  get_view: (o) =>
    gobject = to_gobject o
    for v in *@views
      return v if v.view == gobject

    nil

  remember_focus: =>
    @data.focus_child = @grid.focus_child

  save_screenshot: (filename, type='png', image_opts={}) =>
    pixbuf = Gdk.Pixbuf.get_from_window @window, 0, 0, @allocated_width, @allocated_height
    pixbuf\save filename, type, image_opts

  _as_rows: (views) =>
    rows = {}
    row = {}
    current = nil

    for v in *views
      if current and v.y != current.y
        append rows, row
        row = {}

      current = v
      append row, v.view

    append rows, row
    rows

  _reflow: =>
    views = @views
    return unless #views > 1

    rows = @_as_rows views

    max_columns = 0
    max_columns = math.max(max_columns, #r) for r in *rows

    for y = 1, #rows
      row = rows[y]
      col_size = math.floor max_columns / #row
      extra = max_columns % #row
      for i = 0, #row - 1
        width = col_size
        width += extra if i == #row - 1
        widget = row[i + 1]

        with @grid\properties_for(widget)
          .left_attach = i * col_size
          .top_attach = y - 1
          .width = width

  _insert_column: (anchor, where) =>
    rel_column = @grid\properties_for(anchor).left_attach
    if where == 'left_of'
      @grid\insert_column rel_column
    else
      @grid\insert_column rel_column + 1

  _place: (gobject, placement, anchor) =>
    where = placements[placement]
    error "Unknown placement '#{placement}' specified", 2 unless where

    anchor = to_gobject(anchor) or @focus_child
    unless anchor
      @grid\add gobject
      return

    @_insert_column anchor, placement if placement == 'left_of' or placement == 'right_of'
    @grid\attach_next_to gobject, anchor, Gtk[where], 1, 1

  _on_focus: =>
    howl.app.window = self
    signal.emit 'window-focused', window: self
    false

  _on_focus_lost: =>
    signal.emit 'window-defocused', window: self
    false

-- Signals
signal.register 'window-focused',
  description: 'Signaled right after a window has recieved focus'
  parameters:
    window: 'The window that recieved focus'

signal.register 'window-defocused',
  description: 'Signaled right after a window has lost focus'
  parameters:
    window: 'The window that lost focus'

return Window
