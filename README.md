

## CoffeeNode Tides

CoffeeNode Tides is a (Xe)(La)TeX source generator to produce typographically appealing and moderately complex
tidal calendars. I started this project a while ago for fun, so it's not fully usable as yet, but maybe
someone can make use of it.

For starters, here's what the current output looks like:

<img src='https://github.com/loveencounterflow/coffeenode-tides/raw/master/art/Screen%20Shot%202014-03-20%20at%2020.47.55.png' width=400px>

You'll immediately notice some flaws here:

* most obviously, the lines in the low tide column strike through the times given; this is a result of the
  trick i used to shift those times to their offset positions.

* I actually want those lines to separate dates by enclosing them in boxes, so people don't have to guess
  which times belongs to which date; however, with the current table setting strategy his will almost
  be impossible to do. As a next step, i want to typeset in twice the number of rows and use `multirow`s
  so that the *visual* rows can be offset by a half row's height (still with me?).

* There are lines missing in the low tide column; this is due to a flaw in the data reader.

* There is no column and page breaking implemented as yet, so the table will just run off the page.

* I plan to include curves to visualize tidal levels; i already have this output (which is planned to appear
  to the right of the times columns):

  <img src='https://github.com/loveencounterflow/coffeenode-tides/raw/master/art/Screen%20Shot%202014-03-20%20at%2021.40.43.png' width=100px>

  The left line symbolizes the heights of the high water, the right one the heights of the low water
  point. I hope i got the figures right. Maybe i add another line in the middle that shows the actual water
  level at all times.

  Incidentally, you can see how tides do not only change the water levels as such, but also cause
  a similar change in the minima and maxima of the level—in other words, its a wave within a wave within
  wave, from maybe centennial trends down to tides proper and then on to waves big and small and again on to tiny
  ripples on the water's surface. That's truly turtles all the way down, and very amazing. It may also be
  interesting and helpful for people using the calender.

  While this output does not look so grand when seen in isolation, i want to add a grid for height
  orientation with references to Normaal Amsterdams Peil (NAP, Amsterdam Ordnance Datum) and Lowest
  Astronomical Tide (LAT) as well as horizontal lines to link to the respective time.

  Currently i use the [`hobby`](http://ftp.uni-erlangen.de/mirrors/CTAN/graphics/pgf/contrib/hobby/hobby_doc.pdf)
  package to draw the curves; it is reasonably simple to use, but takes a considerable time to get each
  curve drawn, so maybe i'll look for a way to do this outside of TeX.

### License (Must Read)

The use of this software and any included files is free for anyone. Please consider attribution if you
want to base your own stuff on this project. Thanks.

### Disclaimer (Must Read)

Users of this software must have read, understood, and agreed to the below three disclaimers in order for
the License of this product to become valid.

#### Disclaimer for CoffeeNode Tides

> In case you don't believe me, you will perhaps believe Rijkswaterstaat, the world's leading agency on
> coastal protection. These guys have managed to keep the Netherlands dry for several hundred years, so they
> probably know what they're talking about when it comes to estimating the value tidal predictions:

Please note that **this Tical Calender can not and does not display *actual* water levels**; all it does
is to *attempt* and deliver tidal predictions that enthusiasts may find interesting. **Any data given here
is without any claim explicit or implicit of fitness for any particular purpose**; it is **definitely not
suitable for navigation**, simply because **all actual water levels *will* differ considerably from the figures
given here with near-certainty** (that's the fine difference between astronomical tides projected into the
future and actual tides as known from direct observation or past measurements. Also **there may be faults in
the data and / or data processing**).

#### Disclaimer from Rijkswaterstaat

Gebruik van de informatie op deze data is voor eigen risico. De getoonde gegevens zijn gebaseerd op de best
beschikbare kennis en informatie van Rijkswaterstaat. Desondanks kunnen de werkelijke gegevens door
verschillende oorzaken afwijken van de hier getoonde actuele gegevens. Een afwijking kan bijvoorbeeld zitten
in de getoonde verwachtingen.

> from http://www.rijkswaterstaat.nl/geotool/astronomisch_getij.aspx?cookieload=true

#### Disclaimer from XTide

> **Note** while currently no use of `xtide` has been made to produce the current software, this may change
> in the future.

> from http://www.flaterco.com/xtide/disclaimer.html

NOT FOR NAVIGATION

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  The author assumes no liability
for damages arising from use of this program OR of any 'harmonics data' that might be distributed with it.
For details, see the appended GNU General Public License.

(Accurate tide predictions can only be made if the 'harmonics data' for the relevant location are good.
(Unfortunately, the only way the maintainer of those data has of knowing when they are bad is when someone
(with access to authoritative tide predictions or observations reports a problem.  You should not use this
(program or any data files that might be distributed with it if anyone or anything could come to harm as a
(result of an incorrect tide prediction.  NOAA and similar agencies in other countries can provide you with
(certified tide predictions if that is what you need.)

XTide's predictions do not incorporate the effects of tropical storms, El Niño, seismic events, subsidence,
uplift, or changes in global sea level.

