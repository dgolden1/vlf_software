function varargout = plot_palmer_pp_db(plot_type, start_datenum, end_datenum, varargin)
% plot_palmer_pp_db(plot_type, start_datenum, end_datenum, varargin)
% Plot the palmer plasmapause db in different ways
% 
% plot_type can be one of:
%  date_l_scatter (default) -- scatter plot of L vs. date, color coded by MLT
%  mlt_l_biv_hist -- bivariate histogram of number of images, binned by L and
%  MLT
%  mlt_l_scatter -- scatter plot of L vs. MLT
%  ae_cross_scatter -- scatter plot of L vs. "avg AE in last n hours",
%   where n is chosen optimally based on a previous study
%   varargin can be ae_type, n_hours_history, mlt_sector, b_display_only

% By Daniel Golden (dgolden1 at stanford dot edu) November 2009
% $Id$

% PALMER_LONGITUDE = -64.05; % Degrees

%% Set constants
global PALMER_MLT L_MIN L_MAX
PALMER_MLT = -(4+1/60)/24;
L_MIN = 1;
L_MAX = 7;

%% Setup
year = 2001;

if ~exist('plot_type', 'var') || isempty(plot_type)
	plot_type = 'date_l_scatter';
end
if ~exist('start_datenum', 'var') || isempty(start_datenum)
	start_datenum = datenum([year 01 01 0 0 0]);
end
if ~exist('end_datenum', 'var') || isempty(end_datenum)
	end_datenum = datenum([year + 1, 01, 01, 0, 0, 0]); 
end

db_filename = sprintf('/home/dgolden/vlf/case_studies/image_euv_%04d/palmer_pp_db.mat', year);
load(db_filename, 'palmer_pp_db');

%% Sort and extract database fields
img_datenum = [palmer_pp_db.img_datenum];
idx_date = img_datenum >= start_datenum & img_datenum < end_datenum;
palmer_pp_db = palmer_pp_db(idx_date);
img_datenum = img_datenum(idx_date);

[~, idx] = sort(img_datenum);
palmer_pp_db = palmer_pp_db(idx);

img_datenum = [palmer_pp_db.img_datenum].';
pp_L = [palmer_pp_db.pp_L].';
pp_L2 = [palmer_pp_db.pp_L2].';

%% Run subfunction
switch plot_type
	case 'date_l_scatter'
		date_l_scatter(img_datenum, pp_L, pp_L2);
	case 'mlt_l_biv_hist'
		mlt_l_biv_hist(img_datenum, pp_L, pp_L2);
	case 'mlt_l_scatter'
		mlt_l_scatter(img_datenum, pp_L, pp_L2);
	case 'ae_cross_scatter'
		varargout{1} = ae_cross_scatter(palmer_pp_db, year, varargin);
	otherwise
		error('Invalid value for plot_type: %s', plot_type);
end

function date_l_scatter(img_datenum, pp_L, pp_L2)
% Just plot all the plasmapause values for the year. Doesn't incorporate
% the plume (yet)

%% Constants
global PALMER_MLT L_MIN L_MAX

%% Set up
figure;
hold on;

start_datenum = floor(min(img_datenum));
end_datenum = ceil(max(img_datenum));

%% Plot day and night lines
% if end_datenum - start_datenum < 4
% 	dawn_times = (start_datenum:end_datenum) + 0.25 - PALMER_MLT;
% 	dawn_times = dawn_times(dawn_times > start_datenum & dawn_times < end_datenum);
% 	dusk_times = (start_datenum:end_datenum) + 0.75 - PALMER_MLT;
% 	dusk_times = dusk_times(dusk_times > start_datenum & dusk_times < end_datenum);
% 	
% 	yellow = [0.9 0.9 0.3];
% 	blue = [0.5 0.5 0.8];
% 	for kk = 1:length(dawn_times)
% 		h_dawn = plot(dawn_times(kk)*[1 1], [L_MIN L_MAX], 'Color', yellow, 'LineWidth', 2);
% % 		annotation('arrow', [dawn_times(kk) dawn_times(kk)+0.05], ((L_MAX-L_MIN)/2 + L_MIN)*[1 1], 'Color', yellow, 'LineWidth', 2);
% 	end
% 	for kk = 1:length(dusk_times)
% 		h_dusk = plot(dusk_times(kk)*[1 1], [L_MIN L_MAX], 'Color', blue, 'LineWidth', 2);
% 	end
% end

