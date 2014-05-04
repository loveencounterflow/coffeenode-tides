


#-----------------------------------------------------------------------------------------------------------
module.exports = sine = ( x0, y0, x1, y1, x ) ->
  ### Given two points `x0, y0` and `x1, y1` and an `x`, return the value of the ascending or descending
  sine function that passes with its extrema through `x0, y0` and `x1, y1`. ###
  scale_x = Math.PI / ( x1 - x0 )
  dx      = if y0 < y1 then Math.PI else 0
  scale_y = Math.abs y1 - y0
  dy      = Math.min y0, y1
  return dy + scale_y * ( 1 + Math.cos dx + scale_x * ( x - x0 ) ) / 2


############################################################################################################
unless module.parent?
  TEXT                      = require 'coffeenode-text'
  TRM                       = require 'coffeenode-trm'
  # FS                        = require 'coffeenode-fs'
  rpr                       = TRM.rpr.bind TRM
  badge                     = 'sine'
  log                       = TRM.get_logger 'plain',     badge
  info                      = TRM.get_logger 'info',      badge
  whisper                   = TRM.get_logger 'whisper',   badge
  alert                     = TRM.get_logger 'alert',     badge
  debug                     = TRM.get_logger 'debug',     badge
  warn                      = TRM.get_logger 'warn',      badge
  help                      = TRM.get_logger 'help',      badge
  echo                      = TRM.echo.bind TRM
  #.........................................................................................................
  x0 = 10
  y0 = 50
  x1 = 50
  y1 = 150
  for x in [ x0 .. x1 ] by 1
    y     = sine x0, y0, x1, y1, x
    bar   = ( new Array Math.floor y + 1 ).join '#'
    x_txt = TEXT.flush_right ( x ), 4
    y_txt = TEXT.flush_right ( y.toFixed 3 ), 8
    info x_txt, y_txt, bar
  info()
  #.........................................................................................................
  x0 = 51
  y0 = 150
  x1 = 120
  y1 = 50
  for x in [ x0 .. x1 ] by 1
    y     = sine x0, y0, x1, y1, x
    bar   = ( new Array Math.floor y + 1 ).join '#'
    x_txt = TEXT.flush_right ( x ), 4
    y_txt = TEXT.flush_right ( y.toFixed 3 ), 8
    info x_txt, y_txt, bar





