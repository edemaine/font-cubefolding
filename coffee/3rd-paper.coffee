fs = require 'fs'
path = require 'path'

#gridWidth = 1
#normalWidth = 3
#innerWidth = 3
#outerWidth = 8

gridWidth = 2.5
normalWidth = 5
innerWidth = 5
outerWidth = 2*normalWidth + innerWidth
outerHalf = (outerWidth - innerWidth) / 2

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
  <symbol viewBox="0 0 0 0" z-index="20">
    {if cut.call(@neighbor -1, 0)
      <line x1={-outerWidth} stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>}
    {if cut.call(@neighbor +1, 0)
      <line x1={outerWidth} stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>}
    {if cut.call(@neighbor 0, -1)
      <line y1={-outerWidth} stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>}
    {if cut.call(@neighbor 0, 1)
      <line y1={outerWidth} stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>}
    # T to outside
    {if not fold.call(@neighbor -1, 0) and not @neighbor(-1, 0).includes('-') and cut.call(@neighbor 1, 0) and @neighbor(0, 1).includes('|') and @neighbor(0, -1).includes('|')
      <>
        <line x1={-outerWidth} x2="1" stroke="white" stroke-width={innerWidth} stroke-linecap="square"/>
        <line x1={-innerWidth} x2={-innerWidth} y1={-outerWidth/2} y2={outerWidth/2} stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
      </>
    }
    {if not fold.call(@neighbor 1, 0) and not @neighbor(1, 0).includes('-') and cut.call(@neighbor -1, 0) and @neighbor(0, 1).includes('|') and @neighbor(0, -1).includes('|')
      <>
        <line x1={outerWidth} x2="-1" stroke="white" stroke-width={innerWidth} stroke-linecap="square"/>
        <line x1={innerWidth} x2={innerWidth} y1={-outerWidth/2} y2={outerWidth/2} stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
      </>
    }
    {if not fold.call(@neighbor 0, -1) and not @neighbor(0, -1).includes('|') and cut.call(@neighbor 0, 1) and @neighbor(1, 0).includes('-') and @neighbor(-1, 0).includes('-')
      <>
        <line y1={-outerWidth} y2="1" stroke="white" stroke-width={innerWidth} stroke-linecap="square"/>
        <line y1={-innerWidth} y2={-innerWidth} x1={-outerWidth/2} x2={outerWidth/2} stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
      </>
    }
    {if not fold.call(@neighbor 0, 1) and not @neighbor(0, 1).includes('|') and cut.call(@neighbor 0, -1) and @neighbor(1, 0).includes('-') and @neighbor(-1, 0).includes('-')
      <>
        <line y1={outerWidth} y2="-1" stroke="white" stroke-width={innerWidth} stroke-linecap="square"/>
        <line y1={innerWidth} y2={innerWidth} x1={-outerWidth/2} x2={outerWidth/2} stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
      </>
    }
    # Corner to outside
    {if (cut.call(@neighbor -1, 0) or cut.call(@neighbor 0, 1)) and @neighbor(0, -1).includes('|') and @neighbor(1, 0).includes('-') and not cut.call(@neighbor 0, -1) and not cut.call(@neighbor 1, 0)
      <>
        <line x1={outerWidth} y1={-outerWidth} x2="0" y2="0" stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
        <rect x={normalWidth/2} y={-normalWidth/2-outerHalf} width={outerHalf} height={outerHalf} fill="white"/>
      </>
    }
    {if (cut.call(@neighbor 1, 0) or cut.call(@neighbor 0, 1)) and @neighbor(0, -1).includes('|') and @neighbor(-1, 0).includes('-') and not cut.call(@neighbor 0, -1) and not cut.call(@neighbor -1, 0)
      <>
        <line x1={-outerWidth} y1={-outerWidth} x2="0" y2="0" stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
        <rect x={-normalWidth/2-outerHalf} y={-normalWidth/2-outerHalf} width={outerHalf} height={outerHalf} fill="white"/>
      </>
    }
    {if (cut.call(@neighbor -1, 0) or cut.call(@neighbor 0, -1)) and @neighbor(0, 1).includes('|') and @neighbor(1, 0).includes('-') and not cut.call(@neighbor 0, 1) and not cut.call(@neighbor 1, 0)
      <>
        <line x1={outerWidth} y1={outerWidth} x2="0" y2="0" stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
        <rect x={normalWidth/2} y={normalWidth/2} width={outerHalf} height={outerHalf} fill="white"/>
      </>
    }
    {if (cut.call(@neighbor 1, 0) or cut.call(@neighbor 0, -1)) and @neighbor(0, 1).includes('|') and @neighbor(-1, 0).includes('-') and not cut.call(@neighbor 0, 1) and not cut.call(@neighbor -1, 0)
      <>
        <line x1={-outerWidth} y1={outerWidth} x2="0" y2="0" stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
        <rect x={-normalWidth/2-outerHalf} y={normalWidth/2} width={outerHalf} height={outerHalf} fill="white"/>
      </>
    }
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
    <symbol viewBox="0 0 100 0" overflowBox={[0, -outerWidth/2, 100, outerWidth].join ' '} z-index="10">
      <line x2="100" stroke="black" stroke-width={outerWidth} stroke-linecap="round"/>
      <line x2="100" stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
    </symbol>
  else
    <symbol viewBox="0 0 100 0" overflowBox={[-normalWidth/2, -normalWidth/2, 100+normalWidth, normalWidth].join ' '} z-index="10">
      <line x2="100" stroke="black" stroke-width={normalWidth} stroke-linecap="round"/>
    </symbol>

