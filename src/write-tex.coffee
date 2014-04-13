
############################################################################################################
# njs_util                  = require 'util'
njs_fs                    = require 'fs'
njs_path                  = require 'path'
#...........................................................................................................
BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
TEXT                      = require 'coffeenode-text'
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
          if page_nr < 3 # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
        x_position = '90mm'
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
# @main() unless module.parent?


# OPTIONS = require 'coffeenode-options'
# TRM.dir OPTIONS

# info OPTIONS.get_app_info()
# info OPTIONS.get_app_options()

# BAP                       = require 'coffeenode-bitsnpieces'

# d =
#   'flowers': [ 'roses', 'dandelion', 'tulip', ]
#   'foo':    42
#   'bar':    108
#   'deep':
#     'one':    1
#     'two':    2
#     'three':
#       'four':   4


# debug d
# info BAP.container_and_facet_from_locator d, '/foo'
# info BAP.container_and_facet_from_locator d, '/bar'
# info BAP.container_and_facet_from_locator d, '/deep'
# info BAP.container_and_facet_from_locator d, '/deep/one'
# info BAP.container_and_facet_from_locator d, '/deep/two'
# info BAP.container_and_facet_from_locator d, '/deep/three'
# info BAP.container_and_facet_from_locator d, '/deep/three/four'
# try
#   info BAP.container_and_facet_from_locator d, '/deep/three/four/bar'
#   throw new Error "missing error"
# catch error
#   log TRM.green error[ 'message' ]
#   log TRM.green 'OK'
# try
#   info BAP.container_and_facet_from_locator d, '/deep/four/bar'
#   throw new Error "missing error"
# catch error
#   log TRM.green error[ 'message' ]
#   log TRM.green 'OK'




# # d = CJSON.load njs_path.join BAP.get_app_home(), 'options.json'
# options = require njs_path.join BAP.get_app_home(), 'options.json'
# debug options
# info BAP.walk_containers_crumbs_and_values options, ( error, container, crumbs, value ) ->
#   throw error if error?
#   if crumbs is null
#     log 'over'
#     return
#   log '',
#     ( TRM.gold '/' + ( crumbs.join '/' ) )
#     # ( TRM.grey container )
#     ( TRM.lime rpr value )

# d =
#   meaningless: [
#     42
#     43
#     { foo: 1, bar: 2, nested: [ 'a', 'b', ] }
#     45 ]
#   deep:
#     down:
#       in:
#         a:
#           drawer:   'a pen'
#           cupboard: 'a pot'
#           box:      'a pill'

# BAP.walk_containers_crumbs_and_values d, ( error, container, crumbs, value ) ->
#   throw error if error?
#   if crumbs is null
#     log 'over'
#     return
#   locator           = '/' + crumbs.join '/'
#   # in case you want to mutate values in a container, use:
#   [ head..., key, ] = crumbs
#   log "#{locator}:", rpr value
#   # debug rpr key
#   if key is 'box'
#     container[ 'addition' ] = 'yes!'
#     debug container

# info d

# locators = [
#   '/meaningless/0'
#   '/meaningless/1'
#   '/meaningless/2/foo'
#   '/meaningless/2/bar'
#   '/meaningless/2/nested/0'
#   '/meaningless/2/nested/1'
#   '/meaningless/3'
#   '/deep/down/in/a/drawer'
#   '/deep/down/in/a/cupboard'
#   '/deep/down/in/a/box'
# ]

# for locator in locators
#   [ container
#     key
#     value     ] = BAP.container_and_facet_from_locator d, locator
#   info locator, ( TRM.grey locator ), ( TRM.gold key ), rpr value

# # log BAP.container_and_facet_from_locator 42, '/'

