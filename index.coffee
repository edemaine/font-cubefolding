letterURL = (letter) ->
  "#fu-#{letter}"

window?.onload = ->
  app = new FontWebappSVG
    root: '#output'
    rootSVG: '#svg'
    margin: 50
    charKern: 50
    lineKern: 100
    spaceWidth: 100
    renderChar: (char, state) ->
      char = char.toUpperCase()
      return unless char of window.font
      glyph = window.font[char]
      use = @renderGroup.use()
      .attr 'href', "#fu-#{char}"
      element: use
      width: glyph.width
      height: glyph.height
