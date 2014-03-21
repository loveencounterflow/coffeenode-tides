

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





hl_raw_dots = [
  [
    [ 1, 247 ]
    [ 2, 257 ]
    [ 3, 245 ]
    [ 4, 262 ]
    [ 5, 241 ]
    [ 6, 267 ]
    [ 7, 237 ]
    [ 8, 269 ]
    [ 9, 233 ]
    [ 10, 269 ]
    [ 11, 228 ]
    [ 12, 265 ]
    [ 13, 223 ]
    [ 14, 258 ]
    [ 15, 218 ]
    [ 16, 248 ]
    [ 17, 214 ]
    [ 18, 237 ]
    [ 19, 211 ]
    [ 20, 228 ]
    [ 21, 213 ]
    [ 22, 225 ]
    [ 23, 222 ]
    [ 24, 227 ]
    [ 25, 233 ]
    [ 26, 230 ]
    [ 27, 241 ]
    [ 28, 229 ]
    [ 29, 245 ]
    [ 30, 227 ]
    [ 31, 248 ]
    [ 32, 227 ]
    [ 33, 251 ]
    [ 34, 227 ]
    [ 35, 253 ]
    [ 36, 227 ]
    [ 37, 253 ]
    [ 38, 225 ]
    [ 39, 250 ]
    [ 40, 222 ]
    [ 41, 246 ]
    [ 42, 218 ]
    [ 43, 242 ]
    [ 44, 215 ]
    [ 45, 237 ]
    [ 46, 212 ]
    [ 47, 231 ]
    [ 48, 209 ]
    [ 49, 225 ]
    [ 50, 210 ]
    [ 51, 223 ]
    [ 52, 220 ]
    [ 53, 228 ]
    [ 54, 234 ]
    [ 55, 234 ]
    [ 56, 247 ]
    [ 57, 237 ]
    [ 58, 257 ]
    [ 59, 237 ]
    [ 60, 263 ]
  ],
  [
    [ 0, 42 ]
    [ 1, 39 ]
    [ 2, 35 ]
    [ 3, 35 ]
    [ 4, 30 ]
    [ 5, 31 ]
    [ 6, 27 ]
    [ 7, 28 ]
    [ 8, 27 ]
    [ 9, 26 ]
    [ 10, 30 ]
    [ 11, 28 ]
    [ 12, 38 ]
    [ 13, 33 ]
    [ 14, 47 ]
    [ 15, 42 ]
    [ 16, 58 ]
    [ 17, 53 ]
    [ 18, 67 ]
    [ 19, 62 ]
    [ 20, 72 ]
    [ 21, 65 ]
    [ 22, 69 ]
    [ 23, 61 ]
    [ 24, 62 ]
    [ 25, 54 ]
    [ 26, 55 ]
    [ 27, 50 ]
    [ 28, 51 ]
    [ 29, 49 ]
    [ 30, 48 ]
    [ 31, 49 ]
    [ 32, 45 ]
    [ 33, 47 ]
    [ 34, 41 ]
    [ 35, 45 ]
    [ 36, 38 ]
    [ 37, 45 ]
    [ 38, 39 ]
    [ 39, 46 ]
    [ 40, 41 ]
    [ 41, 49 ]
    [ 42, 45 ]
    [ 43, 53 ]
    [ 44, 48 ]
    [ 45, 56 ]
    [ 46, 54 ]
    [ 47, 61 ]
    [ 48, 60 ]
    [ 49, 64 ]
    [ 50, 63 ]
    [ 51, 62 ]
    [ 52, 58 ]
    [ 53, 54 ]
    [ 54, 48 ]
    [ 55, 45 ]
    [ 56, 37 ]
    [ 57, 36 ]
    [ 58, 27 ]
    [ 59, 27 ]
  ] ]
for raw_dots in hl_raw_dots
  for dot in raw_dots
    [ dot[ 1 ], dot[ 0 ] ] = dot
    dot[ 0 ] = Math.floor ( ( dot[ 0 ] +  0 ) *  10 ) + 100 + 0.5
    dot[ 1 ] = Math.floor ( ( dot[ 1 ] +  0 ) *  50 ) +   0 + 0.5

debug hl_raw_dots

# hl_bezier_dots = raw_dots
hl_bezier_dots = []
for raw_dots in hl_raw_dots
  bezier_dots = []
  hl_bezier_dots.push bezier_dots
  for dot0, idx in raw_dots
    dot3 = raw_dots[ idx + 1 ]
    break unless dot3?
    [ x0, y0, ] = dot0
    [ x3, y3, ] = dot3
    y1 = y2 = Math.floor ( y0 + y3 ) / 2 + 0.5
    x1 = x0
    x2 = x3
    bezier_dots.push [ dot0, [ x1, y1, ], [ x2, y2, ], dot3, ]

dir = '/tmp'

# GM 1000, 1000, "#00ff55aa"
image = GM 500, 3000, "#ffffff00"
  .fontSize 68
  # .stroke "#ff5533", 5
  # .stroke "#ff5533", 1
  # .fill '#123456'
  .fill 'transparent'
  .stroke "red", 1

for bezier_dots in hl_bezier_dots
  for dots in bezier_dots
    image.drawBezier dots...

# image.fill 'blue'
for bezier_dots in hl_bezier_dots
  for dots in hl_bezier_dots
    ### TAINT leaving out last dot ###
    dot0 = dots[ 0 ]
    dot1 = [ dot0[ 0 ] + 2, dot0[ 1 ], ]
    debug dot1
    # image.drawCircle dot0..., dot1...

image.write dir + "/new.png", ( error ) ->
    throw error if error?
    console.log @outname + " created :: " + arguments[3]
    return






