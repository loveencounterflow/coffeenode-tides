
############################################################################################################
# njs_util                  = require 'util'
njs_fs                    = require 'fs'
njs_path                  = require 'path'
#...........................................................................................................
# BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
# FS                        = require 'coffeenode-fs'
rpr                       = TRM.rpr.bind TRM
badge                     = 'TIDES/write-tex'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
#...........................................................................................................
eventually                = process.nextTick
# XDate                     = require 'xdate'
TEX                       = require 'jizura-xelatex'
TIDES                     = require './main'
@draw_curves_with_hobby   = require './draw-curves-with-gm'
#...........................................................................................................
read = ( route ) ->
  return njs_fs.readFileSync ( njs_path.join __dirname, route ), encoding: 'utf-8'
#...........................................................................................................
preamble                  = read '../tex-inputs/preamble.tex'
postscript                = read '../tex-inputs/postscript.tex'

#===========================================================================================================
# TEX VOCABULARY
#-----------------------------------------------------------------------------------------------------------
leavevmode                = TEX.make_command 'leavevmode'
hbox                      = TEX.make_command 'hbox'
leading                   = TEX.make_command 'leading'
multicolumn               = TEX.make_multicommand 'multicolumn', 3
# fncrNG                    = TEX.make_multicommand 'fncrNG', 3
# fncrC                     = TEX.make_multicommand 'fncrC', 3
hrule                     = TEX.raw """\n\n\\hrule\n\n"""
hline                     = TEX.raw """\n\\hline\n"""
cline                     = TEX.make_command 'cline'
@new_tabular              = TEX.make_environment 'tabular'
next_line                 = TEX.raw '\\\\\n'
newline                   = TEX.raw '\n'
next_cell                 = TEX.raw ' & '
esc                       = TEX._escape.bind TEX
thinspace                 = TEX.raw '$\\thinspace$'
thinspace                 = '\u2009'
# thinspace                 = '\u200a'

#-----------------------------------------------------------------------------------------------------------
@moon_symbols =
  'unicode': [ '⬤', '◐', '◯', '◑', ]
  'plain':    [
    ( TEX.raw '\\newmoon'   ),
    ( TEX.raw '\\rightmoon' ),
    ( TEX.raw '\\fullmoon'  ),
    ( TEX.raw '\\leftmoon'  ), ]

