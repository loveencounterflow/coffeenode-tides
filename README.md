

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

* I plan to include curves to visualize tidal levels; i already have this output:

  <img src='https://github.com/loveencounterflow/coffeenode-tides/raw/master/art/Screen%20Shot%202014-03-20%20at%2021.40.43.png' width=100px>

  The left line symbolizes the height of the high water, the right one symbolizes the height of the low water
  point. I hope i got the figures right. Maybe i add another line in the middle that shows the actual water
  level at all times. You can see how tides do not only change the water levels as such, but also cause
  a similar change in the minima and maxima of the level—in other words, its a wave within a wave within
  wave, from maybe centennial trends down to tides proper and then on to waves big and small down to tiny
  ripples on the water's surface. That's truly turtles all the way down, and very amazing.

  While this output does not look so grand when seen in isolation, i want to add a grid for height
  orientation with references to Normaal Amsterdams Peil (NAP, Amsterdam Ordnance Datum) and Lowest
  Astronomical Tide (LAT) as well as horizontal lines to link to the respective time.

  Currently i use the [`hobby`](http://ftp.uni-erlangen.de/mirrors/CTAN/graphics/pgf/contrib/hobby/hobby_doc.pdf)
  package to draw the curves; it is reasonably simple to use, but it takes a considerable time to get each
  curve drawn, so maybe i'll look for a way to do this outside of TeX.
