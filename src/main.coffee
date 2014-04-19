



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
FI                        = require 'coffeenode-fillin'
@options                  = FI.fill_in require '../options'
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
@new_tidal_record = ( source_line_nr, moon_quarter, date, time, is_dst, hl, height ) ->
  R =
    '~isa':             'GEZEITEN/tidal-record'
    'source-line-nr':   source_line_nr
    'moon-quarter':     moon_quarter
    'weekday-idx':      null
    'date':             date
    'time':             time
    'is-dst':           is_dst
    'hl':               hl
    'height':           height
  #.........................................................................................................
  return R

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

new_and_full_moons = []

#-----------------------------------------------------------------------------------------------------------
@walk_tidal_records = ( route, handler ) ->
  record_idx = -1
  #---------------------------------------------------------------------------------------------------------
  @walk_tidal_raw_fields route, ( error, fields, source_line, source_line_nr ) =>
    return handler error if error?
    #.......................................................................................................
    if fields is null
      debug new_and_full_moons # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      last_record_idx = null
      for this_record_idx, idx in new_and_full_moons
        if last_record_idx?
          info this_record_idx - last_record_idx
        last_record_idx = this_record_idx
      return handler null, null
    #.......................................................................................................
    columns     = []
    record_idx += 1
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
    is_dst = no
    if /\+$/.test minute_txt
      minute_txt    = minute_txt[ ... minute_txt.length - 1 ]
      is_dst        = yes
    #.......................................................................................................
    ### TAINT make typography of date & time configurable ###
    # hour_txt      =  hour_txt.replace /^0/, ' '
    day_txt       =   day_txt.replace /^0/, ' '
    month_txt     = month_txt.replace /^0/, ' '
    height        = parseInt height_txt, 10
    date          = [ year_txt, month_txt, day_txt, ]
    time          = [ hour_txt, minute_txt, ]
    #.......................................................................................................
    moon_quarter  = null
    if moon_phase?
      moon_quarter  = @moon_quarter_by_phases[ moon_phase ]
      if moon_quarter is 0 or moon_quarter is 2
        new_and_full_moons.push record_idx
    #.......................................................................................................
    switch tide
      when 'LW' then hl = 'l'
      when 'HW' then hl = 'h'
      else
        return handler new Error "unable to parse tide entry on line #{source_line_nr}: #{rpr tide}"
    #.......................................................................................................
    Z = @new_tidal_record source_line_nr, moon_quarter, date, time, is_dst, hl, height
    #.......................................................................................................
    ### TAINT this procedure will likely work if the place of processing is in the same timezone as the
    place where the given data refers to; in the more general case, however, JavaScript as running in NodeJS
    will probably understand dates in terms of the current local at the place of processing and cause
    subtle or not so subtle mismatches between times and dates as intended and as processed.

    Also, under the assumptions that each day appears at least once in the data and all days are called up
    sequentially, it suffices to calculate the weekday for the first day called and the cycle through
    the list of weekday names. ###
    xdate               = new XDate year_txt, month_txt, day_txt
    Z[ 'weekday-idx' ]  = ( xdate.getDay() + 6 ) % 7
    #.......................................................................................................
    handler null, Z
  #---------------------------------------------------------------------------------------------------------
  return null



############################################################################################################
unless module.parent?
  TIDES = @
  route = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  TIDES.walk_table_rows route, ( error, table_row ) ->
    throw error if error?
    info TRM.rainbow table_row

