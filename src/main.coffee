



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
bSearch                   = require 'coffeenode-bsearch'
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
@new_tidal_extrema_event = ( min_l_height, max_l_height, min_h_height, max_h_height ) ->
  R =
    '~isa':             'TIDES/tidal-extrema-event'
    'min-l-height':      min_l_height
    'max-l-height':      max_l_height
    'min-h-height':      min_h_height
    'max-h-height':      max_h_height
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
### TNG: unified 'lunar event' type ###
@new_lunar_event = ( source, category, marker, date, details = null ) ->
  switch category
    when 'tide'
      throw new Error "illegal marker #{rpr marker}" unless ( marker is 'h' ) or ( marker is 'l' )
    when 'distance'
      throw new Error "illegal marker #{rpr marker}" unless ( marker is 'P' ) or ( marker is 'A' )
    when 'declination'
      throw new Error "illegal marker #{rpr marker}" unless ( marker is 'N' ) or ( marker is 'S' )
    else
      throw new Error "illegal category #{rpr category}"
  R =
    '~isa':             'TIDES/moon-event'
    'category':         category
    'marker':           marker
    'source':           source
    'date':             date
    'details':          details
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
    return if source_line.length is 0
    #.......................................................................................................
    fields  = source_line.split /\s+/
    handler null, fields, source_line, source_line_nr
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@walk_lunar_distance_events = ( handler ) ->
  ### TAINT make configurable ###
  route = njs_path.join __dirname, '../tidal-data/apogees-and-perigees.txt'
  #---------------------------------------------------------------------------------------------------------
  @walk_raw_fields route, ( error, fields, source_line, source_line_nr ) =>
    return handler error if error?
    #.......................................................................................................
    if fields is null
      return handler null, null
    #.......................................................................................................
    unless ( field_count = fields.length ) is 5
      throw new Error "expected 5 fields, got #{field_count} on line ##{source_line_nr} in file #{route}"
    #.......................................................................................................
    [ date_txt
      time_txt
      tz
      distance_km_txt
      marker ] = fields
    #.......................................................................................................
    source      = "#{route}##{source_line_nr}"
    date        = moment.tz "#{date_txt} #{time_txt}", tz
    distance_km = parseInt distance_km_txt, 10
    ### TAINT make configurable ###
    marker      = if marker is 'Apogee' then 'A' else 'P'
    details     = 'distance.km': distance_km
    handler null, @new_lunar_event source, 'distance', marker, date, details

#-----------------------------------------------------------------------------------------------------------
@walk_lunar_declination_events = ( handler ) ->
  ### TAINT make configurable ###
  route = njs_path.join __dirname, '../tidal-data/declination-maxima.txt'
  #---------------------------------------------------------------------------------------------------------
  @walk_raw_fields route, ( error, fields, source_line, source_line_nr ) =>
    return handler error if error?
    #.......................................................................................................
    if fields is null
      return handler null, null
    #.......................................................................................................
    unless ( field_count = fields.length ) is 4
      throw new Error "expected 4 fields, got #{field_count} on line ##{source_line_nr} in file #{route}"
    #.......................................................................................................
    [ date_txt
      time_txt
      tz
      declination_txt ] = fields
    #.......................................................................................................
    source          = "#{route}##{source_line_nr}"
    date            = moment.tz "#{date_txt} #{time_txt}", tz
    marker          = declination_txt[ 0 ]
    declination_deg = parseFloat declination_txt[ 1 ... ], 10
    details         = 'declination.deg': declination_deg
    handler null, @new_lunar_event source, 'declination', marker, date, details

