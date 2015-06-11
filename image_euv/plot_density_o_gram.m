function plot_density_o_gram(start_datenum, end_datenum)
% plot_density_o_gram(start_datenum, end_datenum)
% Plot a "density-o-gram" display of the plasma density at Palmer's L-shell
% 
% To make this plot, you must first:
% 1. Process the FITS files using the palmer_pp_image_gui()
% 2. Create the 1-D db files using make_palmer_pp_1d_db_files()
% 3. Create the 1-D file database using collect_palmer_pp_1d_db_files()

% By Daniel Golden (dgolden1 at stanford.edu) November 2009
% $Id$

%% Setup
if exist('start_datenum', 'var') && ~exist('end_datenum', 'var')
	end_datenum = start_datenum + 1;
else
	if ~exist('start_datenum', 'var') || isempty(start_datenum)
		start_datenum = 0;
	end
	if ~exist('end_datenum', 'var') || isempty(end_datenum)
		end_datenum = Inf;
	end
end

density_db_filename = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_plasmapause_db/palmer_plasmapause_db.mat';
pp_db_filename = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_pp_db.mat';

%% Load and parse out times
df = load(density_db_filename);
if start_datenum == 0, start_datenum = min(df.img_datenum); end
if isinf(end_datenum), end_datenum = max(df.img_datenum); end
idx = df.img_datenum >= start_datenum & df.img_datenum < end_datenum;

if sum(idx) == 0
	error('No valid values in %s from %s to %s', density_db_filename, datestr(start_datenum), datestr(end_datenum));
end

img_datenum_orig = df.img_datenum(idx);
L = df.L;
dens_orig = df.dens(:, idx);

%% Fill in gaps
% % Anywhere img_datenum jumps by more than 15 minutes is a gap
% datenum_diff = diff(img_datenum_orig);
% gap_i = find(datenum_diff > 15/1440);
% gap_size = datenum_diff(gap_i);
% 
% % Average distance between images
% avg_dt = mean(datenum_diff(datenum_diff < 15/1440));
% 
% img_datenum = img_datenum_orig(1:gap_i(1));
% for kk = 1:length(gap_i)
% 	
% 	img_datenum = [img_datenum linspace(img_datenum_orig(gap_i(kk)), img_datenum_orig(gap_i(kk) + 1), ];
% end

%% Fill gaps in time with nans
% Anywhere img_datenum jumps by more than 15 minutes is a gap
gap_i = find(diff(img_datenum_orig) > 15/1440);
gap_i = [0; gap_i; length(img_datenum_orig)];

% Build up the new date vector
img_datenum = zeros(length(img_datenum_orig) + length(gap_i)-2, 1);
dens = nan(length(L), length(img_datenum_orig) + length(gap_i)-2);
for kk = 2:length(gap_i)
	idx_new = [kk - 1 + gap_i(kk-1), kk - 2 + gap_i(kk)];
	idx_orig = [gap_i(kk-1) + 1, gap_i(kk)];
% 	disp(sprintf('img_datenum [%d %d] <-- img_datenum_orig [%d %d]', idx_new, idx_orig));

	img_datenum(idx_new(1):idx_new(2)) = img_datenum_orig(idx_orig(1):idx_orig(2));
	
	if kk ~= length(gap_i)
		% The gap gets a value 10 minutes after the last minute
		img_datenum(idx_new(2) + 1) = img_datenum(idx_new(2)) + 10/1440;
	end
	
	dens(:, idx_new(1):idx_new(2)) = dens_orig(:, idx_orig(1):idx_orig(2));
end

%% Plot
x_start_date = datenum([2001 01 01 0 0 0]);
figure;

% Pcolor has a crazy bug where it won't plot properly if I use the proper
% datenums. Lame!
h = pcolor(img_datenum - x_start_date, L, log10(dens));
set(h, 'linestyle', 'none');
% imagesc(img_datenum, L, log10(dens));
% axis xy;
% datetick2('x', 'keeplimits');
xlabel(sprintf('Days after %s', datestr(x_start_date, 31)));
ylabel('L');
title(sprintf('Plasma density at Palmer''s longitude %s to %s', datestr(start_datenum, 31), datestr(end_datenum, 31)));

colormap(green);
c = colorbar;
ylabel(c, 'log He^+ Column Density (cm^{-2})');
caxis([10.2 12.7]);

zoom xon;

%% Mark plasmapause
load(pp_db_filename, 'palmer_pp_db');
idx = [palmer_pp_db.img_datenum] >= start_datenum & [palmer_pp_db.img_datenum] < end_datenum;
pp_datenum = [palmer_pp_db(idx).img_datenum];
pp_L = [palmer_pp_db(idx).pp_L];
pp_L2 = [palmer_pp_db(idx).pp_L2];

pp1_color = [0.9 0.3 0.7]; % Pink/purple
pp2_color = [1 0.6 0]; % Orange

hold on;
p2 = plot(pp_datenum - x_start_date, pp_L2, 'o', 'color', pp2_color, 'MarkerFaceColor', pp2_color);
p1 = plot(pp_datenum - x_start_date, pp_L, 'o', 'color', pp1_color, 'MarkerFaceColor', pp1_color);

increase_font;
figure_squish(gcf, 0.6, 1);

disp('');
