




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
TIDES                     = require './main'
### TAINT global setting ###
TRM.depth_of_inspect      = 2

#===========================================================================================================
# DEMOS
#-----------------------------------------------------------------------------------------------------------
@walk_tidal_and_lunar_phase_event_batches = ->
  route = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  #---------------------------------------------------------------------------------------------------------
  TIDES.read_tidal_and_lunar_event_batches route, ( error, event_batches ) =>
    throw error if error?
    #.......................................................................................................
    for event_batch in event_batches
      #.....................................................................................................
      for event in event_batch
        date      = event[ 'date' ]
        date_txt  = if date? then date.format 'dddd, D. MMMM YYYY HH:mm' else './.'
        #...................................................................................................
        switch type = TYPES.type_of event
          #.................................................................................................
          when 'TIDES/lunar-event'
            switch category = event[ 'category' ]
              when 'phase'
                quarter         = event[ 'marker' ]
                symbol          = TIDES.options[ 'data' ][ 'moon' ][ 'unicode' ][ quarter ]
                log TRM.lime date_txt, quarter, symbol
              when 'distance'
                ap              = event[ 'marker' ]
                distance_km     = event[ 'details' ][ 'distance.km' ]
                log TRM.blue date_txt, ap, "#{distance_km}km"
              when 'declination'
                sn              = event[ 'marker' ]
                declination_deg = event[ 'details' ][ 'declination.deg' ]
                log TRM.orange date_txt, sn, "#{declination_deg}°"
              else
                warn "skipped event with category #{rpr category}"
          #.................................................................................................
          when 'TIDES/tidal-event'
            hl      = event[ 'hl' ]
            height  = event[ 'height' ]
            log TRM.gold date_txt, hl, height
          #.................................................................................................
          when 'TIDES/tidal-extrema-event'
            log TRM.cyan event
          #.................................................................................................
          else
            warn "unhandled event of type #{rpr type}"
  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
@read_aligned_events = ->
  route = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
  #---------------------------------------------------------------------------------------------------------
  TIDES.read_aligned_events route, ( error, event_batches ) =>
    throw error if error?
    #.......................................................................................................
    [ tidal_extrema_event_batch
      tidal_hl_event_batch      ] = event_batches
    #.......................................................................................................
    for primary_event in tidal_hl_event_batch
      date_txt          = primary_event[ 'date' ].format 'dd DD.MM.YYYY HH:mm'
      hl                = primary_event[ 'hl' ]
      height            = primary_event[ 'height' ]
      log TRM.gold date_txt, hl, height
      secondary_events  = primary_event[ 'lunar-events' ]
      #.....................................................................................................
      if ( secondary_event = secondary_events[ 'phase' ]       )?
        date_txt        = secondary_event[ 'date' ].format 'dd DD.MM.YYYY HH:mm'
        quarter         = secondary_event[ 'marker' ]
        symbol          = TIDES.options[ 'data' ][ 'moon' ][ 'unicode' ][ quarter ]
        log TRM.lime date_txt, quarter, symbol
      #.....................................................................................................
      if ( secondary_event = secondary_events[ 'distance' ]    )?
        date_txt        = secondary_event[ 'date' ].format 'dd DD.MM.YYYY HH:mm'
        ap              = secondary_event[ 'marker' ]
        distance_km     = secondary_event[ 'details' ][ 'distance.km' ]
        distance_ed     = distance_km / 12742
        # log TRM.blue date_txt, ap, "#{distance_km}km"
        log TRM.blue date_txt, ap, "#{distance_ed}ed"
      #.....................................................................................................
      if ( secondary_event = secondary_events[ 'declination' ] )?
        date_txt        = secondary_event[ 'date' ].format 'dd DD.MM.YYYY HH:mm'
        sn              = secondary_event[ 'marker' ]
        declination_deg = secondary_event[ 'details' ][ 'declination.deg' ]
        log TRM.red date_txt, sn, "#{declination_deg}°"


