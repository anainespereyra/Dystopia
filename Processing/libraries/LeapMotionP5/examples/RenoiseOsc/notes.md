# Notes on controlling Renoise via Leap #

To keep it simple, we have two modes:

- Jump to and loop on pattern N
- Mute/unmute track or pattern.

Some interesting things:

It seems (but test this) that you can mute a group by muting the pattern block to the right of the group.

Need to see it this works when using OSC.

Also, is there an option to mute a pattern on the current row?

    /renoise/song/sequence/slot_mute(track_num, row_number) 

Both are 1-based.  There is an unmute version as well.

Thing is, how would you know the current sequence slot? 

We would need to store what pattern number is sent for looping commands and assume that, once the transition is made, that number is the current row


## A simple plan ##

Two modes. Different screens for each.

Screen for jumping to a row shows something to indicate the row; some gesture or finger count makes the change.

A Circle gesture swaps modes.

The mute/unmute screen shows a series of tracks; a gesture or something in a column changes the muting.

### The pattern-jump screen ###

Assume we have 4 rows. Is it better to show them as bars or columns? What is less error-prone?

Or quadrants?  Interesting if we think of them as not sequential. 

Assume rows, as that maps to the screen, and seems simpler.

(If there were more than 4 rows maybe  away to scroll would be nice)




