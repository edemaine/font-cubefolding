#!/usr/bin/coffee
fs = require 'fs'
path = require 'path'
stringify = require 'json-stringify-pretty-compact'
#stringify = JSON.stringify

dir = 'slit'
scale = 100

outSVG = []
data = {}
for file in fs.readdirSync dir
  match = /^font_(.)\.svg$/.exec file
  continue unless match?
  letter = match[1].toUpperCase()

  svg = fs.readFileSync path.join(dir, file), encoding: 'utf8'
  .replace /<\?[^<>]*\?>\n/, ''
  .replace /<![^<>]*>\n/, ''
  .replace /<svg\b/, "<svg id=\"fu-#{letter}\""
  outSVG.push svg

  asc = fs.readFileSync path.join(dir, file.replace /\.svg$/, '.asc'), encoding: 'utf8'
  width = (asc.split('\n')[0].length - 1) // 2 * scale
  height = 5 * scale
  data[letter] = {width, height}

fs.writeFileSync 'font-inline.svg', outSVG.join '\n'
fs.writeFileSync 'font.js', "window.font = #{stringify data};\n"
