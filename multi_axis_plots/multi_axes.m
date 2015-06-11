% Script to toy with multiple x-axes
% By Daniel Golden (dgolden1 at stanford dot edu) Oct 25, 2007

%% Setup
close all;
clear;

%% Read DST and parse out Jan 17
[date, dst] = dst_read_datenum('dst_2003.txt');
[year, month, day, hour, min, sec] = datevec(date);

jan_17_i = find((year == 2003) & (month == 1) & (day == 17));
jan_18_i = find((year == 2003) & (month == 1) & (day == 18));

dst_jan_17 = [dst(jan_17_i, :); dst(jan_18_i, 1)]; % Include midnight, Jan 18

%% Plot it
starttime = datenum(2003, 01, 17, 0, 0, 0);
time_17 = linspace(starttime, starttime + 1, length(dst_jan_17));
figure;
mainplot = plot(time_17, dst_jan_17, 'r', 'LineWidth', 2);
mainax = gca;
% datetick('x');
grid on;
% xlabel('Hour');
ylabel('Dst (nT)');
title('DST Index January 17, 2003');
increase_font(gca);

% Destroy the original x ticks
xticklabels = get(mainax, 'XTickLabel');
for kk = 1:size(xticklabels,1), xticklabels(kk,:) = repmat(' ', 1, length(xticklabels(kk,:))); end;
set(mainax, 'XTickLabel', xticklabels);

% Move the original axis up a little to make room for the new x axes
ax_orig = gca;
pos_orig = get(ax_orig, 'Position');
set(ax_orig, 'Position', [pos_orig(1), pos_orig(2)+0.1, pos_orig(3), pos_orig(4)-0.1]);
pos_orig = get(ax_orig, 'Position');


% Get information for placing the ticks
nhours = ceil((time_17(end) - time_17(1))*24);
tickstep = ceil(nhours/8)/24;
ticks = floor(time_17(1)*24)/24:tickstep:ceil(time_17(end)*24)/24;
xlim_max = [ticks(1) ticks(end)];

% Adjust the original axis tick marks and limits
set(ax_orig, 'XTick', ticks, 'Xlim', xlim_max);

%% Put the original x axis on a new subplot (UTC)
ax_utc = subplot('Position',[pos_orig(1) pos_orig(2)-0.05 pos_orig(3) 1e-4]);
h = plot(time_17, zeros(size(time_17)), 'LineStyle', 'none');
% set(gca, 'Box', 'off')

% Adjust the tick marks and limits
set(ax_utc, 'XTick', ticks, 'Xlim', xlim_max);

datetick('x', 'keepticks');
set(get(ax_utc, 'YLabel'), 'String', 'UTC');

%% Extra axes (Palmer)
offset = -4/24; % Palmer offset from UTC
ax_lt = subplot('Position',[pos_orig(1) pos_orig(2)-0.12 pos_orig(3) 1e-4]);
h = plot(time_17 + offset, zeros(size(time_17)), 'LineStyle', 'none');

% Adjust the tick marks and limits
set(ax_lt, 'XTick', ticks + offset, 'Xlim', xlim_max + offset);

datetick('x', 'keepticks');
set(get(ax_lt, 'YLabel'), 'String', sprintf('Palmer\nLT'));
