// Generated by CoffeeScript 1.7.1
(function() {
  var FI, O, data, get, misfit, settings, values;

  settings = {

    /* Choose your language: */
    language: 'nl_NL',

    /* Choose your styles: */
    styles: {
      weekdays: 'abbreviated',
      months: 'full',
      moon: 'plain',
      layout: 'plain'
    }
  };

  values = {
    moon: '${/data/moon/${/settings/styles/moon}}',
    layout: '${/data/layouts/${/settings/styles/layout}}'
  };

  data = {
    date: {
      timezone: 'Europe/Amsterdam',
      'raw-format': 'DD/MM/YYYY HH:mm'
    },
    moon: {
      'quarter-by-phases': {
        'NM': 0,
        'EK': 1,
        'VM': 2,
        'LK': 3
      },
      unicode: ['⬤', '◐', '◯', '◑'],
      plain: ['\\newmoon', '\\rightmoon', '\\fullmoon', '\\leftmoon']
    },

    /* All measurements in mm (this may change) */
    layouts: {
      plain: {
        margins: {
          outer: 10,
          top: 12
        },
        month: {
          even: {
            align: {
              x: 'left',
              y: 'baseline'
            },
            position: {
              x: '${/data/layouts/plain/margins/outer}',
              y: '${/data/layouts/plain/margins/top}'
            }
          },
          odd: {
            align: {
              x: 'right',
              y: 'baseline'
            },
            position: {
              x: 118,
              y: 0
            }
          }
        }
      }
    }
  };

  get = function(locator_or_crumbs, fallback) {
    return FI.get(O, locator_or_crumbs, fallback);
  };

  FI = require('coffeenode-fillin');

  module.exports = O = {};

  misfit = {};

  O['settings'] = settings;

  O['values'] = values;

  O['data'] = data;

  O['get'] = get;

  FI.fill_in(O);

}).call(this);
