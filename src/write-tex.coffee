
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
# eventually                = process.nextTick
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
# TEX VOCABULARY
#-----------------------------------------------------------------------------------------------------------
leavevmode                = TEX.make_command 'leavevmode'
hbox                      = TEX.make_command 'hbox'
leading                   = TEX.make_command 'leading'
multicolumn               = TEX.make_multicommand 'multicolumn', 3
paLeft                    = TEX.make_multicommand 'paLeft', 3
paCenter                  = TEX.make_multicommand 'paCenter', 3
paRight                   = TEX.make_multicommand 'paRight', 3
paLeftGauge               = TEX.make_multicommand 'paLeftGauge', 3
paCenterGauge             = TEX.make_multicommand 'paCenterGauge', 3
paRightGauge              = TEX.make_multicommand 'paRightGauge', 3
# hrule                     = TEX.raw """\n\n\\hrule\n\n"""
# hline                     = TEX.raw """\n\\hline\n"""
# cline                     = TEX.make_command 'cline'
# @new_tabular              = TEX.make_environment 'tabular'
# next_cell                 = TEX.raw ' & '
# next_line                 = TEX.raw '\\\\\n'
newline                   = TEX.raw '\n'
esc                       = TEX._escape.bind TEX
# thinspace                 = TEX.raw '$\\thinspace$'
thinspace                 = '\u2009'
# thinspace                 = '\u200a'



#-----------------------------------------------------------------------------------------------------------
@format_month_name = ( date ) ->
  ### TAINT make formats configurable ###
  month_name = date.format 'MMMM'
  month_name = month_name[ 0 ].toUpperCase() + month_name[ 1 .. ]
  #.........................................................................................................
  # echo """\\paTopLeft*{0mm}{0mm}{\\includegraphics[width=118mm]{#{route}}}"""
  ### TAINT inefficient to retrieve each time; options should use cache ###
  align_x     = TIDES.options.get '/values/layout/month/odd/align/x'
  align_y     = TIDES.options.get '/values/layout/month/odd/align/y'
  position_x  = ( TIDES.options.get '/values/layout/month/odd/position/x' ) + 'mm'
  position_y  = ( TIDES.options.get '/values/layout/month/odd/position/y' ) + 'mm'
  #.........................................................................................................
  switch alignment = align_x
    when 'left'   then pa_command = paLeftGauge
    when 'center' then pa_command = paCenterGauge
    when 'right'  then pa_command = paRightGauge
    else throw new Error "unknown alignment #{rpr alignment}"
  #.........................................................................................................
  content = TEX.new_group [
    TEX.new_loner 'scFont'
    TEX.new_loner 'large'
    TEX.new_command 'color', 'DarkRed'
    month_name ]
  return pa_command [ position_x, position_y, content, ]

#-----------------------------------------------------------------------------------------------------------
@draw_curves = ( page_nr, dots, handler ) ->
  return @_draw_curves_with_gm page_nr, dots, handler

#-----------------------------------------------------------------------------------------------------------
@_y_position_from_row_idx = ( row_idx, module, unit = 'mm' ) ->
  ### TAINT make configurable ###
  ### TAINT use proper units datatype ###
  value = ( row_idx + 1 ) * module
  value = value.toFixed 2
  return "#{value}#{unit}"

#-----------------------------------------------------------------------------------------------------------
@main = ->
  ### TAINT must parametrize data source ###
  route         = njs_path.join __dirname, '../tidal-data/Yerseke.txt'
  # route         = njs_path.join __dirname, '../tidal-data/Harlingen-2014-hl.txt'
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
  TIDES.walk route, ( error, tide_event ) =>
    throw error if error?
    #.......................................................................................................
    if tide_event is null
      # echo TEX.rpr @draw_curves hi_dots, lo_dots
      echo postscript
      return
    #.......................................................................................................
    row_idx      += 1
    moon_event    = tide_event[ 'moon' ]
    date          = tide_event[ 'date' ]
    this_day      = date.date()
    this_month    = date.month()
    moon_quarter  = if moon_event? then moon_event[ 'quarter' ] else null
    #.......................................................................................................
    unless wrote_header
      this_month_tex = @format_month_name date
      echo TEX.rpr this_month_tex
      wrote_header = yes
    #.......................................................................................................
    if moon_quarter is 0 or moon_quarter is 2
      ### TAINT collect these in a 'newpage' function ###
      row_idx   = 0
      page_nr  += 1
      #---------------------------------------------------------------------------------------------------
      do ( page_nr, dots ) =>
        #-------------------------------------------------------------------------------------------------
        if page_nr < 5 # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
    y_position  = @_y_position_from_row_idx row_idx, module, unit
    #.......................................................................................................
    ### TAINT Unfortunate solution to again ask for moon quarter ###
    if moon_quarter?
      moon_symbol = TIDES.options.get "/values/moon/#{moon_quarter}"
      echo """\\paRight{10mm}{#{y_position}}{#{moon_symbol}}"""
    #.......................................................................................................
    unless last_day is this_day
      last_day  = this_day
      ### TAINT days y to be adjusted ###
      month_txt = date.format 'MM'
      day_txt   = date.format 'DD'
      echo """\\paRight{20mm}{#{y_position}}{#{month_txt}-#{day_txt}}"""
    #.......................................................................................................
    unless last_month is this_month
      last_month = this_month
      echo """\\typeout{\\trmSolCyan{#{date.format 'YYYY-MM-DD'}}}"""
    #.......................................................................................................
    hl      = tide_event[ 'hl' ]
    height  = tide_event[ 'height' ]
    dots.push [ hl, [ height, dots.length, ], ]
    #.......................................................................................................
    switch hl
      when 'h'
        x_position = '35mm'
      when 'l'
        x_position = '50mm'
      else
        throw new Error "expected `h` or `l` for hl indicator, got #{rpr hl}"
    #.......................................................................................................
    ### TAINT use proper escaping ###
    dst       = if tide_event[ 'is-dst' ] then '+' else ''
    time_txt  = date.format "HH[#{thinspace}]:[#{thinspace}]mm"
    echo """\\paRight{#{x_position}}{#{y_position}}{#{time_txt}}"""



############################################################################################################
unless module.parent?
  @main()
  # debug TIDES[ 'options' ]
  # debug TIDES[ 'options' ][ 'values' ][ 'moon' ][ 0 ]
  # debug ( TIDES.options.get '/values/moon' )[ 0 ]
  # debug TIDES.options.get '/values/moon/0'
  # FI = require 'coffeenode-fillin'
  # fill_in = FI.new_method()
  # debug TIDES.options.get fill_in '/values/moon/$quarter', quarter: 0
