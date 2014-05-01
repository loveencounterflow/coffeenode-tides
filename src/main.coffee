



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
ASYNC                     = require 'async'

#-----------------------------------------------------------------------------------------------------------
@new_tidal_event = ( source_line_nr, date, is_dst, hl, height ) ->
  R =
    '~isa':             'TIDES/tidal-event'
    'source-line-nr':   source_line_nr
    'date':             date
    'is-dst':           is_dst
    'hl':               hl
    'height':           height
    'lunar-events':
      'phase':            null
      'distance':         null
      'declination':      null
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
### TNG: unified 'lunar event' type ###
@new_lunar_event = ( source_ref, category, marker, date, details = null ) ->
  switch category
    when 'phase'
      switch marker
        when 0, 1, 2, 3 then null
        else
          throw new Error "illegal marker #{rpr marker} for category #{rpr category}"
    when 'distance'
      switch marker
        when 'P', 'A' then null
        else
          throw new Error "illegal marker #{rpr marker} for category #{rpr category}"
    when 'declination'
      switch marker
        when 'N', 'S' then null
        else
          throw new Error "illegal marker #{rpr marker} for category #{rpr category}"
    else
      throw new Error "illegal category #{rpr category}"
  #.........................................................................................................
  R =
    '~isa':             'TIDES/lunar-event'
    'category':         category
    'marker':           marker
    'source-ref':       source_ref
    'date':             date
    'details':          details
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@walk_raw_fields = ( route, handler ) ->
  #---------------------------------------------------------------------------------------------------------
  FS.lines_of route, ( error, source_line, source_line_nr ) =>
    return handler error if error?
    return handler null, null, null if source_line is null
    #.......................................................................................................
    source_ref  = "#{route}##{source_line_nr}"
    source_line = source_line.trim()
    return if source_line[ 0 ] is '#'
    return if source_line.length is 0
    #.......................................................................................................
    fields  = source_line.split /\s+/
    handler null, fields, source_line, source_ref
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@walk_lunar_distance_events = ( handler ) ->
  ### TAINT make configurable ###
  route = njs_path.join __dirname, '../tidal-data/apogees-and-perigees.txt'
  #---------------------------------------------------------------------------------------------------------
  @walk_raw_fields route, ( error, fields, source_line, source_ref ) =>
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
    date        = moment.tz "#{date_txt} #{time_txt}", tz
    distance_km = parseInt distance_km_txt, 10
    ### TAINT make configurable ###
    marker      = if marker is 'Apogee' then 'A' else 'P'
    details     = 'distance.km': distance_km
    handler null, @new_lunar_event source_ref, 'distance', marker, date, details

