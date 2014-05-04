



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
    moon:
      quarters:     'jzr'
      declination:  'jzr'
      distance:     'jzr'
    layout:     'plain'

############################################################################################################
values =
  #.........................................................................................................
  # weekdays:   '${/data/translations/${/settings/language}/weekdays/${/settings/styles/weekdays}}'
  # months:     '${/data/translations/${/settings/language}/months/${/settings/styles/months}}'
  moon:
    quarters:     '${/data/moon/quarters/${/settings/styles/moon/quarters}}'
    declination:  '${/data/moon/declination/${/settings/styles/moon/declination}}'
    distance:     '${/data/moon/distance/${/settings/styles/moon/distance}}'
  layout:     '${/data/layouts/${/settings/styles/layout}}'

#-----------------------------------------------------------------------------------------------------------
data =
  #.........................................................................................................
  extrema:
    tides:
      'min-l-height': null
      'max-l-height': null
      'min-h-height': null
      'max-h-height': null
    # moon:
    #   quarters:       null
    #   declination:    null
    #   distance:       null
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
    quarters:
      unicode:
        [ '⬤', '◐', '◯', '◑', ]
      plain:    [
        '\\newmoon'
        '\\rightmoon'
        '\\fullmoon'
        '\\leftmoon' ]
      jzr:    [
        '{\\moonFont{}^^^^e024}'
        '{\\moonFont{}^^^^e026}'
        '{\\moonFont{}^^^^e023}'
        '{\\moonFont{}^^^^e027}' ]
    distance:
      jzr:
        A:  '{\\moonFont{}^^^^e065}'
        P:  '{\\moonFont{}^^^^e064}'
    declination:
      jzr:
        N:  '{\\moonFont{}^^^^e063}'
        S:  '{\\moonFont{}^^^^e062}'
  #.........................................................................................................
  xxx:
    'AUKFPFM':      'Aukfield platform'
    'BAALHK':       'Baalhoek'
    'BATH':         'Bath'
    'BEERKNL':      'Beerkanaal'
    'BERGSDSWT':    'Bergse Diepsluis west'
    'BORSSLE':      'Borssele'
    'BRESKS':       'Breskens'
    'BROUWHVSGT02': 'Brouwershavensche Gat 02'
    'BROUWHVSGT08': 'Brouwershavensche Gat 08'
    'CADZD':        'Cadzand'
    'DELFZL':       'Delfzijl'
    'DENHDR':       'Den Helder'
    'DENOVBTN':     'Den Oever'
    'DINTHVN':      'Dintelhaven'
    'DORDT':        'Dordrecht'
    'EEMHVN':       'Eemhaven'
    'EEMSHVN':      'Eemshaven'
    'EURPFM':       'Euro platform'
    'EURPHVN':      'Europahaven'
    'GEULHVN':      'Geulhaven'
    'GOIDSOD':      'Goidschalxoord'
    'GOUDBG':       'Gouda brug'
    'HAGSBNDN':     'Hagestein beneden'
    'HANSWT':       'Hansweert'
    'HARLGN':       'Harlingen'
    'HARMSBG':      'Harmsenbrug'
    'HARTBG':       'Hartelbrug'
    'HARTHVN':      'Hartelhaven'
    'HARTKWT':      'Hartel-Kuwait'
    'HARVT10':      'Haringvliet 10'
    'HEESBN':       'Heesbeen'
    'HELLVSS':      'Hellevoetsluis'
    'HOEKVHLD':     'Hoek van Holland'
    'HUIBGT':       'Huibertgat'
    'IJMDBTHVN':    'IJmuiden'
    'K13APFM':      'K13A platform'
    'KATSBTN':      'Kats'
    'KEIZVR':       'Keizersveer'
    'KORNWDZBTN':   'Kornwerderzand'
    'KRAMMSZWT':    'Krammersluizen west'
    'KRIMPADIJSL':  'Krimpen aan de IJssel'
    'KRIMPADLK':    'Krimpen aan de Lek'
    'LAUWOG':       'Lauwersoog'
    'LICHTELGRE':   'Lichteiland Goeree'
    'LITHDP':       'Lith dorp'
    'MAASSS':       'Maassluis'
    'MARLGT':       'Marollegat'
    'MOERDK':       'Moerdijk'
    'NES':          'Nes'
    'NIEUWSTZL':    'Nieuwe Statenzijl'
    'NOORDWMPT':    'Meetpost Noordwijk'
    'OOSTSDE04':    'Oosterschelde 04'
    'OOSTSDE11':    'Oosterschelde 11'
    'OOSTSDE14':    'Oosterschelde 14'
    'OUDSD':        'Oudeschild'
    'OVLVHWT':      'Overloop van Hansweert'
    'PARKSS':       'Parksluis'
    'PETTZD':       'Petten zuid'
    'RAKND':        'Rak noord'
    'ROOMPBNN':     'Roompot binnen'
    'ROOMPBTN':     'Roompot buiten'
    'ROTTDM':       'Rotterdam'
    'ROZBSSNZDE':   'Rozenburgsesluis noordzijde'
    'SCHAARVDND':   'Schaar van de Noord'
    'SCHEURHVN':    'Scheurhaven'
    'SCHEVNGN':     'Scheveningen'
    'SCHIERMNOG':   'Schiermonnikoog'
    'SCHOONHVN':    'Schoonhoven'
    'SPIJKNSE':     'Spijkenisse'
    'STAVNSE':      'Stavenisse'
    'STELLDBTN':    'Haringvlietsluizen'
    'SUURHBNZDE':   'Suurhoffbrug noordzijde'
    'TERNZN':       'Terneuzen'
    'TERSLNZE':     'Terschelling Noordzee'
    'TEXNZE':       'Texel Noordzee'
    'VLAARDGN':     'Vlaardingen'
    'VLAKTVDRN':    'Vlakte van de Raan'
    'VLIELHVN':     'Vlieland haven'
    'VLISSGN':      'Vlissingen'
    'VURN':         'Vuren'
    'WALSODN':      'Walsoorden'
    'WERKDBTN':     'Werkendam buiten'
    'WESTKPLE':     'Westkapelle'
    'WESTTSLG':     'West-Terschelling'
    'WIERMGDN':     'Wierumergronden'
    'YERSKE':       'Yerseke'




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



############################################################################################################
FI                        = require 'coffeenode-fillin'
module.exports            = O = {}
misfit                    = {}

#...........................................................................................................
O[ 'settings' ] = settings
O[ 'values'   ] = values
O[ 'data'     ] = data

FI.fill_in O


