
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
@_draw_curves_with_gm     = require './draw-curves-with-gm'
#...........................................................................................................
read = ( route ) ->
  return njs_fs.readFileSync ( njs_path.join __dirname, route ), encoding: 'utf-8'
#...........................................................................................................
preamble                  = read '../tex-inputs/preamble.tex'
postscript                = read '../tex-inputs/postscript.tex'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@_as_integer = ( hint ) ->
  return parseInt hint, 10


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
    '\\newmoon'
    '\\rightmoon'
    '\\fullmoon'
    '\\leftmoon' ]
    # ( TEX.raw '\\newmoon'   ),
    # ( TEX.raw '\\rightmoon' ),
    # ( TEX.raw '\\fullmoon'  ),
    # ( TEX.raw '\\leftmoon'  ), ]

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
@draw_curves = ( page_nr, dots, handler ) ->
  return @_draw_curves_with_gm page_nr, dots, handler

#-----------------------------------------------------------------------------------------------------------
@y_position_from_datetime = ( row_idx, time, module, unit = 'mm' ) ->
  ### TAINT use proper units datatype ###
  ### TAINT make prescision configurable ###
  value = ( row_idx + 1 ) * module
  value = value.toFixed 2
  return "#{value}#{unit}"

#-----------------------------------------------------------------------------------------------------------
@main = ->
  ### TAINT must parametrize data source ###
  route         = njs_path.join __dirname, '../tidal-data/Yerseke.txt'
  rows          = TEX.new_container []
  row_idx       = -1
  dots          = []
  page_nr       = 0
  last_day      = null
  last_month    = null
  last_year     = null
  moon_quarter  = null
  wrote_header  = no
  echo preamble
  #---------------------------------------------------------------------------------------------------------
  TIDES.walk_tidal_records route, ( error, trc ) =>
    throw error if error?
    # debug trc
    #.......................................................................................................
    if trc is null
      # echo TEX.rpr @draw_curves hi_dots, lo_dots
      echo postscript
      return
    #.......................................................................................................
    row_idx += 1
    this_date       = trc[ 'date' ]
    this_time       = trc[ 'time' ]
    [ this_year
      this_month
      this_day    ] = this_date
    # return null unless this_month is ' 1' # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    #.......................................................................................................
    unless wrote_header
      this_month_tex = @format_month this_month
      wrote_header = yes
    #.......................................................................................................
    if ( moon_quarter = trc[ 'moon-quarter' ] )?
      if moon_quarter is 0 or moon_quarter is 2
        ### TAINT collect these in a 'newpage' function ###
        row_idx   = 0
        page_nr  += 1
        #---------------------------------------------------------------------------------------------------
        do ( page_nr, dots ) =>
          #-------------------------------------------------------------------------------------------------
          if page_nr < 3
            ### TAINT asynchronous handling is missing ###
            info "drawing image #{page_nr}"
            route = njs_path.join '/tmp', "tides-p#{page_nr}.png"
            # echo """\\paTopLeft*{0mm}{0mm}{\\includegraphics[height=178mm]{#{route}}}"""
            echo """\\paTopLeft*{0mm}{0mm}{\\includegraphics[width=118mm]{#{route}}}"""
            @draw_curves route, dots, ( error ) =>
              info "image #{page_nr} ok"
              throw error if error?
        #---------------------------------------------------------------------------------------------------
        dots      = []
        echo """\\null\\newpage"""
    #.......................................................................................................
    ### TAINT measurements should be defined in options ###
    textheight  = 178 # mm
    line_count  = 62
    module      = textheight / line_count
    unit        = 'mm'
    y_position  = @y_position_from_datetime row_idx, this_time, module, unit
    #.......................................................................................................
    ### TAINT Unfortunate solution to again ask for moon quarter ###
    if moon_quarter?
      moon_symbol = @moon_symbols[ 'plain' ][ moon_quarter ]
      echo """\\paRight{10mm}{#{y_position}}{#{moon_symbol}}"""
    #.......................................................................................................
    unless last_day is this_day
      last_day  = this_day
      ### TAINT days y to be adjusted ###
      echo """\\paRight{20mm}{#{y_position}}{#{this_date[1]}-#{this_date[2]}}"""
    #.......................................................................................................
    unless last_month is this_month
      last_month = this_month
      echo """\\typeout{\\trmSolCyan{#{this_date.join '-'}}}"""
    #.......................................................................................................
    hl      = trc[ 'hl' ]
    height  = trc[ 'height' ]
    dots.push [ hl, [ height, dots.length, ], ]
    #.......................................................................................................
    switch hl
      when 'h'
        x_position = '40mm'
      when 'l'
        x_position = '55mm'
      else
        throw new Error "expected `h` or `l` for hl indicator, got #{rpr hl}"
    #.......................................................................................................
    ### TAINT use proper escaping ###
    dst = if trc[ 'is-dst' ] then '+' else ''
    echo """\\paRight{#{x_position}}{#{y_position}}{#{dst + this_time[0]} : #{this_time[1]}}"""




    # echo """\\begin{textblock*}{15mm}[1,0.5](130mm,#{y_position})\\flushright —\\end{textblock*}"""

    #   # TEX.push rows, multicolumn [ 3, 'l', [ month_tex, year, ], ]
    #   TEX.push rows, multicolumn [ 3, 'l', TEX.new_container [ month_tex, ' ', year, ] ]
    #   TEX.push rows, next_cell
    #   TEX.push rows, 'H'
    #   TEX.push rows, next_cell
    #   TEX.push rows, multicolumn [ 1, 'r', 'L', ]
    #   TEX.push rows, next_cell
    #   TEX.push rows, next_line
    #   TEX.push rows, hline
    # #.......................................................................................................
    # if ( height = trc[ 'hi-water-height' ] )?
    #   hi_dots.push [ row_idx, height, ]
    # #.......................................................................................................
    # if ( height = trc[ 'lo-water-height' ] )?
    #   lo_dots.push [ row_idx, height, ]
    # #.......................................................................................................
    # if moon_quarter?
    #   trc[ 'moon-quarter' ] = moon_quarter
    #   moon_quarter                = null
    # #.......................................................................................................
    # if last_day is trc[ 'date' ][ 2 ]
    #   trc[ 'is-new-day' ]   = no
    #   trc[ 'date' ]         = null
    #   trc[ 'weekday-idx' ]  = null
    #   #.....................................................................................................
    #   if trc[ 'moon-quarter' ]?
    #     moon_quarter                = trc[ 'moon-quarter' ]
    #     trc[ 'moon-quarter' ] = null
    #   #.....................................................................................................
    #   else
    #     moon_quarter                = null
    # #.......................................................................................................
    # else
    #   trc[ 'is-new-day' ]   = yes
    #   last_day                    = trc[ 'date' ][ 2 ]
    # #.......................................................................................................
    # TEX.push rows, @new_row trc

############################################################################################################
@main() unless module.parent?

# info TEX.rpr TEX.new_multicommand 'foo', 3, [ 'helo', 'world', '!' ]

# foo = TEX.make_multicommand 'foo', 3
# info foo [ 'helo', 'world', '!' ]
# info TEX.rpr foo [ 'helo', 'world', '!' ]






