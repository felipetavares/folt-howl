mode_reg =
  name: 'lisp'
  extensions: { 'cl', 'el', 'lisp', 'lsp', 'hy' }
  create: -> bundle_load('lisp_mode')!

howl.mode.register mode_reg

unload = -> howl.mode.unregister 'lisp'

return {
  info:
    author: 'Copyright 2013-2015 The Howl Developers',
    description: 'Lisp mode',
    license: 'MIT',
  :unload
}
