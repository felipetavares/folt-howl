background = '#121212'
foreground = '#d7af5f'

current = '#303030'
selection = '#87afd7'

comment = '#444444'

question = '#87afff'
warning = '#af0000'
errorfg = '#262626'
errorbg = warning

statusbg = current
statusfg = '#eeeeee'

variable = '#5f875f'
label = '#875f00'
line_number = '#606060'
key = label
fdecl = '#d75f00'
keyword = '#d78700'
classcolor = keyword
defcolor = fdecl
fncolor = label
charcolor = '#878787'
number = fdecl
opcolor = '#ff5f00'
prproccolor = '#875f5f'
specialcolor = '#5f875f'
tagcolor = classcolor
typecolor = label
membercolor = specialcolor
infocolor = foreground
constantcolor = number
stringcolor = charcolor
regexcolor = stringcolor

embdfgcolor = '#ffffff'
embdbgcolor = label

return {
  window:
    background: background
    status:
      font:
        bold: false
        italic: false

      color: foreground

      info: color: question
      warning: color: warning
      'error':
        color: errorfg
        background: errorbg

  editor:
    border_color: current
    divider_color: current

    header:
      background: background
      color: foreground
      font:
        bold: false
        italic: false

    footer:
      background: statusbg
      color: statusfg
      font:
        bold: false
        italic: false

    indicators:
      default:
        color: statusfg

      title:
        font:
          bold: false
          italic: false

      vi:
        color: comment

    caret:
      color: white
      width: 32

    current_line:
      background: current

    selection:
      foreground: selection

  highlights:
    search:
      style: highlight.ROUNDBOX
      color: yellow
      alpha: 120
      outline_alpha: 255

    search_secondary:
      style: highlight.COMPOSITIONTHICK
      color: '#fffce4'
      outline_alpha: 50

    list_selection:
      style: highlight.ROUNDBOX
      color: white
      outline_alpha: 100

    replace_strikeout:
      style: highlight.STRIKE
      color: yellow

  styles:

    default:
      :background
      color: foreground

    red: color: red
    green: color: green
    yellow: color: yellow
    blue: color: blue
    magenta: color: purple
    cyan: color: aqua

    popup:
      background: '#00346e'
      color: foreground

    comment:
      color: comment

    variable:
      color: variable

    label:
      color: label

    line_number:
      color: line_number
      :background

    key:
      color: key
      font: bold: false

    fdecl:
      color: fdecl
      font: bold: false

    keyword:
      color: keyword
      font: bold: false

    class:
      color: classcolor
      font: bold: false

    definition: color: defcolor

    function:
      color: fncolor
      font: bold: false

    char: color: charcolor
    number: color: numbercolor
    operator: color: opcolor
    preproc: color: prproccolor
    special: color: specialcolor
    tag: color: tagcolor
    type: color: typecolor
    member: color: membercolor
    info: color: infocolor

    constant:
      color: constantcolor

    string: color: stringcolor

    regex:
      color: regexcolor

    embedded:
      color: embdfgcolor
      background: embdbgcolor
      eol_filled: true

    -- Markup and visual styles

    error:
      font: italic: true
      color: white
      background: darkred

    warning:
      font: italic: true
      color: orange

    list_highlight:
      color: white
      underline: true

    indentguide:
      :background
      color: foreground

    bracelight:
      color: foreground
      background: '#0064b1'

    bracebad:
      color: red

    h1:
      color: key
      font:
        bold: true
        italic: true

    h2:
      color: foreground
      font:
        bold: true

    h3:
      color: foreground
      background: current
      font:
        italic: true

    emphasis:
      font:
        bold: false
        italic: true

    strong:
      font:
        bold: true

    link_label: color: keyword
    link_url: color: comment

    table:
      color: blue
      background: embedded_bg
      underline: true

    addition: color: green
    deletion: color: red
    change: color: yellow
  }
