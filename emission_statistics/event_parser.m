function [chorus_events, hiss_events, other_events] = event_parser(events)
% [chorus_events, hiss_events, other_events] = event_parser(events)
% Parse particular types of emissions
% 
% chorus_events: events in between the chorus burstiness bounds in
% chorus_hiss_globals
% hiss_events: events in between the hiss burstiness bounds in
% chorus_hiss_globals
% other_events: all other events, including events with burstiness that is
% too high, too low, or too middling

% By Daniel Golden (dgolden1 at stanford dot edu) February 2010
% $Id$

[CHORUS_B_MIN CHORUS_B_MAX HISS_B_MIN HISS_B_MAX] = chorus_hiss_globals;

burstiness = [events.burstiness];
chorus_i = burstiness >= CHORUS_B_MIN & burstiness < CHORUS_B_MAX;
hiss_i = burstiness >= HISS_B_MIN & burstiness < HISS_B_MAX;

chorus_events = events(chorus_i);
hiss_events = events(hiss_i);
other_events = events(~chorus_i & ~hiss_i);
