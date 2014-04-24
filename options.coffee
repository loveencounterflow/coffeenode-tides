



#-----------------------------------------------------------------------------------------------------------
settings =
  #.........................................................................................................
  ### Choose your language: ###
  language:   'nl_NL'
  # language:   'de_DE'
  #.........................................................................................................
  ### Choose your styles: ###
  styles:
    weekdays:   'abbreviated'
    # months:     'abbreviated'
    months:     'full'
    moon:       'plain'
    # moon:       'unicode'
    layout:     'plain'

############################################################################################################
values =
  #.........................................................................................................
  # weekdays:   '${/data/translations/${/settings/language}/weekdays/${/settings/styles/weekdays}}'
  # months:     '${/data/translations/${/settings/language}/months/${/settings/styles/months}}'
  moon:       '${/data/moon/${/settings/styles/moon}}'
  layout:     '${/data/layouts/${/settings/styles/layout}}'

#-----------------------------------------------------------------------------------------------------------
data =
  #.........................................................................................................
  tides:
    'min-l-height': null
    'max-l-height': null
    'min-h-height': null
    'max-h-height': null
  #.........................................................................................................
  date:
    timezone:     'Europe/Amsterdam'
    'raw-format': 'DD/MM/YYYY HH:mm'
  #.........................................................................................................
  moon:
    'quarter-by-phases':
      'NM':       0
      'EK':       1
      'VM':       2
      'LK':       3
    unicode:
      [ '⬤', '◐', '◯', '◑', ]
    plain:    [
      '\\newmoon'
      '\\rightmoon'
      '\\fullmoon'
      '\\leftmoon' ]
  #.........................................................................................................
  # translations:
  #   #.......................................................................................................
  #   nl_NL:
  #     weekdays:
  #       #...................................................................................................
  #       full:         [ 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag', 'zondag', ]
  #       abbreviated:  [ 'ma', 'di', 'wo', 'do', 'vr', 'za', 'zo', ]
  #     #.....................................................................................................
  #     months:
  #       full:         [ "januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober", "november", "december", ]
  #       abbreviated:  [ "jan", "feb", "maart", "apr", "mei", "juni", "juli", "aug", "sept", "oct", "nov", "dec", ]
  #   #.......................................................................................................
  #   en_US:
  #     #.....................................................................................................
  #     weekdays:
  #       full:         [ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', ]
  #       abbreviated:  [ 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su', ]
  #     #.....................................................................................................
  #     months:
  #       full:         [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", ]
  #       abbreviated:  [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec", ]
  #   #.......................................................................................................
  #   de_DE:
  #     #.....................................................................................................
  #     weekdays:
  #       full:         [ 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag', ]
  #       abbreviated:  [ 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So', ]
  #     #.....................................................................................................
  #     months:
  #       full:         [ "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember", ]
  #       abbreviated:  [ "Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sept", "Okt", "Nov", "Dez", ]
  #.........................................................................................................
  ### All measurements in mm (this may change) ###
  layouts:
    plain:
      # paper:
      margins:
        outer:        10
        top:          12
      month:
        even:
          align:
            x:        'left'
            y:        'baseline'
          position:
            x:        '${/data/layouts/plain/margins/outer}'
            y:        '${/data/layouts/plain/margins/top}'
        odd:
          align:
            x:        'right'
            y:        'baseline'
          position:
            # x:        '${/data/layouts/plain/margins/outer}'
            x:        118
            # y:        '${/data/layouts/plain/margins/top}'
            y:        0


#===========================================================================================================
# GETTERS
#-----------------------------------------------------------------------------------------------------------
get = ( locator_or_crumbs, fallback ) ->
  return FI.get O, locator_or_crumbs, fallback

# #-----------------------------------------------------------------------------------------------------------
# get.moon_symbol_from_quarter = ( moon_quarter ) ->
#   locator = '/values/moon'
#   R       = O.get FI.get O, locator
#   return R[ moon_quarter ]

# #-----------------------------------------------------------------------------------------------------------
# get.weekday_from_idx = ( weekday_idx ) ->
#   locator = '/values/weekdays'
#   R       = O.get FI.get O, locator
#   return R[ weekday_idx ]

# #-----------------------------------------------------------------------------------------------------------
# get.month_from_idx = ( month_idx ) ->
#   locator = '/values/months'
#   R       = O.get FI.get O, locator
#   return R[ month_idx ]


############################################################################################################
FI                        = require 'coffeenode-fillin'
module.exports            = O = {}
misfit                    = {}

#...........................................................................................................
O[ 'settings' ] = settings
O[ 'values'   ] = values
O[ 'data'     ] = data
O[ 'get'      ] = get

FI.fill_in O


