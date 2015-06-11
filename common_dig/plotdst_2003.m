function plotdst_2003(target_month, target_day, bSavePlots, jpeg_output_dir, dst_filename)
% plotdst_2003(target_month, target_day, bSavePlots, jpeg_output_dir, dst_filename)
% Function to plot DST from 2003
% By Daniel Golden (dgolden1 at stanford dot edu) Oct 22, 2007

% $Id$

%% Setup
error(nargchk(2, 5, nargin));

if ~exist('bSavePlots', 'var') || isempty(bSavePlots)
	bSavePlots = false;
end
if ~exist('jpeg_output_dir', 'var')
	jpeg_output_dir = [];
end
if ~exist('dst_filename', 'var') || isempty(dst_filename)
	dst_filename = '/home/dgolden/vlf/case_studies/chorus_2003/dst/dst_2003.txt';
end

target_datenum = datenum(2003, target_month, target_day, 0, 0, 0);

%% Read DST and parse out Date
[year, month, day, dst] = dst_read(dst_filename);

thisday_i = find((year == 2003) & (month == target_month) & (day == target_day));
[next_year, next_month, next_day] = date_fwd(2003, target_month, target_day, 1);
nextday_i = find((year == next_year) & (month == next_month) & (day == next_day));

dst_thisday = [dst(thisday_i, :) dst(nextday_i, 1)]; % Include midnight of the next day

%% Plot it
starttime = target_datenum;
time_thisday = linspace(starttime, starttime + 1, 25);
h_thisday = figure;
plot(time_thisday, dst_thisday, 'r', 'LineWidth', 2);
datetick('x', 'keeplimits');
grid on;
xlabel('Hour');
ylabel('Dst (nT)');
title(sprintf('DST Index %s', datestr(target_datenum, 'mmmm dd, yyyy')));
increase_font(gca);

%% Also get DST for previous and following three days
sevenday_i = [];
for kk = -3:3
	[next_year, next_month, next_day] = date_fwd(2003, target_month, target_day, kk);
	sevenday_i = [sevenday_i find((year == next_year) & (month == next_month) & (day == next_day))];
end
dst_sevenday = dst(sevenday_i, :);
dst_sevenday_flat = reshape(dst_sevenday.', 1, []); % Reshape normally goes down columns; we want to go across rows
[start_year, start_month, start_day] = date_fwd(2003, target_month, target_day, -3);
starttime = datenum(start_year, start_month, start_day, 0, 0, 0);
time_sevenday = linspace(starttime, starttime + 7 - 1/24, 24*7);

% jan_17_ri = find((year == 2003) & (month == 1) & (day >= 14) & (day <= 20));
% dst_thisday_r = dst(jan_17_ri, :);
% dst_thisday_r_flat = reshape(dst_thisday_r', 1, []); % Reshape normally goes down columns; we want to go across rows
% starttime = datenum(2003, 01, 14, 0, 0, 0);
% time_x7 = linspace(starttime, starttime + 7 - 1/24, 24*7);
h_sevenday = figure;
plot(time_sevenday, dst_sevenday_flat, 'LineWidth', 2)
datetick('x', 'keeplimits');
grid on;
xlabel('Day');
title(sprintf('DST Index surrounding %s', datestr(target_datenum, 'mmmm dd, yyyy')));

% Overlay the day of interest in red
hold on;
plot(time_thisday, dst_thisday, 'r', 'LineWidth', 2);
ylabel('Dst (nT)');

increase_font(gca);

%% And DST for the month
month_i = find((year == 2003) & (month == target_month));
dst_month = dst(month_i, :);
dst_month_flat = reshape(dst_month', 1, []);
starttime = datenum(2003, target_month, 1, 0, 0, 0);
endtime = datenum(2003, target_month+1, 1, 23, 0, 0)-1;
time_month = starttime:(1/24):endtime;

h_month = figure;
plot(time_month, dst_month_flat, 'LineWidth', 2);
h = gca;
set(h, 'XTick', [starttime:2:ceil(endtime)])
datetick('x', 7, 'keepticks');
grid on;
xlabel('Day');
ylabel('Dst (nT)');
title(sprintf('DST Index for %s', datestr(target_datenum, 'mmmm, yyyy')));

% Overlay target date in red
hold on;
plot(time_thisday, dst_thisday, 'r', 'LineWidth', 2);
ylabel('Dst (nT)');

increase_font(gca);


%% Save plots
if bSavePlots
	if isempty(jpeg_output_dir)
		jpeg_output_dir = uigetdir(pwd, 'Select directory to save files');
	end
	if ~ischar(jpeg_output_dir), return; end

	% Write single day plot
	figure(h_thisday);
	filename = fullfile(jpeg_output_dir, sprintf('dst_%s.jpg', datestr(target_datenum, 'yyyy_mm_dd')));
	print('-djpeg', filename);
	disp(sprintf('Wrote %s', filename));
	
	% Write seven day plot
	figure(h_sevenday);
	filename = fullfile(jpeg_output_dir, sprintf('dst_%s-%s.jpg', datestr(target_datenum-3, 'yyyy_mm_dd'), ...
		datestr(target_datenum+3, 'yyyy_mm_dd')));
	print('-djpeg', filename);
	disp(sprintf('Wrote %s', filename));

	% Write month plot
	figure(h_month);
	filename = fullfile(jpeg_output_dir, sprintf('dst_%s.jpg', datestr(target_datenum, 'yyyy_mm')));
	print('-djpeg', filename);
	disp(sprintf('Wrote %s', filename));
end


%% Function: date_fwd
function [next_year, next_month, next_day] = date_fwd(year, month, day, days_to_add)
% Function to find days before or after a given day, in Matlab serial date
% format

date = datenum(year, month, day);
next_date = date + days_to_add;
[next_year, next_month, next_day] = datevec(next_date);