lineV = ->
  #lineH.call @
  #.replace /x2=/g, 'y2='
  #.replace /Box="([\-.\d]+) ([\-.\d]+) ([\-.\d]+) ([\-.\d]+)"/g, 'Box="$2 $1 $4 $3"'
  if cut.call @
    <symbol viewBox="0 0 0 100" overflowBox={[-outerWidth/2, 0, outerWidth, 100].join ' '} z-index="10">
      <line y2="100" stroke="black" stroke-width={outerWidth} stroke-linecap="round"/>
      <line y2="100" stroke="white" stroke-width={innerWidth} stroke-linecap="round"/>
    </symbol>
  else
    <symbol viewBox="0 0 0 100" overflowBox={[-normalWidth/2, -normalWidth/2, normalWidth, 100+normalWidth].join ' '} z-index="10">
      <line y2="100" stroke="black" stroke-width={normalWidth} stroke-linecap="round"/>
    </symbol>

pixel =
  #<rect width="100" height="100" fill="#ddd" stroke="#939393"/>
  <symbol viewBox="0 0 100 100">
    <rect width="100" height="100" fill="#ddd" stroke="#939393" stroke-width={gridWidth}/>
  </symbol>

hole =
  <symbol viewBox="0 0 100 100">
    <rect width="100" height="100" fill="white" stroke="#cccccc"/>
  </symbol>
    #{readSVG 'scissors.svg'}

blank = ->
  row = @row().some (x) -> x.includes '+'
  col = @column().some (x) -> x.includes '+'
  #if @neighbor(-1, 0).includes('+') or @neighbor(+1, 0).includes('+')
  if row and not col
    <symbol viewBox="0 0 100 0"/>
  #else if @neighbor(0, -1).includes('+') or @neighbor(0, +1).includes('+')
  else if col and not row
    <symbol viewBox="0 0 0 100"/>
  #else if (@column().some (x) -> x.includes '#') and (@row().some (x) -> x.includes '#')
  else if not row and not col
    <symbol viewBox="0 0 100 100"/>
  else
    ''

'+': corner
'-': lineH
'|': lineV
'#': pixel
'H': hole
' ': blank
