



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
@options                  = require '../options'
#...........................................................................................................
eventually                = process.nextTick
moment                    = require 'moment-timezone'

#-----------------------------------------------------------------------------------------------------------
@moon_quarter_by_phases =
  'NM':       0
  'EK':       1
  'VM':       2
  'LK':       3


#-----------------------------------------------------------------------------------------------------------
@new_tide_event = ( source_line_nr, date, is_dst, hl, height ) ->
  R =
    '~isa':             'TIDES/tide-event'
    'source-line-nr':   source_line_nr
    'date':             date
    'is-dst':           is_dst
    'hl':               hl
    'height':           height
    'moon':             null
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_moon_event = ( source_line_nr, date, is_dst, moon_quarter ) ->
  R =
    '~isa':             'TIDES/moon-event'
    'source-line-nr':   source_line_nr
    'date':             date
    'is-dst':           is_dst
    'quarter':          moon_quarter
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@walk_raw_fields = ( route, handler ) ->
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
@walk_tide_and_moon_events = ( route, handler ) ->
  record_idx        = -1
  datetime_format   = @options[ 'data' ][ 'date' ][ 'raw-format' ]
  timezone          = @options[ 'data' ][ 'date' ][ 'timezone' ]
  #---------------------------------------------------------------------------------------------------------
  @walk_raw_fields route, ( error, fields, source_line, source_line_nr ) =>
    return handler error if error?
    #.......................................................................................................
    if fields is null
      last_record_idx = null
      return handler null, null
    #.......................................................................................................
    columns     = []
    record_idx += 1
    #.......................................................................................................
    switch field_count = fields.length
      #.....................................................................................................
      when 5
        [ date_txt
          tide_time_txt
          tide
          height_txt ]  = fields
        moon_phase      = null
        moon_quarter    = null
        moon_time_txt   = null
      #.....................................................................................................
      when 7
        [ date_txt
          moon_phase
          moon_time_txt
          tide_time_txt
          tide
          height_txt ]  = fields
        moon_quarter    = @options[ 'data' ][ 'moon' ][ 'quarter-by-phases' ][ moon_phase ]
      #.....................................................................................................
      else
        return handler new Error "unable to parse line #{source_line_nr}: #{rpr source_line}"
    #.......................................................................................................
    height  = parseInt height_txt, 10
    is_dst  = /\+$/.test tide_time_txt
    #.......................................................................................................
    switch tide
      when 'LW' then hl = 'l'
      when 'HW' then hl = 'h'
      else
        return handler new Error "unable to parse tide entry on line #{source_line_nr}: #{rpr tide}"
    #.......................................................................................................
    tide_date = moment.tz "#{date_txt} #{tide_time_txt}", datetime_format, timezone
    ### TAINT use @options ###
    tide_date.lang 'nl'
    handler null, @new_tide_event source_line_nr, tide_date, is_dst, hl, height
    #.......................................................................................................
    return unless moon_phase?
    moon_date = moment.tz "#{date_txt} #{moon_time_txt}", datetime_format, timezone
    ### TAINT use @options ###
    moon_date.lang 'nl'
    handler null, @new_moon_event source_line_nr, moon_date, is_dst, moon_quarter
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@walk = ( route, handler ) ->
  tide_buffer             = []
  tide_buffer_max_length  = 6
  moon_buffer             = []
  waiting_for_moon        = no
  #---------------------------------------------------------------------------------------------------------
  find_closest_tide_for_moon_event = =>
    return if moon_buffer.length is 0
    if moon_buffer.length > 1
      return handler new Error "too many moon events in buffer (#{moon_buffer.length})"
    moon_event  = moon_buffer.shift()
    moon_date   = moon_event[ 'date' ]
    #.....................................................................................................
    dt_min = Infinity
    for tide_event in tide_buffer
      tide_date     = tide_event[ 'date' ]
      dt            = Math.abs ( moment.duration tide_date.diff moon_date ).asHours()
      continue if dt > dt_min
      dt_min        = dt
      target_event  = tide_event
    #.....................................................................................................
    target_event[ 'moon' ] = moon_event
  #---------------------------------------------------------------------------------------------------------
  clear_tide_buffer = ( max_length ) =>
    while tide_buffer.length > max_length
      # whisper "clearing tide buffer"
      handler null, tide_buffer.shift()
  #---------------------------------------------------------------------------------------------------------
  @walk_tide_and_moon_events route, ( error, event ) =>
    return handler error if error?
    #.......................................................................................................
    ### Release remaining buffer contents and finish: ###
    ### TAINT must look for remaining moon entries in buffer ###
    if event is null
      find_closest_tide_for_moon_event()
      clear_tide_buffer 0
      if moon_buffer.length isnt 0
        return handler new Error "found #{moon_buffer.length} unprocessed moon events"
      return handler null, null
    #.......................................................................................................
    type = event[ '~isa' ]
    if type is 'TIDES/tide-event'
      tide_buffer.push event
    else
      moon_buffer.push event
      waiting_for_moon = yes
    #.......................................................................................................
    if waiting_for_moon
      if ( tide_buffer.length >= tide_buffer_max_length )
        find_closest_tide_for_moon_event()
        waiting_for_moon = no
        clear_tide_buffer 0
    #.......................................................................................................
    else
      clear_tide_buffer 2


#===========================================================================================================
# DEMOS
#-----------------------------------------------------------------------------------------------------------
@_demo_walk_tide_and_moon_events = ->
  TIDES = @
  route = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  TIDES.walk_tide_and_moon_events route, ( error, event ) ->
    throw error if error?
    return if event is null
    date = event[ 'date' ]
    date_txt  = date.format 'dddd, D. MMMM YYYY HH:mm'
    if TYPES.isa event, 'TIDES/moon-event'
      quarter = event[ 'quarter' ]
      symbol  = TIDES.options[ 'data' ][ 'moon' ][ 'unicode' ][ quarter ]
      log TRM.lime date_txt, quarter, symbol
    else
      hl      = event[ 'hl' ]
      height  = event[ 'height' ]
      log TRM.gold date_txt, hl, height

#-----------------------------------------------------------------------------------------------------------
@_demo_walk = ->
  TIDES = @
  route = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  TIDES.walk route, ( error, event ) ->
    throw error if error?
    return if event is null
    date      = event[ 'date' ]
    date_txt  = date.format 'dddd, D. MMMM YYYY HH:mm'
    hl        = event[ 'hl' ]
    height    = event[ 'height' ]
    event_txt = TRM.gold date_txt, hl, height
    if ( moon_event = event[ 'moon' ] )?
      date        = moon_event[ 'date' ]
      date_txt    = date.format 'dddd, D. MMMM YYYY HH:mm'
      quarter     = moon_event[ 'quarter' ]
      symbol      = TIDES.options[ 'data' ][ 'moon' ][ 'unicode' ][ quarter ]
      event_txt  += ' ' + TRM.lime date_txt, quarter, symbol
    log event_txt


############################################################################################################
unless module.parent?
  # @_demo_walk_tide_and_moon_events()
  @_demo_walk()

