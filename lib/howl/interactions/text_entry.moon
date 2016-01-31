-- Copyright 2012-2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

import app, interact from howl

class ReadText
  run: (@finish, opts = {}) =>
    with app.window.command_line
      .prompt = opts.prompt or ''
      .title = opts.title

  keymap:
    ctrl_m: =>
      self.finish app.window.command_line.text

    ctrl_g: => self.finish!

interact.register
  name: 'read_text'
  description: 'Read free form text entered by user'
  factory: ReadText

