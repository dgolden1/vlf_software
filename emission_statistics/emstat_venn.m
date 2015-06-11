function emstat_venn
% Make a venn diagram to show emissions occurring in their emission
% interval and on what days multiple emissions occur

% By Daniel Golden (dgolden1 at stanford dot edu) September 2008
% $Id$

%% Load & parse emissions
load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');

[chorus_events, hiss_events, chorus_and_hiss_events] = event_parser(events);

dawn_int_start = datenum([0 0 0 03 0 0]);
dawn_int_end = datenum([0 0 0 09 0 0]);
dusk_int_start = datenum([0 0 0 14 0 0]);
dusk_int_end = datenum([0 0 0 23 0 0]);

days = datenum([2003 01 01 0 0 0]):datenum([2003 10 31 0 0 0]);

chorus_days = find_event_days(chorus_events, days, dawn_int_start, dawn_int_end);
hiss_days = find_event_days(hiss_events, days, dusk_int_start, dusk_int_end);
chorus_and_hiss_days = find_event_days(chorus_and_hiss_events, days, dawn_int_start, dawn_int_end);

% load emission_days_venn.mat;

% hiss_days = [false hiss_days(1:end-1)];

%% Make the venn diagram
vec = [sum(chorus_days & ~hiss_days & ~chorus_and_hiss_days), ...
      sum(chorus_days & hiss_days & ~chorus_and_hiss_days), ...
      sum(~chorus_days & hiss_days & ~chorus_and_hiss_days), ...
      sum(~chorus_days & hiss_days & chorus_and_hiss_days), ...
      sum(~chorus_days & ~hiss_days & chorus_and_hiss_days), ...
      sum(chorus_days & ~hiss_days & chorus_and_hiss_days), ...
      sum(chorus_days & hiss_days & chorus_and_hiss_days)];
  
% disp(sprintf('chorus only: %d\nchorus and hiss: %d\nhiss only: %d\nhiss and chorushiss: %d\nchorushiss: %d\nchorushiss and chorus: %d\neverything: %d', ...
% 	vec));

[error, handles] = vennX(vec, 0.1);

%% Rename the circles
set(handles(1), 'String', sprintf('C (%d)', vec(1)));
set(handles(2), 'String', sprintf('C,H (%d)', vec(2)));
set(handles(3), 'String', sprintf('H (%d)', vec(3)));
set(handles(4), 'String', sprintf('H,CH (%d)', vec(4)));
set(handles(5), 'String', sprintf('CH (%d)', vec(5)));
set(handles(6), 'String', sprintf('C,CH (%d)', vec(6)));
set(handles(7), 'String', sprintf('C,H,CH (%d)', vec(7)));

set(handles, 'horizontalalignment', 'center');

title('Overlap of event types occurring on the same day');