#-----------------------------------------------------------------------------------------------------------
@walk_lunar_declination_events = ( handler ) ->
  ### TAINT make configurable ###
  route = njs_path.join __dirname, '../tidal-data/declination-maxima.txt'
  #---------------------------------------------------------------------------------------------------------
  @walk_raw_fields route, ( error, fields, source_line, source_ref ) =>
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
    date            = moment.tz "#{date_txt} #{time_txt}", tz
    marker          = declination_txt[ 0 ]
    declination_deg = parseFloat declination_txt[ 1 ... ], 10
    details         = 'declination.deg': declination_deg
    #.......................................................................................................
    handler null, @new_lunar_event source_ref, 'declination', marker, date, details
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@_walk_tidal_and_lunar_phase_events = ( route, handler ) ->
  record_idx        = -1
  datetime_format   = @options[ 'data' ][ 'date' ][ 'raw-format' ]
  timezone          = @options[ 'data' ][ 'date' ][ 'timezone' ]
  min_l_height      = +Infinity
  max_l_height      = -Infinity
  min_h_height      = +Infinity
  max_h_height      = -Infinity
  #---------------------------------------------------------------------------------------------------------
  @walk_raw_fields route, ( error, fields, source_line, source_ref ) =>
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
        return handler new Error "unable to parse line #{source_ref}:\n#{rpr source_line}"
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
    handler null, @new_tidal_event source_ref, tide_date, is_dst, hl, height
    #.......................................................................................................
    return unless moon_phase?
    moon_date = moment.tz "#{date_txt} #{moon_time_txt}", datetime_format, timezone
    ### TAINT use @options ###
    moon_date.lang 'nl'
    handler null, @new_lunar_event source_ref, 'phase', moon_quarter, moon_date
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@read_tidal_and_lunar_event_batches = ( route, handler ) ->
  ### As the name says, the method will read tidal and lunar events and return a list with three batches
  (i.e. lists) of events.

  The batches list will be ordered as follows:
  * first comes a list with a single `TIDES/tidal-extrema-event`, announcing the lows and highs for the
    place and time under consideration;
  * next come all the tidal lows and heights;
  * finally, the lunar events—phases as well as declination and distance extrema—are sent.

  Note that **(1)** each event category is sorted **as they appear in the datasources**, so in case they
  should *not* appear in ascending order, expect weird results when trying to align events using binary
  search; **(2)** lunar events are sorted only **within**, not **across** event categories, so it may happen
  that a lunar declination event for July comes earlier than, say, a lunar phase event for January. ###
  tidal_extrema_event_batch = []
  tidal_hl_event_batch      = []
  lunar_event_batch         = []
  tasks                     = []
  #---------------------------------------------------------------------------------------------------------
  tasks.push ( done ) =>
    #-------------------------------------------------------------------------------------------------------
    @_walk_tidal_and_lunar_phase_events route, ( error, event ) =>
      return handler error if error?
      return done null if event is null
      #.....................................................................................................
      switch types = TYPES.type_of event
        when 'TIDES/tidal-extrema-event'
          tidal_extrema_event_batch.push event
        when 'TIDES/tidal-event'
          tidal_hl_event_batch.push event
        when 'TIDES/lunar-event'
          lunar_event_batch.push event
        else
          warn "skipped event of type #{rpr type}"
  #---------------------------------------------------------------------------------------------------------
  tasks.push ( done ) =>
    #-------------------------------------------------------------------------------------------------------
    ### TAINT pass in route? use options? ###
    @walk_lunar_distance_events ( error, event ) =>
      return handler error if error?
      return done null if event is null
      #.....................................................................................................
      lunar_event_batch.push event
  #---------------------------------------------------------------------------------------------------------
  tasks.push ( done ) =>
    #-------------------------------------------------------------------------------------------------------
    ### TAINT pass in route? use options? ###
    @walk_lunar_declination_events ( error, event ) =>
      return handler error if error?
      return done null if event is null
      #.....................................................................................................
      lunar_event_batch.push event
  #---------------------------------------------------------------------------------------------------------
  ASYNC.parallel tasks, ( error ) =>
    return handler error if error?
    handler null, [
      tidal_extrema_event_batch
      tidal_hl_event_batch
      lunar_event_batch         ]
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@_align_lunar_with_tidal_event = ( tidal_events, lunar_event ) ->
  #---------------------------------------------------------------------------------------------------------
  get_compare = ( probe_event ) =>
    return ( data_event ) =>
      return probe_event[ 'date' ] - data_event[ 'date' ]
  #---------------------------------------------------------------------------------------------------------
  category          = lunar_event[ 'category' ]
  lunar_date        = lunar_event[ 'date' ]
  idx               = bSearch.closest tidal_events, get_compare lunar_event
  throw new Error "should never happen: uanble to align events" unless idx?
  tidal_event       = tidal_events[ idx ]
  #.........................................................................................................
  tidal_event[ 'lunar-events' ][ category ] = lunar_event
  return tidal_event

#-----------------------------------------------------------------------------------------------------------
@read_aligned_events = ( route, handler ) ->
  #---------------------------------------------------------------------------------------------------------
  @read_tidal_and_lunar_event_batches route, ( error, event_batches ) =>
    throw error if error?
    #.......................................................................................................
    [ tidal_extrema_event_batch
      tidal_hl_event_batch
      lunar_event_batch         ] = event_batches
    #.......................................................................................................
    for lunar_event in lunar_event_batch
      @_align_lunar_with_tidal_event tidal_hl_event_batch, lunar_event
    #.......................................................................................................
    return handler null, [ tidal_extrema_event_batch, tidal_hl_event_batch, ]
  #---------------------------------------------------------------------------------------------------------
  return null



# ############################################################################################################
# unless module.parent?
#   # @_demo_walk_tide_and_moon_events()
#   # @_demo_walk()
#   # @_demo_walk_lunar_events()
#   @_demo_align_tide_and_moon_events()