#-----------------------------------------------------------------------------------------------------------
@walk_tide_and_moon_events = ( route, handler ) ->
  record_idx        = -1
  datetime_format   = @options[ 'data' ][ 'date' ][ 'raw-format' ]
  timezone          = @options[ 'data' ][ 'date' ][ 'timezone' ]
  min_l_height      = +Infinity
  max_l_height      = -Infinity
  min_h_height      = +Infinity
  max_h_height      = -Infinity
  #---------------------------------------------------------------------------------------------------------
  @walk_raw_fields route, ( error, fields, source_line, source_line_nr ) =>
    return handler error if error?
    #.......................................................................................................
    if fields is null
      handler null, @new_tidal_extrema_event min_l_height, max_l_height, min_h_height, max_h_height
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
      when 'LW'
        hl = 'l'
        min_l_height = Math.min min_l_height, height
        max_l_height = Math.max max_l_height, height
      when 'HW'
        hl = 'h'
        min_h_height = Math.min min_h_height, height
        max_h_height = Math.max max_h_height, height
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
@walk_events_extrema_first = ( route, handler ) ->
  buffer                  = []
  #---------------------------------------------------------------------------------------------------------
  @walk_tide_and_moon_events route, ( error, event ) =>
    return handler error if error?
    #.......................................................................................................
    if event is null
      handler null, event for event in buffer
      return handler null, null
    #.......................................................................................................
    return handler null, event if TYPES.isa event, 'TIDES/tidal-extrema-event'
    buffer.push event
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
  @walk_events_extrema_first route, ( error, event ) =>
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
    switch type = event[ '~isa' ]
      when 'TIDES/tide-event'
        tide_buffer.push event
      when 'TIDES/moon-event'
        moon_buffer.push event
        waiting_for_moon = yes
      when 'TIDES/tidal-extrema-event'
        @options[ 'data' ][ 'tides' ][ 'min-l-height' ] = event[ 'min-l-height' ]
        @options[ 'data' ][ 'tides' ][ 'max-l-height' ] = event[ 'max-l-height' ]
        @options[ 'data' ][ 'tides' ][ 'min-h-height' ] = event[ 'min-h-height' ]
        @options[ 'data' ][ 'tides' ][ 'max-h-height' ] = event[ 'max-h-height' ]
      else
        return handler new Error "unknown event type #{rpr type}"
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
  #---------------------------------------------------------------------------------------------------------
  TIDES.walk_tide_and_moon_events route, ( error, event ) =>
    throw error if error?
    return if event is null
    date      = event[ 'date' ]
    date_txt  = if date? then date.format 'dddd, D. MMMM YYYY HH:mm' else './.'
    switch type = TYPES.type_of event
      when 'TIDES/moon-event'
        quarter = event[ 'quarter' ]
        symbol  = TIDES.options[ 'data' ][ 'moon' ][ 'unicode' ][ quarter ]
        log TRM.lime date_txt, quarter, symbol
      when 'TIDES/tide-event'
        hl      = event[ 'hl' ]
        height  = event[ 'height' ]
        log TRM.gold date_txt, hl, height
      when 'TIDES/tidal-extrema-event'
        log TRM.gold event
      else
        warn "unhandled event of type #{rpr type}"
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@_demo_align_tide_and_moon_events = ->
  TIDES         = @
  # route         = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  route         = njs_path.join __dirname, '../tidal-data/Yerseke.txt'
  tidal_events  = []
  lunar_events  = []
  #---------------------------------------------------------------------------------------------------------
  get_compare = ( probe_event ) =>
    return ( data_event ) =>
      return probe_event[ 'date' ] - data_event[ 'date' ]
  #---------------------------------------------------------------------------------------------------------
  collect = ( handler ) =>
    #-------------------------------------------------------------------------------------------------------
    TIDES.walk_tide_and_moon_events route, ( error, event ) =>
      return handler error if error?
      return handler null if event is null
      switch type = TYPES.type_of event
        when 'TIDES/moon-event'
          lunar_events.push event
        when 'TIDES/tide-event'
          tidal_events.push event
        else
          warn "unhandled event of type #{rpr type}"
  #---------------------------------------------------------------------------------------------------------
  splice = => # ( handler ) =>
    collect ( error ) =>
      throw error if error?
      for collection in [ lunar_events, ]
        for lunar_event in lunar_events
          lunar_date        = lunar_event[ 'date' ]
          lunar_date_txt    = lunar_date.format 'YY-MM-DD HH:mm Z', 'Europe/Amsterdam'
          # lunar_event_txt   = "#{lunar_date_txt} #{lunar_event[ 'category' ]} #{lunar_event[ 'marker' ]}"
          lunar_event_txt   = "#{lunar_date_txt} #{lunar_event[ 'quarter' ]}"
          idx               = bSearch.closest tidal_events, get_compare lunar_event
          tidal_event       = tidal_events[ idx ]
          tidal_date        = tidal_event[ 'date' ]
          tidal_date_txt    = tidal_date.format 'YY-MM-DD HH:mm Z', 'Europe/Amsterdam'
          tidal_event_txt   = "#{tidal_date_txt} #{tidal_event[ 'hl' ]}"
          log ( TRM.lime tidal_event_txt ), ( TRM.gold lunar_event_txt )
  #.........................................................................................................
  splice()
  return null

#-----------------------------------------------------------------------------------------------------------
@_demo_walk = ->
  _                 = require 'lodash'
  TIDES             = @
  route             = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  tide_moon_counts  = []
  tide_idx          = 0
  last_moon_idx     = null
  #---------------------------------------------------------------------------------------------------------
  TIDES.walk route, ( error, event ) =>
    throw error if error?
    #.......................................................................................................
    if event is null
      # info tide_moon_counts
      info _.countBy tide_moon_counts
      return
    #.......................................................................................................
    tide_idx += 1
    date      = event[ 'date' ]
    date_txt  = date.format 'ddd, DD. MMM YYYY HH:mm'
    hl        = event[ 'hl' ]
    height    = event[ 'height' ]
    event_txt = TRM.gold date_txt, hl, height
    #.......................................................................................................
    if ( moon_event = event[ 'moon' ] )?
      if ( moon_event[ 'quarter' ] is 0 ) # or ( moon_event[ 'quarter' ] is 2 )
        tide_moon_counts.push tide_idx - last_moon_idx if last_moon_idx?
        last_moon_idx   = tide_idx
      date            = moon_event[ 'date' ]
      date_txt        = date.format 'ddd, D. MMM YYYY HH:mm'
      quarter         = moon_event[ 'quarter' ]
      symbol          = TIDES.options[ 'data' ][ 'moon' ][ 'unicode' ][ quarter ]
      event_txt      += ' ' + TRM.lime date_txt, quarter, symbol
    #.......................................................................................................
    log event_txt
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@_demo_walk_lunar_events = ->
  @walk_lunar_distance_events ( error, event ) ->
    throw error if error?
    return if event is null
    debug event[ 'category' ], event[ 'marker' ], event[ 'date' ].toString(), event[ 'details' ]
  @walk_lunar_declination_events ( error, event ) ->
    throw error if error?
    return if event is null
    debug event[ 'category' ], event[ 'marker' ], event[ 'date' ].toString(), event[ 'details' ]

############################################################################################################
unless module.parent?
  # @_demo_walk_tide_and_moon_events()
  # @_demo_walk()
  # @_demo_walk_lunar_events()
  @_demo_align_tide_and_moon_events()