%% Plot valid points
% Add Palmer's L-shell line
green = [0.3 0.7 0.3];
h_palmer_line = plot([start_datenum end_datenum], 2.44*[1 1], '--', ...
	'Color', green, 'LineWidth', 2);

pp1_color = [0.9 0.3 0.7]; % Pink/purple
pp2_color = [1 0.6 0]; % Orange

% Plot plasmapause points
valid_idx = ~isnan(pp_L);
% h_pp2 = scatter(img_datenum, min(pp_L2, L_MAX), 'o', 'Filled', 'cdata', pp2_color);
% h_pp1 = scatter(img_datenum, min(pp_L, L_MAX), 'o', 'Filled', 'cdata', pp1_color);
cdata = fpart(img_datenum(valid_idx) + PALMER_MLT);
h_pp1 = scatter(img_datenum(valid_idx), min(pp_L(valid_idx), L_MAX), 'o', 'Filled', 'cdata', cdata);
h_pp2 = scatter(img_datenum(valid_idx), min(pp_L2(valid_idx), L_MAX), 'o', 'Filled', 'cdata', cdata);
colormap(hsv);
datetick2('x', 'keeplimits');

c = colorbar;
caxis([0 1]);
datetick(c, 'y');
ylabel(c, 'Palmer LT');

grid on;
set(gca, 'Box', 'on');
xlim([start_datenum end_datenum]);
ylim([L_MIN L_MAX]);
xlabel('UTC');
ylabel('L');
title(sprintf('Plasmapause at Palmer''s Lon. (%s to %s)', datestr(start_datenum, 'yyyy-mm-dd'), datestr(end_datenum, 'yyyy-mm-dd')));

%% Plot invalid points
h_invalid = scatter(img_datenum(isnan(pp_L)), ones(1, sum(isnan(pp_L))), 'rx');
% h_unclear = scatter(img_datenum(isinf(pp_L)), L_MAX*ones(1, sum(isinf(pp_L))), 'o', 'CData', [0 0.9 0]);

%% Plot points for EUV images with no value set
% fits_dir = '/home/dgolden/vlf/case_studies/image_euv_2001/fits/';
% find_cmd = sprintf('find %s -regextype posix-extended -regex ".*/[0-9]{4}-[0-9]{2}-[0-9]{2}/eqmapped/.+_xform\\.fits" | sort', fits_dir);
% [~, filelist_str] = unix(find_cmd);
% filelist = textscan(filelist_str, '%s');
% filelist = filelist{1};
% 
% no_value_img_datenums = nan(size(filelist));
% for kk = 1:length(filelist)
% 	this_img_datenum = get_img_datenum(filelist{kk});
% 	if ~any(img_datenum == this_img_datenum)
% 		no_value_img_datenums(kk) = this_img_datenum;
% 	end
% end
% 
% no_value_img_datenums = no_value_img_datenums(~isnan(no_value_img_datenums));
% 
% h_noval = scatter(no_value_img_datenums, 1.2*ones(size(no_value_img_datenums)), 'gd', 'filled');

%% Mess with axis and figure size
figure_grow(gcf, 1.7, 1);
zoom xon;

%% Legend
% legend([h_pp, h_unclear, h_invalid, h_dawn, h_dusk, h_palmer_line], 'Plamapause', 'Plasmapause Unclear', ...
% 	'Invalid Image', 'Dawn', 'Dusk', 'Palmer L-Shell');


% if isempty(ax), increase_font(gca); end
increase_font;

