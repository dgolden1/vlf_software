function plot_palmer_pp_db(start_datenum, end_datenum, db_filename, ax, bShowLegend)
% plot_palmer_pp_db(start_datenum, end_datenum, db_filename, ax, bShowLegend)
% Function to plot the plasmapause location from the palmer plasmapause
% database

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id$

%% Setup
% PALMER_LONGITUDE = -64.05; % Degrees
PALMER_MLT = -4; % Palmer MLT offset from UT, in hours

if ~exist('start_datenum', 'var') || isempty(start_datenum)
	start_datenum = 0; % This gets changed in the next cell
end
if ~exist('end_datenum', 'var') || isempty(end_datenum)
	end_datenum = inf; % This gets changed in the next cell
end

if ~exist('db_filename', 'var') || isempty(db_filename)
	db_filename = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_pp_db.mat';
end
if ~exist('ax', 'var')
	ax = [];
end
if ~exist('bShowLegend', 'var') || isempty(bShowLegend)
	bShowLegend = false;
end

load(db_filename, 'palmer_pp_db');

L_MIN = 1;
L_MAX = 6;

%% Parse out requested dates
if start_datenum <= 0
	start_datenum = min([palmer_pp_db.img_datenum]);
end
if end_datenum > 0 && isinf(end_datenum)
	end_datenum = max([palmer_pp_db.img_datenum]);
end
palmer_pp_db = palmer_pp_db([palmer_pp_db.img_datenum] >= start_datenum & [palmer_pp_db.img_datenum] <= end_datenum);

if isempty(palmer_pp_db)
	error('No plasmapause entries between %s and %s', datestr(start_datenum), datestr(end_datenum));
end

%% Sort
[img_datenum, i] = sort([palmer_pp_db.img_datenum]);
pp_L = [palmer_pp_db(i).pp_L];

%% Set up plot
if ~isempty(ax)
	axes(ax);
else
	figure;
end
hold on;

%% Plot day and night lines
if end_datenum - start_datenum < 4
	dawn_times = (floor(start_datenum):ceil(end_datenum)) + 0.25 - PALMER_MLT/24;
	dawn_times = dawn_times(dawn_times > start_datenum & dawn_times < end_datenum);
	dusk_times = (floor(start_datenum):ceil(end_datenum)) + 0.75 - PALMER_MLT/24;
	dusk_times = dusk_times(dusk_times > start_datenum & dusk_times < end_datenum);
	
	yellow = [0.9 0.9 0.3];
	blue = [0.5 0.5 0.8];
	for kk = 1:length(dawn_times)
		h_dawn = plot(dawn_times(kk)*[1 1], [L_MIN L_MAX], 'Color', yellow, 'LineWidth', 2);
% 		annotation('arrow', [dawn_times(kk) dawn_times(kk)+0.05], ((L_MAX-L_MIN)/2 + L_MIN)*[1 1], 'Color', yellow, 'LineWidth', 2);
	end
	for kk = 1:length(dusk_times)
		h_dusk = plot(dusk_times(kk)*[1 1], [L_MIN L_MAX], 'Color', blue, 'LineWidth', 2);
	end
end

%% Plot valid points
% Add Palmer's L-shell line
green = [0.3 0.7 0.3];
h_palmer_line = plot([floor(img_datenum(1)) ceil(img_datenum(end))], 2.44*[1 1], '--', ...
	'Color', green, 'LineWidth', 2);

% Plot plasmapause points
h_pp = scatter(img_datenum, pp_L, 'bo', 'Filled');
grid on;
set(gca, 'Box', 'on');
xlim([start_datenum end_datenum]);
% yl = ylim;
% ylim([1 yl(2)]);
ylim([L_MIN L_MAX]);
xlabel('Time (UTC)');
ylabel('L');
title(sprintf('Plasmapause at Palmer''s Lon. (%s to %s)', datestr(start_datenum, 'yyyy-mm-dd'), datestr(end_datenum, 'yyyy-mm-dd')));

%% Plot invalid points
h_invalid = scatter(img_datenum(isnan(pp_L)), ones(1, sum(isnan(pp_L))), 'rx');
h_unclear = scatter(img_datenum(isinf(pp_L)), L_MAX*ones(1, sum(isinf(pp_L))), 'o', 'CData', [0 0.9 0]);

% legend('Palmer', 'Plamapause', 'Location', 'SouthWest');

%% Mess with axis and figure size
figure_squish(gcf, 0.6, 1);
datetick2('x', 'keeplimits');
zoom xon;

%% Legend
if bShowLegend
	legend([h_pp, h_unclear, h_invalid, h_dawn, h_dusk, h_palmer_line], 'Plamapause', 'Plasmapause Unclear', ...
		'Invalid Image', 'Dawn', 'Dusk', 'Palmer L-Shell');
end


if isempty(ax), increase_font(gca); end