# #-----------------------------------------------------------------------------------------------------------
# @_demo_align_tide_and_moon_events = ->
#   # route         = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
#   route         = njs_path.join __dirname, '../tidal-data/Yerseke.txt'
#   tidal_events  = []
#   lunar_events  = []
#   #---------------------------------------------------------------------------------------------------------
#   get_compare = ( probe_event ) =>
#     return ( data_event ) =>
#       return probe_event[ 'date' ] - data_event[ 'date' ]
#   #---------------------------------------------------------------------------------------------------------
#   collect = ( handler ) =>
#     #-------------------------------------------------------------------------------------------------------
#     TIDES.walk_tide_and_moon_events route, ( error, event ) =>
#       return handler error if error?
#       return handler null if event is null
#       switch type = TYPES.type_of event
#         when 'TIDES/lunar-event'
#           lunar_events.push event
#         when 'TIDES/tidal-event'
#           tidal_events.push event
#         else
#           warn "unhandled event of type #{rpr type}"
#   #---------------------------------------------------------------------------------------------------------
#   splice = => # ( handler ) =>
#     collect ( error ) =>
#       throw error if error?
#       for collection in [ lunar_events, ]
#         for lunar_event in lunar_events
#           lunar_date        = lunar_event[ 'date' ]
#           lunar_date_txt    = lunar_date.format 'YY-MM-DD HH:mm Z', 'Europe/Amsterdam'
#           # lunar_event_txt   = "#{lunar_date_txt} #{lunar_event[ 'category' ]} #{lunar_event[ 'marker' ]}"
#           lunar_event_txt   = "#{lunar_date_txt} #{lunar_event[ 'quarter' ]}"
#           idx               = bSearch.closest tidal_events, get_compare lunar_event
#           tidal_event       = tidal_events[ idx ]
#           tidal_date        = tidal_event[ 'date' ]
#           tidal_date_txt    = tidal_date.format 'YY-MM-DD HH:mm Z', 'Europe/Amsterdam'
#           tidal_event_txt   = "#{tidal_date_txt} #{tidal_event[ 'hl' ]}"
#           log ( TRM.lime tidal_event_txt ), ( TRM.gold lunar_event_txt )
#   #.........................................................................................................
#   splice()
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @_demo_walk = ->
#   _                 = require 'lodash'
#   TIDES             = @
#   route             = njs_path.join __dirname, '../tidal-data/Vlieland-haven.txt'
#   tide_moon_counts  = []
#   tide_idx          = 0
#   last_moon_idx     = null
#   #---------------------------------------------------------------------------------------------------------
#   TIDES.walk route, ( error, event ) =>
#     throw error if error?
#     #.......................................................................................................
#     if event is null
#       # info tide_moon_counts
#       info _.countBy tide_moon_counts
#       return
#     #.......................................................................................................
#     tide_idx += 1
#     date      = event[ 'date' ]
#     date_txt  = date.format 'ddd, DD. MMM YYYY HH:mm'
#     hl        = event[ 'hl' ]
#     height    = event[ 'height' ]
#     event_txt = TRM.gold date_txt, hl, height
#     #.......................................................................................................
#     if ( moon_event = event[ 'moon' ] )?
#       if ( moon_event[ 'quarter' ] is 0 ) # or ( moon_event[ 'quarter' ] is 2 )
#         tide_moon_counts.push tide_idx - last_moon_idx if last_moon_idx?
#         last_moon_idx   = tide_idx
#       date            = moon_event[ 'date' ]
#       date_txt        = date.format 'ddd, D. MMM YYYY HH:mm'
#       quarter         = moon_event[ 'quarter' ]
#       symbol          = TIDES.options[ 'data' ][ 'moon' ][ 'unicode' ][ quarter ]
#       event_txt      += ' ' + TRM.lime date_txt, quarter, symbol
#     #.......................................................................................................
#     log event_txt
#   #---------------------------------------------------------------------------------------------------------
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @_demo_walk_lunar_events = ->
#   @walk_lunar_distance_events ( error, event ) ->
#     throw error if error?
#     return if event is null
#     debug event[ 'category' ], event[ 'marker' ], event[ 'date' ].toString(), event[ 'details' ]
#   @walk_lunar_declination_events ( error, event ) ->
#     throw error if error?
#     return if event is null
#     debug event[ 'category' ], event[ 'marker' ], event[ 'date' ].toString(), event[ 'details' ]

#-----------------------------------------------------------------------------------------------------------
@_demo_momentjs = ->
  info moment() - moment '2012-01-01'
  info
  #.........................................................................................................
  high_and_low_water_times = [
    new Date '2014-12-27T00:51'
    new Date '2014-12-27T07:12'
    new Date '2014-12-27T13:20'
    new Date '2014-12-27T19:46'
    new Date '2014-12-28T01:45'
    new Date '2014-12-28T08:06'
    new Date '2014-12-28T14:16'
    new Date '2014-12-28T20:40'
    new Date '2014-12-29T02:41'
    new Date '2014-12-29T08:58'
    new Date '2014-12-29T15:10'
    new Date '2014-12-29T21:38'
    new Date '2014-12-30T03:35'
    new Date '2014-12-30T10:02'
    new Date '2014-12-30T16:09'
    new Date '2014-12-30T22:45'
    ]
  #.........................................................................................................
  first_quarter = new Date '2014-12-28T19:31'
  idx = bSearch.closest high_and_low_water_times, first_quarter
  #.........................................................................................................
  info 'first quarter:                         ', first_quarter
  info()
  info 'closest tidal event:                   ', high_and_low_water_times[ idx ]
  info()
  #.........................................................................................................
  milliseconds  =    1
  seconds       = 1000 * milliseconds
  minutes       =   60 * seconds
  hours         =   60 * minutes
  twelve_hours  =   12 * hours
  #.........................................................................................................
  [ lo_idx, hi_idx ] = bSearch.interval high_and_low_water_times, ( value ) ->
    dt = first_quarter - value
    return  0 if  ( Math.abs dt ) <= twelve_hours
    return +1 if  dt > 0
    return -1
  #.........................................................................................................
  for idx in [ lo_idx .. hi_idx ]
    info 'tidal event closer than twelve hours:  ', high_and_low_water_times[ idx ]


############################################################################################################
unless module.parent?
  # @_demo_walk_tidal_and_lunar_phase_event_batches()
  @read_aligned_events()