#-----------------------------------------------------------------------------------------------------------
@weekday_names =
  'dutch':
    'full':         [ 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag', 'zondag', ]
    'abbreviated':  [ 'ma', 'di', 'wo', 'do', 'vr', 'za', 'zo', ]

#-----------------------------------------------------------------------------------------------------------
@month_names =
  'dutch':
    'full':         [ 'januari', 'februari', 'maart', 'april', 'mei', 'juni',
                      'juli', 'augustus', 'september', 'oktober', 'november', 'december', ]
    'abbreviated':  [ 'jan', 'feb', 'maart', 'apr', 'mei', 'juni',
                      'juli', 'aug', 'sept', 'oct', 'nov', 'dec', ]

#-----------------------------------------------------------------------------------------------------------
@get_month_name = ( month, language, style ) ->
  month = parseInt month, 10 unless TYPES.isa_number month
  R     = @month_names[ language ]?[ style ]?[ month - 1 ]
  #.........................................................................................................
  unless R?
    throw new Error "unable to understand month specification  #{rpr month}, #{rpr language}, #{rpr style}"
  #.........................................................................................................
  return R # .toUpperCase()

#-----------------------------------------------------------------------------------------------------------
@format_month = ( month ) ->
  # month = @get_month_name month, 'dutch', 'full'
  month = @get_month_name month, 'dutch', 'abbreviated'
  month = month[ 0 ].toUpperCase() + month[ 1 .. ]
  return TEX.new_group [
    TEX.new_command 'color', 'DarkRed'
    TEX.new_loner 'scFont'
    TEX.new_loner 'large'
    ' '
    month ]

#-----------------------------------------------------------------------------------------------------------
@new_row = ( table_row ) ->
  R   = TEX.new_container []
  #.........................................................................................................
  add = ( P ... ) ->
    TEX.push R, p for p in P
    return R
  #.........................................................................................................
  if table_row[ 'is-new-day' ]
    add cline '2-4'
  #.........................................................................................................
  if table_row[ 'day-change' ]
    add cline '5-5'
  #.........................................................................................................
  if ( moon_quarter = table_row[ 'moon-quarter' ] )?
    add @moon_symbols[ 'plain' ][ moon_quarter ]
  add next_cell
  #.........................................................................................................
  if table_row[ 'date' ]?
    day = table_row[ 'date' ][ 2 ]
    # day = '\\ ' + day if day.length is 1
    add TEX.new_group [
      TEX.new_loner 'itFont'
      day ]
    add '.'
    # add day, '.'
  add next_cell
  #.........................................................................................................
  if table_row[ 'date' ]?
    weekday_idx   = table_row[ 'weekday-idx' ]
    weekday_name  = @weekday_names[ 'dutch' ][ 'abbreviated' ][ weekday_idx ]
    ### TAINT use TeX commands for formatting ###
    switch weekday_idx
      when 6
        ### TAINT color repeated here ###
        add TEX.new_group [
          TEX.new_command 'color', 'DarkRed'
          TEX.new_loner 'itFont'
          weekday_name ]
      else
        add TEX.new_group [
          # TEX.new_command 'color', 'DarkRed',
          TEX.new_loner 'itFont'
          weekday_name ]
    # add ''
  add next_cell
  #.........................................................................................................
  if ( time = table_row[ 'hi-water-time' ] )?
    add time[ 0 ], thinspace, ':', thinspace, time[ 1 ]
  add next_cell
  #.........................................................................................................
  if ( time = table_row[ 'lo-water-time' ] )?
    add time[ 0 ], thinspace, ':', thinspace, time[ 1 ]
  add next_cell
  #.........................................................................................................
  add next_line
  return R

#-----------------------------------------------------------------------------------------------------------
@draw_curves = ( hi_dots, lo_dots, handler ) ->
  warn "`write-tex#draw_curves` must use options object; not yet implemented"
  return handler null, 'CURVES OMITTED'
  method = @[ "draw_curves_with_#{image_format}" ]
  throw new Error "unknown image format #{image_format}" unless method?
  method = method.bind @
  return method hi_dots, lo_dots, handler

# #-----------------------------------------------------------------------------------------------------------
# @draw_curves_with_gm = ( hi_dots, lo_dots ) ->
#   R = ''
#   for collection in [ hi_dots, lo_dots, ]
#     dots = []
#     debug '--------------------------------------------'
#     for [ idx, height ] in collection
#       debug [ height, idx ]
#   return R

#-----------------------------------------------------------------------------------------------------------
@draw_curves_with_hobby = ( hi_dots, lo_dots, handler ) ->
  ### Given the series for line indices and water level maxima and minima (in cm relative to LAT), return
  a LaTeX snippet to generate curves using the `hobby` package.

  **Note** This code is no longer maintained and has been left here for future reference only. It is
  somehwat slow and conceptually more difficult to get right than using the `gm` module; it also does not
  allow to easily cache results between runs, so all the computation has to be done on each run anew.
  It also violates the principle that computation-heavy stuff with complex logics should be done outside
  of LaTeX, which is not really built to do that kind of stuff. ###
  throw new Error """code no longer maintained; please read comments in
    `src/main.coffee#draw_curves_with_hobby` to learn why."""
  R = TEX.new_container []
  TEX.push R, TEX.raw "\\begin{tikzpicture}[scale=1,x=0.1mm,y=-1em]%\n"
  for collection in [ hi_dots, lo_dots, ]
    dots = []
    for [ idx, height ] in collection
      dot_txt = "(#{height},#{idx})"
      TEX.push R, TEX.raw "\\filldraw #{dot_txt} circle (1pt);%\n"
      dots.push dot_txt
    first_dot = dots.shift()
    last_dot  = dots.pop()
    TEX.push R, TEX.raw """\\draw #{first_dot} to
      [ curve through ={#{dots.join ' .. '}}]
      #{last_dot};"""
  TEX.push R, TEX.raw "\\end{tikzpicture}"
  return R

###
\multicolumn{3}{l}{{\color{DarkRed}\scFont\large Januari} 2014} & H & L & \\

\draw ([in angle=90, out angle=-90]99,1) to
[ curve through ={(109,2) .. (97,3) .. (114,4) .. (93,5) .. (119,6) .. (89,7) .. (121,8) .. (85,9) .. (121,10) .. (80,11) .. (117,12) .. (75,13) .. (110,14) .. (70,15) .. (100,16) .. (66,17) .. (89,18) .. (63,19) .. (80,20) .. (65,21) .. (77,22) .. (74,23) .. (79,24) .. (85,25) .. (82,26) .. (93,27) .. (81,28) .. (97,29) .. (79,30) .. (100,31) .. (79,32) .. (103,33) .. (79,34) .. (105,35) .. (79,36) .. (105,37) .. (77,38) .. (102,39) .. (74,40) .. (98,41) .. (70,42) .. (94,43) .. (67,44) .. (89,45) .. (64,46) .. (83,47) .. (61,48) .. (77,49) .. (62,50) .. (75,51) .. (72,52) .. (80,53) .. (86,54) .. (86,55) .. (99,56) .. (89,57) .. (109,58) .. (89,59) .. (115,60) .. (88,61) .. (119,62) .. (87,63) .. (121,64) .. (85,65) .. (119,66) .. (82,67) .. (112,68) .. (78,69) .. (101,70)}]
(72,71);
\draw ([in angle=90, out angle=-90]-106,0) to
[ curve through ={(-109,1) .. (-113,2) .. (-113,3) .. (-118,4) .. (-117,5) .. (-121,6) .. (-120,7) .. (-121,8) .. (-122,9) .. (-118,10) .. (-120,11) .. (-110,12) .. (-115,13) .. (-101,14) .. (-106,15) .. (-90,16) .. (-95,17) .. (-81,18) .. (-86,19) .. (-76,20) .. (-83,21) .. (-79,22) .. (-87,23) .. (-86,24) .. (-94,25) .. (-93,26) .. (-98,27) .. (-97,28) .. (-99,29) .. (-100,30) .. (-99,31) .. (-103,32) .. (-101,33) .. (-107,34) .. (-103,35) .. (-110,36) .. (-103,37) .. (-109,38) .. (-102,39) .. (-107,40) .. (-99,41) .. (-103,42) .. (-95,43) .. (-100,44) .. (-92,45) .. (-94,46) .. (-87,47) .. (-88,48) .. (-84,49) .. (-85,50) .. (-86,51) .. (-90,52) .. (-94,53) .. (-100,54) .. (-103,55) .. (-111,56) .. (-112,57) .. (-121,58) .. (-121,59) .. (-128,60) .. (-128,61) .. (-131,62) .. (-134,63) .. (-131,64) .. (-137,65) .. (-126,66) .. (-135,67) .. (-117,68) .. (-127,69)}]
(-105,70);

\multirow{10}{*}{%
\begin{tikzpicture}[scale=1,x=0.1mm,y=-3em]%
\filldraw (0,0) circle (1pt);%
\filldraw (-100,1) circle (1pt);%
\filldraw (100,2) circle (1pt);%
\filldraw (1,3) circle (1pt);%
\filldraw (3,4) circle (1pt);%
\filldraw (3,5) circle (1pt);%
\draw (0,0) to [ quick curve through ={(-100,1) .. (100,2) .. (1,3) .. (3,4)}] (3,5);%
\end{tikzpicture}} \\
###

#-----------------------------------------------------------------------------------------------------------
@main = ->
  route         = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  rows          = TEX.new_container []
  row_idx       = -1
  hi_dots       = []
  lo_dots       = []
  last_day      = null
  moon_quarter  = null
  wrote_header  = no
  echo preamble
  #---------------------------------------------------------------------------------------------------------
  TIDES.walk_table_rows route, ( error, table_row ) =>
    throw error if error?
    #.......................................................................................................
    if table_row is null
      # echo TEX.rpr @draw_curves hi_dots, lo_dots
      echo 'CURVES OMITTED'
      format = TEX.raw "{ r r l r q r | c | c | c }\n"
      echo TEX.rpr @new_tabular [ format, rows, ]
      echo postscript
      return
    #.......................................................................................................
    row_idx += 1
    #.......................................................................................................
    unless wrote_header
      year      = table_row[ 'date' ][ 0 ]
      month_tex = @format_month table_row[ 'date' ][ 1 ]
      # TEX.push rows, multicolumn [ 3, 'l', [ month_tex, year, ], ]
      TEX.push rows, multicolumn [ 3, 'l', TEX.new_container [ month_tex, ' ', year, ] ]
      TEX.push rows, next_cell
      TEX.push rows, 'H'
      TEX.push rows, next_cell
      TEX.push rows, multicolumn [ 1, 'r', 'L', ]
      TEX.push rows, next_cell
      TEX.push rows, next_line
      TEX.push rows, hline
      wrote_header = yes
    #.......................................................................................................
    if ( height = table_row[ 'hi-water-height' ] )?
      hi_dots.push [ row_idx, height, ]
    #.......................................................................................................
    if ( height = table_row[ 'lo-water-height' ] )?
      lo_dots.push [ row_idx, height, ]
    #.......................................................................................................
    if moon_quarter?
      table_row[ 'moon-quarter' ] = moon_quarter
      moon_quarter                = null
    #.......................................................................................................
    if last_day is table_row[ 'date' ][ 2 ]
      table_row[ 'is-new-day' ]   = no
      table_row[ 'date' ]         = null
      table_row[ 'weekday-idx' ]  = null
      #.....................................................................................................
      if table_row[ 'moon-quarter' ]?
        moon_quarter                = table_row[ 'moon-quarter' ]
        table_row[ 'moon-quarter' ] = null
      #.....................................................................................................
      else
        moon_quarter                = null
    #.......................................................................................................
    else
      table_row[ 'is-new-day' ]   = yes
      last_day                    = table_row[ 'date' ][ 2 ]
    #.......................................................................................................
    TEX.push rows, @new_row table_row

############################################################################################################
@main() unless module.parent?

# info TEX.rpr TEX.new_multicommand 'foo', 3, [ 'helo', 'world', '!' ]

# foo = TEX.make_multicommand 'foo', 3
# info foo [ 'helo', 'world', '!' ]
# info TEX.rpr foo [ 'helo', 'world', '!' ]





