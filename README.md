

- [CoffeeNode Tides](#coffeenode-tides)
	- [Observations](#observations)
	- [License (Must Read)](#license-must-read)
	- [Disclaimer (Must Read)](#disclaimer-must-read)
		- [Disclaimer for CoffeeNode Tides](#disclaimer-for-coffeenode-tides)
		- [Disclaimer from Rijkswaterstaat](#disclaimer-from-rijkswaterstaat)
		- [Disclaimer from XTide](#disclaimer-from-xtide)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


## CoffeeNode Tides

CoffeeNode Tides is a (Xe)(La)TeX source generator to produce typographically appealing and moderately complex
tidal calendars. I started this project a while ago for fun, so it's not fully usable as yet, but maybe
someone can make use of it.

For starters, here's what the current output looks like:

<img src='https://github.com/loveencounterflow/coffeenode-tides/raw/master/art/Screen%20Shot%202014-04-02%20at%2013.08.21.png' width=400px>

And this is the output from an earlier incarnation of my code:

<img src='https://github.com/loveencounterflow/coffeenode-tides/raw/master/art/Screen%20Shot%202014-03-20%20at%2020.47.55.png' width=400px>

I've concentrated my efforts on getting those curves right, and the way i'm doing that may be summarized as
follows:

* I've switched from using the [`hobby`](http://ftp.uni-erlangen.de/mirrors/CTAN/graphics/pgf/contrib/hobby/hobby_doc.pdf)
  package (which does all its calculations inside of TeX and is quite slow) to using [gm](https://github.com/aheckmann/gm),
  which is GraphicsMagick for NodeJS. It's much faster, and since images are stored in the filesystem, you
  get


You'll immediately notice some flaws here:

* <del>most obviously, the lines in the low tide column strike through the times given; this is a result of the
  trick i used to shift those times to their offset positions.</del>

* I actually want those lines to separate dates by enclosing them in boxes, so people don't have to guess
  which times belongs to which date; <del>however, with the current table setting strategy his will almost
  be impossible to do. As a next step, i want to typeset in twice the number of rows and use `multirow`s
  so that the *visual* rows can be offset by a half row's height (still with me?).</del>

* <del>There are lines missing in the low tide column; this is due to a flaw in the data reader.</del>

* <del>There is no column and page breaking implemented as yet, so the table will just run off the page.</del>

* I plan to include curves to visualize tidal levels; i already have this output (which is planned to appear
  to the right of the times columns):

  The left line symbolizes the heights of the high water, the right one the heights of the low water
  point. I hope i got the figures right. Maybe i add another line in the middle that shows the actual water
  level at all times.

  Incidentally, you can see how tides do not only change the water levels as such, but also cause
  a similar change in the minima and maxima of the level—in other words, its a wave within a wave within
  wave, from maybe centennial trends down to tides proper and then on to waves big and small and again on to tiny
  ripples on the water's surface. That's truly turtles all the way down, and very amazing. It may also be
  interesting and helpful for people using the calender.

  <del>While this output does not look so grand when seen in isolation, i want to add a grid for height
  orientation with references to Normaal Amsterdams Peil (NAP, Amsterdam Ordnance Datum) and Lowest
  Astronomical Tide (LAT) as well as horizontal lines to link to the respective time.</del>

  <del>Currently i use the [`hobby`](http://ftp.uni-erlangen.de/mirrors/CTAN/graphics/pgf/contrib/hobby/hobby_doc.pdf)
  package to draw the curves; it is reasonably simple to use, but takes a considerable time to get each
  curve drawn, so maybe i'll look for a way to do this outside of TeX.</del>

### Observations

There are always 54, 58, or 62 HL-times between a day with a new or full moon and the following day with
a full or new moon.


### License (Must Read)

The use of this software and any included files is free for anyone. Please consider attribution if you
want to base your own stuff on this project. Thanks.

### Disclaimer (Must Read)

Users of this software must have read, understood, and agreed to the below three disclaimers in order for
the License of this product to become valid.

#### Disclaimer for CoffeeNode Tides

Please note that **this Tidal Calender can not, does not, and will not display *actual* water levels**; all it does
is to *attempt* and deliver tidal predictions that enthusiasts may find interesting. **Any data given here
is without any claim explicit or implicit of fitness for any particular purpose**; it is **definitely not
suitable for navigation**, simply because **all actual water levels *will* differ considerably from the figures
given here with near-certainty** (that's the fine difference between astronomical tides projected into the
future and actual tides as known from direct observation or past measurements. Also **there may be faults in
the data and / or data processing**).

#### Disclaimer from Rijkswaterstaat

> In case you don't believe me, you will perhaps believe Rijkswaterstaat, the world's leading agency on
> coastal protection. These guys have managed to keep the Netherlands dry for several hundred years, so they
> probably know what they're talking about when it comes to estimating the value of tidal predictions:

**Gebruik van de informatie op deze data is voor eigen risico**. De getoonde gegevens zijn gebaseerd op de best
beschikbare kennis en informatie van Rijkswaterstaat. Desondanks kunnen de werkelijke gegevens door
verschillende oorzaken afwijken van de hier getoonde actuele gegevens. Een afwijking kan bijvoorbeeld zitten
in de getoonde verwachtingen.

> from http://www.rijkswaterstaat.nl/geotool/astronomisch_getij.aspx?cookieload=true

#### Disclaimer from XTide

> **Note** while currently no use of `xtide` has been made to produce the current software, this may change
> in the future. *The disclaimer still applies to CoffeeNode Tides*.

> If Rijkswaterstaat is not nerdy enough for you, XTide certainly is. Again, from someone who knows what
> they're talking about:


**NOT FOR NAVIGATION**

This program is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE**.  The author assumes no liability
for damages arising from use of this program OR of any 'harmonics data' that might be distributed with it.
For details, see the appended GNU General Public License.

(Accurate tide predictions can only be made if the 'harmonics data' for the relevant location are good.
Unfortunately, the only way the maintainer of those data has of knowing when they are bad is when someone
with access to authoritative tide predictions or observations reports a problem.  You should not use this
program or any data files that might be distributed with it if anyone or anything could come to harm as a
result of an incorrect tide prediction.

XTide's predictions **do not incorporate the effects of tropical storms, El Niño, seismic events, subsidence,
uplift, or changes in global sea level.**

> from http://www.flaterco.com/xtide/disclaimer.html



<!--

http://live.getij.nl/export.cfm?format=txt&from=01-01-2014&to=31-12-2014&uitvoer=2&interval=10&lunarphase=yes&location=EEMHVN&Timezone=MET_DST&refPlane=LAT&graphRefPlane=LAT&bottom=0&keel=0


locations =
  'AUKFPFM':        'Aukfield platform'
  'BAALHK':         'Baalhoek'
  'BATH':           'Bath'
  'BEERKNL':        'Beerkanaal'
  'BERGSDSWT':      'Bergse Diepsluis west'
  'BORSSLE':        'Borssele'
  'BRESKS':         'Breskens'
  'BROUWHVSGT02':   'Brouwershavensche Gat 02'
  'BROUWHVSGT08':   'Brouwershavensche Gat 08'
  'CADZD':          'Cadzand'
  'DELFZL':         'Delfzijl'
  'DENHDR':         'Den Helder'
  'DENOVBTN':       'Den Oever'
  'DINTHVN':        'Dintelhaven'
  'DORDT':          'Dordrecht'
  'EEMHVN':         'Eemhaven'
  'EEMSHVN':        'Eemshaven'
  'EURPFM':         'Euro platform'
  'EURPHVN':        'Europahaven'
  'GEULHVN':        'Geulhaven'
  'GOIDSOD':        'Goidschalxoord'
  'GOUDBG':         'Gouda brug'
  'HAGSBNDN':       'Hagestein beneden'
  'HANSWT':         'Hansweert'
  'HARLGN':         'Harlingen'
  'HARMSBG':        'Harmsenbrug'
  'HARTBG':         'Hartelbrug'
  'HARTHVN':        'Hartelhaven'
  'HARTKWT':        'Hartel-Kuwait'
  'HARVT10':        'Haringvliet 10'
  'HEESBN':         'Heesbeen'
  'HELLVSS':        'Hellevoetsluis'
  'HOEKVHLD':       'Hoek van Holland'
  'HUIBGT':         'Huibertgat'
  'IJMDBTHVN':      'IJmuiden'
  'K13APFM':        'K13A platform'
  'KATSBTN':        'Kats'
  'KEIZVR':         'Keizersveer'
  'KORNWDZBTN':     'Kornwerderzand'
  'KRAMMSZWT':      'Krammersluizen west'
  'KRIMPADIJSL':    'Krimpen aan de IJssel'
  'KRIMPADLK':      'Krimpen aan de Lek'
  'LAUWOG':         'Lauwersoog'
  'LICHTELGRE':     'Lichteiland Goeree'
  'LITHDP':         'Lith dorp'
  'MAASSS':         'Maassluis'
  'MARLGT':         'Marollegat'
  'MOERDK':         'Moerdijk'
  'NES':            'Nes'
  'NIEUWSTZL':      'Nieuwe Statenzijl'
  'NOORDWMPT':      'Meetpost Noordwijk'
  'OOSTSDE04':      'Oosterschelde 04'
  'OOSTSDE11':      'Oosterschelde 11'
  'OOSTSDE14':      'Oosterschelde 14'
  'OUDSD':          'Oudeschild'
  'OVLVHWT':        'Overloop van Hansweert'
  'PARKSS':         'Parksluis'
  'PETTZD':         'Petten zuid'
  'RAKND':          'Rak noord'
  'ROOMPBNN':       'Roompot binnen'
  'ROOMPBTN':       'Roompot buiten'
  'ROTTDM':         'Rotterdam'
  'ROZBSSNZDE':     'Rozenburgsesluis noordzijde'
  'SCHAARVDND':     'Schaar van de Noord'
  'SCHEURHVN':      'Scheurhaven'
  'SCHEVNGN':       'Scheveningen'
  'SCHIERMNOG':     'Schiermonnikoog'
  'SCHOONHVN':      'Schoonhoven'
  'SPIJKNSE':       'Spijkenisse'
  'STAVNSE':        'Stavenisse'
  'STELLDBTN':      'Haringvlietsluizen'
  'SUURHBNZDE':     'Suurhoffbrug noordzijde'
  'TERNZN':         'Terneuzen'
  'TERSLNZE':       'Terschelling Noordzee'
  'TEXNZE':         'Texel Noordzee'
  'VLAARDGN':       'Vlaardingen'
  'VLAKTVDRN':      'Vlakte van de Raan'
  'VLIELHVN':       'Vlieland haven'
  'VLISSGN':        'Vlissingen'
  'VURN':           'Vuren'
  'WALSODN':        'Walsoorden'
  'WERKDBTN':       'Werkendam buiten'
  'WESTKPLE':       'Westkapelle'
  'WESTTSLG':       'West-Terschelling'
  'WIERMGDN':       'Wierumergronden'
  'YERSKE':         'Yerseke'


 -->

