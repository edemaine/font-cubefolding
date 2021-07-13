window?.onload = ->
  app = new FontWebappSVG
    root: '#output'
    rootSVG: '#svg'
    margin: 50
    charKern: 50
    lineKern: 100
    spaceWidth: 100
    renderChar: (char, state, group) ->
      char = char.toUpperCase()
      return unless char of window.font
      glyph = window.font[char]
      use = group.use()
      .attr 'href', "#fu-#{char}"
      element: use
      width: glyph.width
      height: glyph.height

  document.getElementById 'downloadSVG'
  .addEventListener 'click', -> app.downloadSVG 'cubefolding.svg'
