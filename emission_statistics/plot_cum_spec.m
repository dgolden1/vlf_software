function h = plot_cum_spec(events, em_type)
% h = plot_cum_spec(events, em_type)
% Plot a "cumulative spectrogram" view of events
% Events are represented as overlapping semi-translucent boxes

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$

%% Do the plotting
global T_LOW T_HIGH

T_LOW = 5/60/24;
T_HIGH = (23 + 59/60)/24;
% T_LOW = 0;
% T_HIGH = 1;

figure(gcf);

% xlim([T_LOW T_HIGH]);
xlim([0 1]);
ylim([0.3 10]);
hold on;
% xlabel(sprintf('Palmer LT (UTC + %0.1f)', PALMER_T_OFFSET*24));
xlabel(sprintf('Palmer LT'));
ylabel('Frequency (kHz)');

for kk = 1:length(events)
	plot_single_event(events(kk));
end

%% Play with axes
grid on;
title(sprintf('VLF emission events (%s) 2003',  strrep(em_type, '_', '\_')));

% xticks = 0:2/24:1;
% set(gca, 'XTick', xticks);
datetick('x', 'HH:MM', 'keeplimits');


%% Function: plot_single_event
function plot_single_event(event)

global T_LOW T_HIGH

start_time = [event.start_datenum] - floor([event.start_datenum]);
end_time = [event.end_datenum] - floor([event.end_datenum]);

% start_time = [event.start_datenum] - floor([event.start_datenum]);
% end_time = [event.end_datenum] - floor([event.end_datenum]);
f_lc = event.f_lc;
f_uc = event.f_uc;

y = [f_lc f_lc f_uc f_uc];
color = 'r';
if end_time < start_time % If this event wraps past midnight, split it into two
	x = [start_time T_HIGH T_HIGH start_time];
	p = patch(x, y, color, 'FaceAlpha', 0.03, 'EdgeColor', 'none');
	x = [T_LOW end_time end_time T_LOW];
	p = patch(x, y, color, 'FaceAlpha', 0.03, 'EdgeColor', 'none');
else
	x = [start_time end_time end_time start_time];
	p = patch(x, y, color, 'FaceAlpha', 0.03, 'EdgeColor', 'none');
end
