eraseWidth = 5
borderWidth = 4
outerWidth = eraseWidth + 2 * borderWidth

fs = require 'fs'
path = require 'path'

readSVG = (filename) ->
  filename = path.join __dirname, filename
  fs.readFileSync filename, encoding: 'utf8'
  .replace /[^]*?<svg/, '<svg'

neighborCount = (sub) ->
  @neighbor(+1, 0).includes(sub) +
  @neighbor(-1, 0).includes(sub) +
  @neighbor(0, +1).includes(sub) +
  @neighbor(0, -1).includes(sub)

degree = ->
  neighborCount.call(@, '-') + neighborCount.call(@, '|')

corner = ->
  #<circle r="4" fill="black"/>
  #<circle r="1.5" fill="white"/>
  diff = outerWidth - eraseWidth
  <symbol viewBox="0 0 0 0" overflowBox="#{-diff} #{-diff} #{2*diff} #{2*diff}" style="overflow: visible; z-index: 20">
    {if cut.call(@neighbor -1, 0)
      <line x1={-diff} stroke="white" stroke-width={eraseWidth} stroke-linecap="round"/>}
    {if cut.call(@neighbor +1, 0)
      <line x1={diff} stroke="white" stroke-width={eraseWidth} stroke-linecap="round"/>}
    {if cut.call(@neighbor 0, -1)
      <line y1={-diff} stroke="white" stroke-width={eraseWidth} stroke-linecap="round"/>}
    {if not fold.call(@neighbor(-1, 0)) and cut.call(@neighbor 1, 0) and @neighbor(0, 1).includes('|') and @neighbor(0, -1).includes('|')
      <>
        <line x1={-diff} x2="1" stroke="white" stroke-width={eraseWidth} stroke-linecap="square"/>
        <line x1={-(borderWidth+eraseWidth)/2} x2={-(borderWidth+eraseWidth)/2} y1={-diff} y2={diff} stroke="white" stroke-width={eraseWidth} stroke-linecap="round"/>
      </>}
    {if not fold.call(@neighbor(1, 0)) and cut.call(@neighbor -1, 0) and @neighbor(0, 1).includes('|') and @neighbor(0, -1).includes('|')
      <>
        <line x1={diff} x2="-1" stroke="white" stroke-width={eraseWidth} stroke-linecap="square"/>
        <line x1={(borderWidth+eraseWidth)/2} x2={(borderWidth+eraseWidth)/2} y1={-diff} y2={diff} stroke="white" stroke-width={eraseWidth} stroke-linecap="round"/>
      </>}
    {if not fold.call(@neighbor(0, -1)) and cut.call(@neighbor 0, 1) and @neighbor(1, 0).includes('-') and @neighbor(-1, 0).includes('-')
      <>
        <line y1={-diff} y2="1" stroke="white" stroke-width={eraseWidth} stroke-linecap="square"/>
        <line y1={-(borderWidth+eraseWidth)/2} y2={-(borderWidth+eraseWidth)/2} x1={-diff} x2={diff} stroke="white" stroke-width={eraseWidth} stroke-linecap="round"/>
      </>}
    {if not fold.call(@neighbor(0, 1)) and cut.call(@neighbor 0, -1) and @neighbor(1, 0).includes('-') and @neighbor(-1, 0).includes('-')
      <>
        <line y1={diff} y2="-1" stroke="white" stroke-width={eraseWidth} stroke-linecap="square"/>
        <line y1={(borderWidth+eraseWidth)/2} y2={(borderWidth+eraseWidth)/2} x1={-diff} x2={diff} stroke="white" stroke-width={eraseWidth} stroke-linecap="round"/>
      </>}
  </symbol>

fold = ->
  (@neighbor(0, -1).includes('#') and @neighbor(0, +1).includes('#')) or
  (@neighbor(-1, 0).includes('#') and @neighbor(+1, 0).includes('#'))

cut = ->
  if @includes '-'
    @neighbor(0, -1).includes('#') and @neighbor(0, +1).includes('#')
  else if @includes '|'
    @neighbor(-1, 0).includes('#') and @neighbor(+1, 0).includes('#')
  else
    false

lineH = ->
  if cut.call @
    """
      <symbol viewBox="0 0 100 0" overflowBox="#{-outerWidth/2} #{-outerWidth/2} #{100+outerWidth} #{outerWidth}" style="overflow: visible; z-index: 10">
        <line x2="100" stroke="black" stroke-width="#{outerWidth}" stroke-linecap="round"/>
        <line x2="100" stroke="white" stroke-width="#{eraseWidth}" stroke-linecap="round"/>
      </symbol>
    """
  else
    """
      <symbol viewBox="0 0 100 0" overflowBox="#{-borderWidth/2} #{-borderWidth/2} #{100+borderWidth} #{borderWidth}" style="overflow: visible; z-index: 10">
        <line x2="100" stroke="black" stroke-width="#{borderWidth}" stroke-linecap="round"/>
      </symbol>
    """

lineV = ->
  lineH.call @
  .replace /x2=/g, 'y2='
  .replace /Box="([\-.\d]+) ([\-.\d]+) ([\-.\d]+) ([\-.\d]+)"/g, 'Box="$2 $1 $4 $3"'

pixel =
  #   <rect width="100" height="100" fill="white" stroke="#939393"/>
  #   #{readSVG 'momath_logo.svg'}
  """
    <symbol viewBox="0 0 100 100">
      <rect width="100" height="100" fill="#ddd" stroke="#939393"/>
    </symbol>
  """

hole =
  #   <rect width="100" height="100" fill="#cccccc" stroke="#cccccc"/>
  #   #{readSVG 'scissors.svg'}
  """
    <symbol viewBox="0 0 100 100">
      <rect width="100" height="100" fill="white" stroke="white"/>
    </symbol>
  """

blank = ->
  row = @row().some (x) -> x.includes '+'
  col = @column().some (x) -> x.includes '+'
  #if @neighbor(-1, 0).includes('+') or @neighbor(+1, 0).includes('+')
  if row and not col
    '<symbol viewBox="0 0 100 0"/>'
  #else if @neighbor(0, -1).includes('+') or @neighbor(0, +1).includes('+')
  else if col and not row
    '<symbol viewBox="0 0 0 100"/>'
  #else if (@column().some (x) -> x.includes '#') and (@row().some (x) -> x.includes '#')
  else if not row and not col
    '<symbol viewBox="0 0 100 100"/>'
  else
    ''

'+': corner
'-': lineH
'|': lineV
'#': pixel
'H': hole
' ': blank
