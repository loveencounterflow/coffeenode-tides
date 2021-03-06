
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
FI                        = require 'coffeenode-fillin'
sine                      = require './sine'
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
@format_month_name = ( page_nr, date ) ->
  ### TAINT make formats configurable ###
  month_name    = date.format 'MMMM'
  month_name    = month_name[ 0 ].toUpperCase() + month_name[ 1 .. ]
  #.........................................................................................................
  # echo """\\paTopLeft*{0mm}{0mm}{\\includegraphics[width=118mm]{#{route}}}"""
  ### TAINT inefficient to retrieve each time; options should use cache ###
  is_even_page  = page_nr %% 2 is 0
  if is_even_page
    align_x       = FI.get TIDES.options, '/values/layout/month/even/align/x'
    align_y       = FI.get TIDES.options, '/values/layout/month/even/align/y'
    position_x    = ( FI.get TIDES.options, '/values/layout/month/even/position/x' ) + 'mm'
    position_y    = ( FI.get TIDES.options, '/values/layout/month/even/position/y' ) + 'mm'
  else
    align_x       = FI.get TIDES.options, '/values/layout/month/odd/align/x'
    align_y       = FI.get TIDES.options, '/values/layout/month/odd/align/y'
    position_x    = ( FI.get TIDES.options, '/values/layout/month/odd/position/x' ) + 'mm'
    position_y    = ( FI.get TIDES.options, '/values/layout/month/odd/position/y' ) + 'mm'
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
  chapter_mark = TEX.new_multicommand 'markboth', 2, [ month_name, month_name, ]
  return [
    pa_command [ position_x, position_y, content, ]
    chapter_mark ]

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
@_get_moon_phase = ( lunar_events ) ->
  return [ null, null, ] unless ( event = lunar_events[ 'phase' ] )?
  # date_txt        = event[ 'date' ].format 'dd DD.MM.YYYY HH:mm'
  moon_quarter    = event[ 'marker' ]
  moon_symbol     = FI.get TIDES.options, "/values/moon/quarters/#{moon_quarter}"
  return [ moon_quarter, moon_symbol, ]

#-----------------------------------------------------------------------------------------------------------
@_get_moon_distance = ( lunar_events ) ->
  return [ null, null, null, ] unless ( event = lunar_events[ 'distance' ] )?
  # date_txt        = event[ 'date' ].format 'dd DD.MM.YYYY HH:mm'
  ap              = event[ 'marker' ]
  ap_symbol       = FI.get TIDES.options, "/values/moon/distance/#{ap}"
  distance_km     = event[ 'details' ][ 'distance.km' ]
  distance_ed     = distance_km / 12742
  return[ ap, ap_symbol, distance_ed, ]

#-----------------------------------------------------------------------------------------------------------
@_get_moon_declination = ( lunar_events ) ->
  return [ null, null, null, ] unless ( event = lunar_events[ 'declination' ] )?
  # date_txt        = event[ 'date' ].format 'dd DD.MM.YYYY HH:mm'
  sn              = event[ 'marker' ]
  sn_symbol       = FI.get TIDES.options, "/values/moon/declination/#{sn}"
  declination_deg = event[ 'details' ][ 'declination.deg' ]
  return [ sn, sn_symbol, declination_deg, ]


