-- Copyright 2013-2015 The Howl Developers
-- License: MIT (see LICENSE.md)

import formatting from howl
completer = bundle_load 'css_completer'

class CSSMode
  new: =>
    @lexer = bundle_load 'css_lexer'
    @completers = { completer, 'in_buffer' }

  default_config:
    word_pattern: r'\\b[-_\\w]+\\b'

  comment_syntax: { '/*', '*/' }

  auto_pairs: {
    '(': ')'
    '[': ']'
    '{': '}'
    '"': '"'
    "'": "'"
  }

  on_completion_accepted: (completion, context) =>
    @completer or= completer!
    @completer.finish_completion completion, context
