

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
badge                     = 'TIDES/fetch-data'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
mk_request                = require 'request'

### TAINT should go to TIDES/options ###
options =
  url:              'http://live.getij.nl/export.cfm'
  qs:
    format:           'txt'
    from:             '01-01-2014'
    to:               '31-12-2014'
    # uitvoer:          '1' # tijdreeksen
    uitvoer:          '2' # hoog- en laagwaters
    interval:         '10'
    lunarphase:       'yes'
    # location:         'YERSKE'
    # location:         'HARLGN'
    location:         'SCHIERMNOG'
    Timezone:         'MET_DST'
    refPlane:         'LAT'
    graphRefPlane:    'LAT'
    bottom:           '0'
    keel:             '0'

mk_request.get options, ( error, response, body ) ->
  throw error if error?
  echo body


