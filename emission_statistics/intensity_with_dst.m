function intensity_with_dst(start_datenum, end_datenum)
% Function to overlay emission event intensity on DST plot for 2003

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

%% Setup
error(nargchk(2, 2, nargin));

dst_filename = '/home/dgolden/vlf/case_studies/chorus_2003/dst/dst_2003.txt';

% Load events
load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');


%% Read DST and parse out given date's values
error('I flattended the output of dst_read_datenum and broke this section Dec 13 2007 -Dan');
[dst_date, dst] = dst_read_datenum(dst_filename);
dst_i = find(dst_date >= start_datenum & dst_date <= end_datenum);


this_date = interp1(1:length(dst_date(dst_i)), dst_date(dst_i), 1:1/24:length(dst_date(dst_i)));
this_dst_flat = reshape(dst(dst_i,:).', 1, []);
this_dst_flat = this_dst_flat(1:end-23); % Cut the full day's values from the end_date


%% Plot DST for this month
figure;
subplot(2, 1, 1);
plot(this_date, this_dst_flat, 'r', 'LineWidth', 2);
% plot(this_date, this_dst_flat, 'r', 'LineWidth', 1);
h = gca;
grid on;
xticks = linspace(start_datenum, end_datenum, 10);
set(h, 'XTick', xticks);
datetick('x', 'keeplimits');
xlabel('Day');
ylabel('Dst (nT)');
title(sprintf('DST index from %s to %s', datestr(start_datenum, 0), datestr(end_datenum, 0)));
xl = xlim;


%% Parse out events for given dates
subplot(2, 1, 2);
events_i = find([events.start_datenum] >= start_datenum & [events.end_datenum] <= end_datenum);
these_events = events(events_i);

scatter([these_events.start_datenum], [these_events.intensity], '.');
h = gca;
grid on;
xticks = linspace(start_datenum, end_datenum, 10);
set(h, 'XTick', xticks);
datetick('x', 'keeplimits');
xlabel('Day');
ylabel('Event intensity');
title(sprintf('VLF emission events'));
xlim(xl);

%% Plot events for this month
subplot(2, 1, 1);