function mlt_l_biv_hist(img_datenum, pp_L, pp_L2)
% Plot a 2-D histogram with L-shell and MLT as the independent variables,
% and number of images as the dependent variables
% 
% Lumps all "Inf" values in L=7, and chooses whichever's bigger: pp_L or
% pp_L2

%% Constants
global PALMER_MLT L_MIN L_MAX

%% Plot stuff
idx = ~isnan(pp_L);
date_edges = 0:3/24:1;
pp_edges = [2:1/3:6 inf];
edges = {date_edges, pp_edges};

% Maximum of pp_L and pp_L2, but no more than L_MAX
max_ppL = min([min([pp_L(idx).'; pp_L2(idx).']); L_MAX*ones(1, length(pp_L(idx)))]).';

[N, C] = hist3([fpart(img_datenum(idx) + PALMER_MLT) max_ppL], 'Edges', edges);
N = N(1:end-1, 1:end-1); C{1} = C{1}(1:end-1); C{2} = C{2}(1:end-1); % Remove superfluous bins

% Divide by the number of valid images in each MLT bin
num_images = histc(fpart(img_datenum(idx) + PALMER_MLT), date_edges);
num_images = num_images(1:end-1); % Remove superfluous bins

N_norm = zeros(size(N));
for kk = 1:size(N, 2)
	N_norm(:, kk) = N(:, kk)./num_images;
end