# #-----------------------------------------------------------------------------------------------------------
# compile_options = ( options ) ->
#   #---------------------------------------------------------------------------------------------------------
#   BAP.walk_containers_crumbs_and_values options, ( error, container, crumbs, value ) =>
#     throw error if error?
#     if crumbs is null
#       log 'over'
#       return
#     locator           = '/' + crumbs.join '/'
#     [ ..., key ]      = crumbs
#     return null unless TYPES.isa_text value
#     #-------------------------------------------------------------------------------------------------------
#     TEXT.fill_in value, ( error, fill_in_key, format ) =>
#       throw error if error?
#       return null unless key?
#       debug locator, key, value, fill_in_key, format

# info options
# compile_options options

# matcher = TEXT.fill_in.get_matcher()
# templates = [
#   'foo bar baz'
#   'foo $bar baz'
#   'foo ${bar} baz'
#   'foo ${bar/x/y} baz'
#   'foo ${bar/x/y} $month baz'
#   'foo ${bar/x/y/$month}  baz'
#   '$foo bar baz'
#   ]

# for template in templates
#   match = template.match matcher
#   if match?
#     [ ignored
#       prefix
#       markup
#       bare
#       bracketed
#       tail      ] = match
#     ### TAINT not correct ###
#     activator_length = 1
#     #.......................................................................................................
#     if bare?
#       name          = bare
#       ### TAINT not correct ###
#       opener_length = 1
#       closer_length = 1
#     else
#       name          = bracketed
#       opener_length = 0
#       closer_length = 0
#     #.......................................................................................................
#     log TRM.gold template
#     log TRM.plum template.replace matcher, ( ignored, prefix, markup, bare, bracketed, tail ) ->
#       return prefix + ( ( new Array markup.length + 1 ).join '_' ) + tail
#     log TRM.red TEXT.fill_in template, {}
#     info match[ 1 .. ]
#   else
#     whisper template

d =
  meaningless: [
    42
    43
    { foo: 1, bar: 2, nested: [ 'a', 'b', ] }
    45 ]
  deep:
    down:
      in:
        a:
          drawer:   '${/my-things/pen}'
          cupboard: '${/my-things/pot}'
          box:      '${${locations/for-things}/variable}'
  'my-things':
    pen:      'a pen'
    pot:      'a pot'
    pill:     'a pill'
    variable: '${/my-things/pill}'
  locations:
    'for-things':   '/my-things'
  ping1:      '${/ping4}'
  ping2:      '${/ping3}'
  ping3:      '${/ping2}'
  ping4:      '${/ping1}'
  pong:       '${/ping1}'

#   '/meaningless/3'
#   '/deep/down/in/a/drawer'


TEXT.fill_in.container d
debug d


############################################################################################################
# @options = CJSON.load njs_path.join BAP.get_app_home(), 'options.json'
# info BAP.compile_options @options

# info '$foo'.match BAP.compile_options.name_re

# options =
#   'columns': []
#   'moon-symbols':
#     'unicode': [ '⬤', '◐', '◯', '◑', ]
#     'tex':    [
#       '\\newmoon'
#       '\\rightmoon'
#       '\\fullmoon'
#       '\\leftmoon' ]
#   'weekday-names':
#     'dutch':
#       'full':         [ 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag', 'zondag', ]
#       'abbreviated':  [ 'ma', 'di', 'wo', 'do', 'vr', 'za', 'zo', ]
#   'month-names':
#     'dutch':
#       'full':         [ 'januari', 'februari', 'maart', 'april', 'mei', 'juni',
#                         'juli', 'augustus', 'september', 'oktober', 'november', 'december', ]
#       'abbreviated':  [ 'jan', 'feb', 'maart', 'apr', 'mei', 'juni',
#                         'juli', 'aug', 'sept', 'oct', 'nov', 'dec', ]


# echo JSON.stringify options, null, '  '

# debug JSON.parse """{ "foo": "bar", "deep": [ { "zero": true }, 1,2,3] }""", ( key, value ) ->
#   info @, key#, value
#   return value



