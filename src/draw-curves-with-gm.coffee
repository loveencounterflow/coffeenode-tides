

############################################################################################################
# njs_util                  = require 'util'
njs_fs                    = require 'fs'
njs_path                  = require 'path'
#...........................................................................................................
# BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
# FS                        = require 'coffeenode-fs'
rpr                       = TRM.rpr.bind TRM
badge                     = 'TIDES/draft'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
GM                        = require 'gm'

options =
  'pixels-per-mm':    15
  # 'pixels-per-mm':    3
  'width.mm':         118
  'height.mm':        178
  'width.px':         null
  'height.px':        null
  ### TAINT this value from `write-tex#module` ###
  'line-height.mm':   2.871
  'line-height.px':   null
  'x-offset.mm':      90
  'x-offset.px':      null

#-----------------------------------------------------------------------------------------------------------
@_compile_options = ( options ) ->
  options[ 'width.px'       ] = options[ 'width.mm'       ] * options[ 'pixels-per-mm' ]
  options[ 'height.px'      ] = options[ 'height.mm'      ] * options[ 'pixels-per-mm' ]
  options[ 'line-height.px' ] = options[ 'line-height.mm' ] * options[ 'pixels-per-mm' ]
  options[ 'x-offset.px'    ] = options[ 'x-offset.mm'    ] * options[ 'pixels-per-mm' ]

#-----------------------------------------------------------------------------------------------------------
@_image_px_from_origin_mm = ( d_mm ) ->
  return d_mm * options[ 'pixels-per-mm' ]

#-----------------------------------------------------------------------------------------------------------
@_image_px_from_real_cm = ( x_real_cm ) ->
  ### TAINT magic number 14 ###
  return options[ 'x-offset.px' ] - x_real_cm * options[ 'pixels-per-mm' ] / 14

#-----------------------------------------------------------------------------------------------------------
@_image_px_from_y_raw = ( y_raw ) ->
  ### TAINT make configurable ###
  return ( 0.75 + y_raw ) * options[ 'line-height.px' ]

#-----------------------------------------------------------------------------------------------------------
@_convert_dots_to_mm = ( raw_dots ) ->
  R = []
  for raw_dot, idx in raw_dots
    [ hl, [ x_real_cm, y_raw, ], ] = raw_dot
    x = @_image_px_from_real_cm  x_real_cm
    y = @_image_px_from_y_raw    y_raw
    R.push [ hl, [ x, y, ], ]
  return R

#-----------------------------------------------------------------------------------------------------------
@_get_control_points_for_vertical_bezier = ( point0, point3 ) ->
  #.......................................................................................................
  [ x0, y0, ] = point0
  [ x3, y3, ] = point3
  y1 = y2     = Math.floor ( y0 + y3 ) / 2 + 0.5
  x1          = x0
  x2          = x3
  return [ [ x1, y1, ], [ x2, y2, ] ]

#-----------------------------------------------------------------------------------------------------------
module.exports = @_draw_curves_with_gm = ( route, raw_dots, handler ) ->
  ### Given the series for line indices and water level maxima and minima (in cm relative to LAT), return
  a LaTeX snippet to include the respective image file. Missing image files will be generated on the fly.
  ###
  bezier_tide_points  = []
  bezier_h_points     = []
  bezier_l_points     = []
  #.........................................................................................................
  dots                = @_convert_dots_to_mm raw_dots
  #.........................................................................................................
  for dot0, idx in dots
    [ hl0, point0, ]    = dot0
    dot3 = raw_dots[ idx + 1 ]
    break unless dot3?
    [ hl3, point3, ]    = dot3
    [ point1, point2, ] = @_get_control_points_for_vertical_bezier point0, point3
    bezier_tide_points.push [ hl0, [ point0, point1, point2, point3, ], ]
  #.........................................................................................................
  ### TAINT ratio pixels / mm should be configurable ###
  image = GM options[ 'width.px' ], options[ 'height.px' ], "#ffffffff"
    .fontSize 68
    # .stroke "#ff5533", 5
    # .stroke "#ff5533", 1
    # .fill '#123456'
    .fill 'transparent'
    .stroke "black", 2
    # .stroke "blue", 4
  #.........................................................................................................
  ### draw LAT vertical ###
  x0 = x1 = @_image_px_from_real_cm 0
  y0 = @_image_px_from_y_raw  0
  y1 = @_image_px_from_y_raw 60
  image
    .stroke "black", 1
    .drawLine x0, y0, x1, y1
  #.........................................................................................................
  ### draw NAP vertical ###
  ### TAINT must get NAP - LAT difference from RWS for each location ###
  x0 = x1 = @_image_px_from_real_cm 0 + 203
  y0 = @_image_px_from_y_raw  0
  y1 = @_image_px_from_y_raw 60
  image
    .stroke "black", 1
    .drawLine x0, y0, x1, y1
  #.........................................................................................................
  for [ hl, points, ], idx in bezier_tide_points
    image
      .stroke "black", 1
      .drawBezier points...
    ### draw HL horizontal ###
    if idx is 0
      x0 = @_image_px_from_real_cm 0
    else
      x0 = points[ 0 ][ 0 ]
    ### TAINT these numbers also in `write-tex`; save in options ###
    x1 = @_image_px_from_origin_mm ( if hl is 'h' then 40 else 55 ) + 1
    y0 = y1 = points[ 0 ][ 1 ]
    image
      .stroke "black", 1
      .drawLine x0, y0, x1, y1

  #.........................................................................................................
  image.write route, ( error ) ->
    return handler error if error?
    # log @outname + " created :: " + arguments[3]
    handler null
  #.........................................................................................................
  return null


############################################################################################################
@_compile_options options
module.exports = module.exports.bind @

x = 42

f = ->
  # x = 8
  f ( error, result, x ) =>
    # @d = 1
    x = 108
    # x = 8+5
    return null



