#!/usr/bin/coffee
fs = require 'fs'
path = require 'path'
stringify = require 'json-stringify-pretty-compact'
#stringify = JSON.stringify

dir = 'slit'
scale = 100

outSVG = []
symbols = {}
symbolIds = {}
font = {}
for file in fs.readdirSync dir
  match = /^font_(.)\.svg$/.exec file
  continue unless match?
  letter = match[1].toUpperCase()

  map = {}
  svg = fs.readFileSync path.join(dir, file), encoding: 'utf8'
  .replace /<\?[^<>]*\?>\n/, ''
  .replace /<![^<>]*>\n/, ''
  .replace /^ *<symbol id="([^"]*)"([^<>/]*(?:\/>|>[^]*?<\/symbol>)\n)/mg,
    (symbol, id, tail) ->
      oldId = id
      tail = tail.replace /^  /mg, ''
      unless tail of symbols
        while id of symbolIds
          id = id.replace /[0-9]*$/, (val) -> 1 + parseInt val
        symbolIds[id] = true
        symbols[tail] = id
      map[oldId] = symbols[tail]
      ''
  .replace /\bhref="#([^"]*)"/g, (href, id) ->
    "href=\"##{map[id]}\""
  .replace /<svg[^<>]*>/, "<symbol id=\"fu-#{letter}\" overflow=\"visible\">"
  .replace /<\/svg>/, '</symbol>'
  outSVG.push svg

  asc = fs.readFileSync path.join(dir, file.replace /\.svg$/, '.asc'), encoding: 'utf8'
  width = (asc.split('\n')[0].length - 1) // 2 * scale
  height = 5 * scale
  font[letter] = {width, height}

outSVG.unshift (
  for tail, id of symbols
    """<symbol id="#{id}"#{tail}"""
).join ''

fs.writeFileSync 'font-inline.svg', outSVG.join '\n'
fs.writeFileSync 'font.js', "window.font = #{stringify font};\n"
console.log "Wrote font-inline.svg and font.js with #{(x for x of font).length} symbols"