figure;
% Plot bivariate histogram
% s1 = subplot(4, 1, 1:3);
imagesc(C{1}, C{2}, N_norm.');
axis xy
colorbar
ylabel(colorbar, 'Fraction of images')
datetick('x', 'keeplimits')
ylabel('L');
title('Bivariate histogram of Palmer L-shell distribution with MLT');

% % Plot histogram of number of images per MLT bin
% s2 = subplot(4, 1, 4);
% b = bar(C{1}, num_images, 1);
% set(gca, 'yscale', 'log');
% ylim([1e1 10^max(ceil(log10(num_images)))]);
% set(get(b, 'baseline'), 'basevalue', 1);
% 
% % Kludge to line up the two axes, since the top one has a colorbar and the
% % bottom one doesn't
% pos1 = get(s1, 'position');
% pos2 = get(s2, 'position');
% set(gca, 'position', [pos2(1:2) pos1(3) pos2(4)]);
% 
% ylabel('# img');

datetick('x', 'keeplimits');
xlabel('MLT');
grid on;

increase_font;
figure_squish(gcf, 0.7, 1);

function mlt_l_scatter(img_datenum, pp_L, pp_L2)
% Plot a scatter plot type thing showing all the clicks for L-shell vs. MLT
% Takes the minimum of pp_L and pp_L2

%% Constants
global PALMER_MLT L_MIN L_MAX

%% Plot stuff
figure;

idx = ~isnan(pp_L);
plot(fpart(img_datenum(idx) + PALMER_MLT), min([pp_L(idx); pp_L2(idx); L_MAX*ones(size(pp_L(idx)))]), '.');
datetick('x', 'keeplimits')
grid on;
xlabel('MLT')
ylabel('L');
title('Palmer PP vs local time');

figure_squish(gcf, 0.6, 1);
increase_font;

function varargout = ae_cross_scatter(palmer_pp_db, year, other_args)
% rho = ae_cross_scatter(img_datenum, pp_L, pp_L2, year, other_args)
% other_args can include: ae_type, n_hours_history, mlt_sector, b_display_only
% 
% ae_type can be one of 'avg' (default) or 'max'
% n_hours_history should be an integer greater or equal to 0

%% Setup
if exist('other_args', 'var')
	if length(other_args) > 0 && ~isempty(other_args{1})
		ae_type = other_args{1};
	else
		ae_type = 'avg';
	end
	
	if length(other_args) > 1 && ~isempty(other_args{2})
		n_hours_history = other_args{2};
	else
		n_hours_history = 0;
	end
	
	if length(other_args) > 2 && ~isempty(other_args{3})
		mlt_sector = other_args{3};
	else
		mlt_sector = 0;
	end
	
	if length(other_args) > 3 && ~isempty(other_args{4})
		b_display_only = other_args{4};
	else
		b_display_only = false;
	end
end

global PALMER_MLT L_MIN L_MAX

addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics'));

%% Everything else

% Segment into MLT sector
% sector_names = {'All', 'post-midnight 00-06', 'pre-noon 06-12', 'post-noon 12-18', 'pre-midnight 18-24'};
% 
% if mlt_sector > 0
% 	idx_sec = fpart(img_datenum + PALMER_MLT) >= (mlt_sector - 1)*0.25 & ...
% 	          fpart(img_datenum + PALMER_MLT) < mlt_sector*0.25;
% else
% 	idx_sec = true(size(img_datenum));
% end

[mlt_idx, sector_name] = choose_mlt_sector([palmer_pp_db.img_datenum], mlt_sector);
palmer_pp_db = palmer_pp_db(mlt_idx);
img_datenum = [palmer_pp_db.img_datenum].';
pp_L = [palmer_pp_db.pp_L].';
pp_L2 = [palmer_pp_db.pp_L2].';


% Discard values of nan or where the plasmapause was off the image
valid_idx = all(isfinite([pp_L, pp_L2].')).';
img_datenum = img_datenum(valid_idx);
pp_L = pp_L(valid_idx);
pp_L2 = pp_L2(valid_idx);
max_pp = max([pp_L pp_L2].').';


[ae_date, ae] = ae_read_datenum(year);

switch ae_type
	case 'avg'
		% Average AE in last N hours
		ae_star_int = interp1(ae_date + n_hours_history/2/24, smooth(ae, n_hours_history + 1), img_datenum);
	case 'max'
		% Max AE in last N hours
		ae_star_datenum = img_datenum(1):(max(n_hours_history, 1)/2/24):(img_datenum(end) + max(1, n_hours_history/24));
		ae_star = get_idx_star(ae, ae_date, ae_star_datenum, n_hours_history, 'max');
		ae_star_int = interp1(ae_star_datenum, ae_star, img_datenum);
end

% if b_display_only
% 	disp(sprintf('%s AE in prev. %d hours', ae_type, n_hours_history));
% end

n = length(max_pp);
rho = corr(log10(ae_star_int), max_pp);
[p, S] = polyfit(log10(ae_star_int), max_pp, 1);
sigma_err = S.normr/sqrt(n - 2); % See Navidi (2006) p 509
ae_star_int_fit = logspace(log10(min(ae_star_int)), log10(max(ae_star_int)), 10);
max_pp_fit = polyval(p, log10(ae_star_int_fit));

% Prediction interval. See Navidi (2006) p 516, equation 7.40
err_fit = abs(tinv(0.025, n-2))*sigma_err*sqrt(1 + 1/n + (log10(ae_star_int_fit) - mean(log10(ae_star_int))).^2/sum((log10(ae_star_int) - mean(log10(ae_star_int))).^2));

% if b_display_only
% 	fprintf(1, '\n');
% end

face_color = [0.95 0.6 0]; % Orange

if ~b_display_only
% 	figure;
	semilogx(ae_star_int, max_pp, 'k.');
	grid on
	ylim([2 7]);
	
	% Plot fit
	hold on;
	semilogx(ae_star_int_fit, max_pp_fit, 'r', 'LineWidth', 2);
% 	semilogx(ae_star_int_fit, max_pp_fit - err_fit, 'r', 'LineWidth', 2);
% 	semilogx(ae_star_int_fit, max_pp_fit + err_fit, 'r', 'LineWidth', 2);
	
	xlabel(sprintf('%s AE in prev. %d hours (nT)', ae_type, n_hours_history));
	ylabel('Plasmapause extent (R_E)');
	title(sprintf('%s MLT (\\rho = %0.2f, \\sigma_{err} = %0.2f)', sector_name, rho, sigma_err));

	increase_font;
end

if nargout > 0
	varargout{1} = rho;
end