#-----------------------------------------------------------------------------------------------------------
@_add_dots_day_entry = ( dots, row_idx, day, hl ) ->
  dots[ 'days' ].push { row_idx: row_idx, day: day, hl: hl, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_new_dots = ->
  R           = []
  R[ 'days' ] = []
  return R

#-----------------------------------------------------------------------------------------------------------
@main = ->
  ### TAINT must parametrize data source ###
  # route         = njs_path.join __dirname, '../tidal-data/Schiermonnikoog-2014-hl.txt'
  route         = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  # route         = njs_path.join __dirname, '../tidal-data/Yerseke.txt'
  # route         = njs_path.join __dirname, '../tidal-data/Harlingen-2014-hl.txt'
  rows          = TEX.new_container []
  row_idx       = -1
  dots          = @_new_dots()
  page_nr       = 0
  last_day      = null
  last_month    = null
  last_year     = null
  moon_quarter  = null
  wrote_header  = no
  # wrote_footer  = no
  echo preamble
  echo """\\renewcommand{\\placename}{Schiermonnikoog}"""
  echo """\\renewcommand{\\placename}{Vlieland (Haven)}"""
  #---------------------------------------------------------------------------------------------------------
  TIDES.read_aligned_events route, ( error, event_batches ) =>
    throw error if error?
    #.......................................................................................................
    [ extrema_event_batch
      tidal_hl_event_batch      ] = event_batches
    throw error if error?
    #.......................................................................................................
    for tidal_event in tidal_hl_event_batch
      row_idx      += 1
      lunar_events  = tidal_event[ 'lunar-events' ]
      [ moon_quarter, moon_symbol,                  ] = @_get_moon_phase        lunar_events
      [ ap,             ap_symbol, distance_ed,     ] = @_get_moon_distance     lunar_events
      [ sn,             sn_symbol, declination_deg, ] = @_get_moon_declination  lunar_events
      #.....................................................................................................
      date          = tidal_event[ 'date' ]
      this_day      = date.date()
      this_month    = date.month()
      #.....................................................................................................
      unless wrote_header
        [ this_month_tex, chapter_mark ] = @format_month_name page_nr, date
        # echo TEX.rpr this_month_tex
        echo TEX.rpr chapter_mark
        wrote_header = yes
        # whisper TEX.rpr this_month_tex
      #.....................................................................................................
      if moon_quarter is 0 or moon_quarter is 2
        ### TAINT collect these in a 'newpage' function ###
        row_idx   = 0
        page_nr  += 1
        #---------------------------------------------------------------------------------------------------
        do ( page_nr, dots ) =>
          #-------------------------------------------------------------------------------------------------
          if page_nr < 80 # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            ### TAINT asynchronous handling is missing ###
            info "drawing image #{page_nr}"
            route = njs_path.join '/tmp', "tides-p#{page_nr}.png"
            # echo """\\paTopLeft*{0mm}{0mm}{\\includegraphics[height=178mm]{#{route}}}"""
            echo """\\paTopLeft*{0mm}{0mm}{\\includegraphics[width=118mm]{#{route}}}"""
            @draw_curves route, dots, ( error ) =>
              info "image #{page_nr} ok"
              throw error if error?
        #---------------------------------------------------------------------------------------------------
        [ this_month_tex, chapter_mark ] = @format_month_name page_nr, date
        # echo TEX.rpr this_month_tex
        echo TEX.rpr chapter_mark
        dots      = @_new_dots()
        delete dots[ 'month-change-at-row-idx' ] # obsolete
        delete dots[ 'month-change-at-hl' ] # obsolete
        echo """\\null\\newpage"""
        wrote_header = no
      #.....................................................................................................
      ### TAINT parametrize ###
      # if ( date.isBefore '2014-06-13' ) or ( date.isAfter '2014-08-10 17:00' )
      #   # whisper "skipping #{date.toString()}"
      #   continue
      #.....................................................................................................
      ### TAINT measurements should be defined in options ###
      textheight  = 178 # mm
      line_count  = 62
      module      = textheight / line_count
      unit        = 'mm'
      y_position  = @_y_position_from_row_idx row_idx, module, unit
      #.....................................................................................................
      ### TAINT take horizontal positions from options ###
      symbols     = []
      symbols.push sn_symbol    if sn?
      symbols.push ap_symbol    if ap?
      symbols.push moon_symbol  if moon_symbol?
      if symbols.length > 0
        # symbols = ( symbols.join '\\\\' ) + '\\par'
        symbols = symbols.join ''
        echo """\\paLeftGauge{0.5mm}{#{y_position}}{#{symbols}}"""
      #.....................................................................................................
      hl      = tidal_event[ 'hl' ]
      #.....................................................................................................
      unless last_day is this_day
        last_day    = this_day
        month_txt   = date.format 'MM'
        day_txt     = date.format 'DD'
        weekday_txt = ( date.format 'dd' ).toLowerCase()
        color       = switch date.day()
          # when 6 then FI.get TIDES.options, '/values/colors/blue'   # Saturday
          when 0 then FI.get TIDES.options, '/values/colors/red'    # Sunday
          else        FI.get TIDES.options, '/values/colors/black'  # weekdays
        echo """\\paLeftGauge{10.5mm}{#{y_position}}{\\textcolor[HTML]{#{color}}{\\itFont{}#{weekday_txt}}}"""
        echo """\\paRightGauge{22.5mm}{#{y_position}}{\\textcolor[HTML]{#{color}}{\\large{} #{day_txt}.}}"""
        @_add_dots_day_entry dots, row_idx, this_day, hl
      #.....................................................................................................
      unless last_month is this_month # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        dots[ 'month-change-at-row-idx' ] = row_idx # obsolete
        dots[ 'month-change-at-hl'      ] = hl # obsolete
        last_month = this_month
        echo """\\typeout{\\trmSolCyan{#{date.format 'YYYY-MM-DD'}}}"""
        echo """\\typeout{\\trmSolCyan{#{date.format 'MMM'}}}"""
      #.....................................................................................................
      height  = tidal_event[ 'height' ]
      dots.push [ hl, [ height, dots.length, ], ]
      #.....................................................................................................
      switch hl
        when 'h'
          x_position = '34mm'
        when 'l'
          x_position = '46mm'
        else
          throw new Error "expected `h` or `l` for hl indicator, got #{rpr hl}"
      #.....................................................................................................
      ### TAINT use proper escaping ###
      dst       = if tidal_event[ 'is-dst' ] then '+' else ''
      time_txt  = date.format "HH[#{thinspace}]:[#{thinspace}]mm"
      echo """\\paRightGauge{#{x_position}}{#{y_position}}{#{time_txt}}"""
      #                ^^^^^
    #.......................................................................................................
    echo postscript
  #---------------------------------------------------------------------------------------------------------
  return null



############################################################################################################
unless module.parent?
  @main()
  # debug TIDES[ 'options' ]
  # debug TIDES[ 'options' ][ 'values' ][ 'moon' ][ 0 ]
  # debug ( FI.get TIDES.options, '/values/moon' )[ 0 ]
  # debug FI.get TIDES.options, '/values/moon/0'
  # FI = require 'coffeenode-fillin'
  # fill_in = FI.new_method()
  # debug FI.get TIDES.options, fill_in '/values/moon/$quarter', quarter: 0
