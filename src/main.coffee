



############################################################################################################
# njs_util                  = require 'util'
njs_fs                    = require 'fs'
njs_path                  = require 'path'
#...........................................................................................................
# BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
FS                        = require 'coffeenode-fs'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'TIDES/main'
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
XDate                     = require 'xdate'

#-----------------------------------------------------------------------------------------------------------
@moon_quarter_by_phases =
  'NM':       0
  'EK':       1
  'VM':       2
  'LK':       3


#-----------------------------------------------------------------------------------------------------------
@new_tidal_record = ( source_line_nr, moon_quarter, date, time, hl, height ) ->
  R =
    '~isa':             'GEZEITEN/tidal-record'
    'source-line-nr':   source_line_nr
    'moon-quarter':     moon_quarter
    'date':             date
    'time':             time
    'hl':               hl
    'height':           height
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_table_row = ( source_line_nr, date ) ->
  R =
    '~isa':             'GEZEITEN/tidal-table-line'
    'source-line-nr':   source_line_nr
    'date':             date
    'weekday-idx':      null
    'moon-quarter':     null
    'day-change':       false
    'hi-water-time':    null
    'lo-water-time':    null
    'hi-water-height':  null
    'lo-water-height':  null
  #.........................................................................................................
  return R

# #-----------------------------------------------------------------------------------------------------------
# @new_tidal_records = ( source_route ) ->
#   R =
#     '~isa':             'GEZEITEN/tidal-records'
#     'source-route':     source_route
#   return R

# #-----------------------------------------------------------------------------------------------------------
# @_postprocess = ( result ) ->
#   return [ null, result, ]

#-----------------------------------------------------------------------------------------------------------
@walk_tidal_raw_fields = ( route, handler ) ->
  #---------------------------------------------------------------------------------------------------------
  FS.lines_of route, ( error, source_line, source_line_nr ) =>
    return handler error if error?
    return handler null, null if source_line is null
    #.......................................................................................................
    source_line = source_line.trim()
    return if source_line[ 0 ] is '#'
    #.......................................................................................................
    fields  = source_line.split /\s+/
    handler null, fields, source_line, source_line_nr
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@walk_tidal_records = ( route, handler ) ->
  #---------------------------------------------------------------------------------------------------------
  @walk_tidal_raw_fields route, ( error, fields, source_line, source_line_nr ) =>
    return handler error if error?
    return handler null, null if fields is null
    #.......................................................................................................
    columns = []
    #.......................................................................................................
    switch field_count = fields.length
      #.....................................................................................................
      when 5
        [ date_txt
          time_txt
          tide
          height_txt ]  = fields
        moon_phase      = null
      #.....................................................................................................
      when 7
        [ date_txt
          moon_phase
          ignored
          time_txt
          tide
          height_txt ]  = fields
      #.....................................................................................................
      else
        return handler new Error "unable to parse line #{source_line_nr}: #{rpr source_line}"
    #.......................................................................................................
    [ day_txt, month_txt, year_txt, ] = date_txt.split '/'
    [ hour_txt, minute_txt,         ] = time_txt.split ':'
    #.......................................................................................................
    hour_txt      =  hour_txt.replace /^0/, ' '
    day_txt       =   day_txt.replace /^0/, ' '
    month_txt     = month_txt.replace /^0/, ' '
    moon_quarter  = if moon_phase? then @moon_quarter_by_phases[ moon_phase ] else null
    height        = parseInt height_txt, 10
    date          = [ year_txt, month_txt, day_txt, ]
    time          = [ hour_txt, minute_txt, ]
    #.......................................................................................................
    switch tide
      when 'LW' then hl = 'l'
      when 'HW' then hl = 'h'
      else
        return handler new Error "unable to parse tide entry on line #{source_line_nr}: #{rpr tide}"
    #.......................................................................................................
    Z = @new_tidal_record source_line_nr, moon_quarter, date, time, hl, height
    #.......................................................................................................
    handler null, Z
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@walk_table_rows = ( route, handler ) ->
  # line        = @new_tidal_fields()
  # Z           = @new_tidal_records route
  ### TAINT we use no less than two variables to do one thing, namely terminate prematurely for testing
  purposes, while still preserving the default behavior and ensure that we call the handler exactly once
  (on success or failure). Question is whether this might not be made somewhat shorter? ###
  finished    = no
  over        = no
  Z           = null
  last_day    = null
  last_month  = null
  last_year   = null
  #---------------------------------------------------------------------------------------------------------
  @walk_tidal_records route, ( error, tidal_record ) =>
    throw error if error?
    return if over
    source_line_nr  = tidal_record?[ 'source-line-nr' ] ? null
    finished        = tidal_record is null or source_line_nr > 150 # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    finished        = ( tidal_record is null ) or finished and not over
    #.......................................................................................................
    if finished
      over = true
      handler null, Z if Z?
      return handler null, null # ( @_postprocess Z )...
    #.......................................................................................................
    hl              = tidal_record[ 'hl' ]
    this_date       = tidal_record[ 'date' ]
    [ this_year
      this_month
      this_day    ] = this_date
    #.......................................................................................................
    unless Z?
      Z = @new_table_row source_line_nr, this_date
    #.......................................................................................................
    if hl is 'h'
      Z[ 'hi-water-time'   ] = tidal_record[ 'time'   ]
      Z[ 'hi-water-height' ] = tidal_record[ 'height' ]
    else
      Z[ 'lo-water-time'   ] = tidal_record[ 'time'   ]
      Z[ 'lo-water-height' ] = tidal_record[ 'height' ]
    #.......................................................................................................
    ### TAINT this procedure will likely work if the place of processing is in the same timezone as the
    place where the given data refers to; in the more general case, however, JavaScript as running in NodeJS
    will probably understand dates in terms of the current local at the place of processing and cause
    subtle or not so subtle mismatches between times and dates as intended and as processed.

    Also, under the assumptions that each day appears at least once in the data and all days are called up
    sequentially, it suffices to calculate the weekday for the first day called and the cycle through
    the list of weekday names. ###
    unless Z[ 'weekday-idx' ]?
      xdate               = new XDate this_year, this_month, this_day
      Z[ 'weekday-idx' ]  = ( xdate.getDay() + 6 ) % 7
    #.......................................................................................................
    if this_day isnt last_day
      last_day = this_day
      Z[ 'day-change' ] = yes if hl is 'l'
    #.......................................................................................................
    if ( moon_quarter = tidal_record[ 'moon-quarter' ] )?
      Z[ 'moon-quarter' ] = moon_quarter
    #.......................................................................................................
    if Z[ 'lo-water-time' ]?
      handler null, Z
      Z = null
  #---------------------------------------------------------------------------------------------------------
  return null



############################################################################################################
unless module.parent?
  TIDES = @
  route = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  TIDES.walk_table_rows route, ( error, table_row ) ->
    throw error if error?
    info TRM.rainbow table_row

