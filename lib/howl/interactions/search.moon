-- Copyright 2012-2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

import app, interact from howl

class SearchInteraction
  run: (@finish, @operation, @type, opts={}) =>
    @line_search = opts.line_search
    @searcher = app.editor.searcher
    @keymap = moon.copy @keymap

    for keystroke in *opts.backward_keys
      @keymap[keystroke] = -> @searcher\previous @line_search
    for keystroke in *opts.forward_keys
      @keymap[keystroke] = -> @searcher\next @line_search
    app.window.command_line.title = opts.title

  on_update: (text) =>
    match = @searcher.active if @operation == 'backward_to'
    match = true if @operation == 'forward_to'

    @searcher[@operation] @searcher, text, @type, match, @line_search
    --@searcher[@operation] @searcher, text, @type

  keymap:
    ctrl_i: => @searcher\previous @line_search
    ctrl_j: => @searcher\next @line_search
    ctrl_m: => self.finish true
    ctrl_g: => self.finish!

interact.register
  name: 'search'
  description: ''
  factory: SearchInteraction

interact.register
  name: 'forward_search'
  description: ''
  handler: ->
    interact.search 'forward_to', 'plain'
      title: 'Forward Search'
      forward_keys: howl.bindings.keystrokes_for('buffer-search-forward', 'editor')
      backward_keys: howl.bindings.keystrokes_for('buffer-search-backward', 'editor')
      line_search: false

interact.register
  name: 'search_line'
  description: ''
  handler: ->
    interact.search 'forward_to', 'plain'
      title: 'Line Search'
      forward_keys: howl.bindings.keystrokes_for('buffer-search-forward', 'editor')
      backward_keys: howl.bindings.keystrokes_for('buffer-search-backward', 'editor')
      line_search: true

interact.register
  name: 'backward_search'
  description: ''
  handler: ->
    interact.search 'backward_to', 'plain'
      title: 'Backward Search'
      forward_keys: howl.bindings.keystrokes_for('buffer-search-forward', 'editor')
      backward_keys: howl.bindings.keystrokes_for('buffer-search-backward', 'editor')
      line_search: false

interact.register
  name: 'forward_search_word'
  description: ''
  handler: ->
    interact.search 'forward_to', 'word',
      title: 'Forward Word Search'
      forward_keys: howl.bindings.keystrokes_for('buffer-search-word-forward', 'editor')
      backward_keys: howl.bindings.keystrokes_for('buffer-search-word-backward', 'editor')

interact.register
  name: 'backward_search_word'
  description: ''
  handler: ->
    interact.search 'backward_to', 'word',
      title: 'Backward Word Search',
      forward_keys: howl.bindings.keystrokes_for('buffer-search-word-forward', 'editor')
      backward_keys: howl.bindings.keystrokes_for('buffer-search-word-backward', 'editor')
