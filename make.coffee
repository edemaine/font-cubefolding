#!/usr/bin/coffee

fs = require 'fs'
path = require 'path'

dir = 'slit'

out = []
for file in fs.readdirSync dir
  match = /^font_(.)\.svg$/.exec file
  continue unless match?
  letter = match[1]

  svg = fs.readFileSync path.join(dir, file), encoding: 'utf8'
  .replace /<\?[^<>]*\?>\n/, ''
  .replace /<![^<>]*>\n/, ''
  .replace /<svg\b/, "<svg id=\"fu-#{letter}\""
  out.push svg

fs.writeFileSync 'font-inline.svg', out.join '\n'
