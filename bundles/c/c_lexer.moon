-- Copyright 2014-2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

howl.aux.lpeg_lexer ->
  c = capture
  ident = (alpha + '_')^1 * (alpha + digit + '_')^0
  ws = c 'whitespace', blank

  identifer = c 'identifer', ident

  keyword = c 'keyword', word {
    -- C++ keywords: todo, break out into separate mode later
    'alignas', 'alignof', 'and_eq', 'and', 'asm', 'bitand', 'bitor', 'bool',
    'catch', 'char16_t', 'char32_t', 'char', 'class', 'compl', 'constexpr',
    'const_cast', 'decltype', 'delete', 'dynamic_cast', 'explicit', 'export',
    'false', 'friend', 'mutable', 'namespace', 'new', 'noexcept', 'not_eq',
    'not', 'nullptr', 'operator', 'or_eq', 'or', 'private', 'protected',
    'public', 'reinterpret_cast', 'static_assert', 'static_cast', 'template',
    'this', 'thread_local', 'throw', 'true', 'try', 'typeid', 'typename',
    'union', 'using', 'virtual', 'wchar_t', 'while', 'xor_eq', 'xor'

    'auto', '_Bool', 'break', 'case', 'char', '_Complex', 'const', 'continue',
    'default', 'double', 'do', 'else', 'enum', 'extern', 'float', 'for', 'goto',
    'if', '_Imaginary', 'inline', 'int', 'long', 'register', 'restrict',
    'return', 'short', 'signed', 'sizeof', 'static', 'struct', 'switch',
    'typedef', 'union', 'unsigned', 'void', 'volatile', 'while'
  }

  operator = c 'operator', S('+-*/%=<>~&^|!(){}[];.')

  comment = c 'comment', any {
    P'//' * scan_until eol,
    span '/*', '*/'
  }

  char_constant = span("'", "'", '\\')

  number = c 'number', any {
    char_constant,
    float,
    hexadecimal_float,
    hexadecimal,
    octal,
    R'19' * digit^0,
  }

  special = c 'special', word {
    'NULL', 'TRUE', 'FALSE', '__FILE__',
    '__LINE__', '__DATE__', '__TIME__', '__TIMESTAMP__'
  }

  string = c 'string', span('"', '"', '\\')

  preproc = c 'preproc', '#' * complement(space)^1

  include_stmt = sequence {
    c('preproc', '#include'),
    ws^0,
    c('operator', '<'),
    c('string', complement('>')^1),
    c('operator', '>'),
  }

  constant = c 'constant', word any('_', upper)^1 * any('_', upper, digit)^0

  any {
    include_stmt,
    preproc,
    comment,
    string,
    keyword,
    special,
    operator,
    number,
    constant,
    identifer,
  }
