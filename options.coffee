
module.exports =
  #.........................................................................................................
  language:   'nl_NL'
  styles:
    weekdays:   'abbreviated'
  keys:
    weekdays:     '${/translations/${/language}/weekdays/${/styles/weekdays}}'
  #.........................................................................................................
  translations:
    #.......................................................................................................
    nl_NL:
      weekdays:
        #...................................................................................................
        full:         [ 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag', 'zondag', ]
        abbreviated:  [ 'ma', 'di', 'wo', 'do', 'vr', 'za', 'zo', ]
      #.....................................................................................................
      months:
        full:         [ "januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober", "november", "december", ]
        abbreviated:  [ "jan", "feb", "maart", "apr", "mei", "juni", "juli", "aug", "sept", "oct", "nov", "dec", ]
    #.......................................................................................................
    en_US:
      #.....................................................................................................
      weekdays:
        full:         [ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', ]
        abbreviated:  [ 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su', ]
      #.....................................................................................................
      months:
        full:         [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", ]
        abbreviated:  [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec", ]
    #.......................................................................................................
    de_DE:
      #.....................................................................................................
      weekdays:
        full:         [ 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag', ]
        abbreviated:  [ 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So', ]
      #.....................................................................................................
      months:
        full:         [ "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember", ]
        abbreviated:  [ "Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sept", "Okt", "Nov", "Dez", ]

###

{
  "language": "dutch",
  "foo": [
    "$bar",
    "${/bar}",
    "${/weekday-names}",
    "${/weekday-names/dutch/full/0}",
    "${/weekday-names/$language/full/0}",
    "${/weekday-names/${/language}/full/0}",
    "$bar:quoted" ],
  "bar": 42,
  "columns": [],
  "moon-symbols": {
    "unicode": [
      "⬤",
      "◐",
      "◯",
      "◑"
    ],
    "tex": [
      "\\newmoon",
      "\\rightmoon",
      "\\fullmoon",
      "\\leftmoon"
    ]
  },
  "weekday-names": {
    "dutch": {
      "full": [
        "maandag",
        "dinsdag",
        "woensdag",
        "donderdag",
        "vrijdag",
        "zaterdag",
        "zondag"
      ],
      "abbreviated": [
        "ma",
        "di",
        "wo",
        "do",
        "vr",
        "za",
        "zo"
      ]
    }
  },
  "month-names": {
    "dutch": {
      "full": [
        "januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober", "november", "december"
      ],
      "abbreviated": [
        "jan", "feb", "maart", "apr", "mei", "juni", "juli", "aug", "sept", "oct", "nov", "dec"
      ]
    }
  }
}
###