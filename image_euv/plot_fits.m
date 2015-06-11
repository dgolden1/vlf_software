function varargout = plot_fits(fitsfilename, max_plot_L, figure_handle, axes_handle, palmer_pp_db_filename_or_struct, b_plot_color, b_contour, b_plot_l_lines)
% [info, imdata] = plot_fits(fitsfilename, max_plot_L, figure_handle, axes_handle, palmer_pp_db_filename_or_struct, b_plot_color, b_contour, b_plot_l_lines)
%  axes_handle, palmer_pp_db_filename_or_struct, b_plot_color, b_contour, b_plot_l_lines) 
% Plots an equatorially-mapped IMAGE EUV FITS file
% 
% If figure_handle or axes_handle is not specified, plot_fits will open a new window for
% plotting
% 
% If b_plot_color is true, the plot will be in black and white; otherwise, it
% will use the usual jet color scale

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Setup

if ~exist('max_plot_L', 'var') || isempty(max_plot_L), max_plot_L = inf; end
if ~exist('figure_handle', 'var'), figure_handle = []; end
if ~exist('axes_handle', 'var'), axes_handle = []; end
if ~exist('palmer_pp_db_filename_or_struct', 'var') || isempty(palmer_pp_db_filename_or_struct), palmer_pp_db_filename_or_struct = '/home/dgolden/vlf/case_studies/image_euv_2001/palmer_pp_db.mat'; end
if ~exist('b_plot_color', 'var') || isempty(b_plot_color), b_plot_color = true; end
if ~exist('b_contour', 'var') || isempty(b_contour), b_contour = true; end
if ~exist('b_plot_l_lines', 'var') || isempty(b_plot_l_lines), b_plot_l_lines = true; end

% Don't do colorbar if we're plotting this in a pre-made axis
if ~isempty(axes_handle)
	bNOANNOT = true;
else
	bNOANNOT = false;
end

% PALMER_LONGITUDE = -64.05; % Palmer station longitude in degrees
PALMER_MLT = -4; % Palmer MLT offset from UT, in hours
PALMER_L_SHELL = 2.44;

%% Read FITS file
info = fitsinfo(fitsfilename);
imdata = fitsread(fitsfilename);

%% Error checking - is this a non-equatorially mapped file?
if size(imdata, 1) ~= 600 || size(imdata, 2) ~= 600 || ndims(imdata) ~= 2
	error('Data must be a 600x600 array - is this file not equatorially mapped?');
end

%% Get image time and Calibrate
img_datenum = get_img_datenum(fitsfilename);
palmer_datenum = utc_to_palmer_lt(img_datenum);
imdata = calibrate_euv_image(imdata, img_datenum);

%% Rotate image 180 degrees so the sun is to the right
imdata = rot90(rot90(imdata));

%% Plot data
max_L = get_fits_keyword(info, 'MAX_L');
max_plot_L = min(max_plot_L, max_L);

x_sm = linspace(-max_L, max_L, size(imdata, 2));
y_sm = linspace(-max_L, max_L, size(imdata, 1));

% Silently open figure or axes without stealing focus
if isempty(figure_handle) && isempty(axes_handle)
	sfigure;
elseif ~isempty(axes_handle)
	saxes(axes_handle);
	cla;
else
	sfigure(figure_handle);
	clf;
end

cax = [10.2 12.7];
% Plot image
imagesc(x_sm, y_sm, log10(imdata));
hold on;

% Plot contour
if b_contour
	if b_plot_color
		contour_color = 'k';
	else
		contour_color = [1 1 1]*0.8;
	end
	cont_ss = 4; % Contour subsampling rate
	smooth_factor = round(20/cont_ss); % How much to smooth data when making contours
	contour(x_sm(1:cont_ss:end), y_sm(1:cont_ss:end), ...
		log10(smooth2(imdata(1:cont_ss:end, 1:cont_ss:end), smooth_factor)), ...
		linspace(cax(1), cax(2), 20), 'linecolor', contour_color, 'LineWidth', 1);
end

img_ax = gca;
set(img_ax, 'tag', 'img_ax');
caxis(cax);
axis(max_plot_L*[-1 1 -1 1]);
hold on;

if ~bNOANNOT
	c = colorbar;
	set(get(c, 'YLabel'), 'String', 'log He^+ Column Density (cm^{-2})');
end

axis xy square;

if b_plot_color, 
% 	colormap('jet');
	j = jet(64);
% 	j = j(15:end, :); % Only use part of the jet colormap
% 	for kk = 1:3, j(1:5, kk) = linspace(1, j(5, kk), 5); end % Fade to white
% 	j = j(20:end, :);
	colormap(j); 
else
	colormap(green);
end

xlabel('X_{SM} (R_E)');
ylabel('Y_{SM} (R_E)');

title(sprintf('IMAGE EUV %s UTC (%s Palmer MLT)', datestr(img_datenum, 31), datestr(palmer_datenum, 13)));

%% Draw L-shells
theta = (0:360)*pi/180;
if b_plot_l_lines
	center = 0; % Center of image in Re

	L = 1:max_L;
	for kk = 2:2:length(L)
		x = L(kk)*cos(theta) + center;
		y = L(kk)*sin(theta) + center;

		% Draw line
		plot(x, y, 'r--');

		% Label
		if L(kk) < max_plot_L
			text(L(kk)-0.2, 0, num2str(L(kk)), 'Color', 'r', 'BackgroundColor', 'w');
		end
	end
end

%% Draw Palmer's L-shell
if b_plot_l_lines
	x = PALMER_L_SHELL*cos(theta) + center;
	y = PALMER_L_SHELL*sin(theta) + center;

	plot(x, y, 'b--', 'LineWidth', 2);
end

%% Draw UTC midnight and Palmer lines
% Get image time of day (in decimal days)
img_time = img_datenum - floor(img_datenum);

% % I decided that the UTC line was dumb. Actually, Maria did. --Dan
% % Draw UTC midnight line
% [x, y] = get_fits_line(0, img_time, max_L);
% 
% c_green = [0.5 0.8 0.3];
% h_utc0_line = plot(x, y, '--', 'Color', c_green, 'LineWidth', 2);

% Draw Palmer line
[x, y] = get_fits_line(PALMER_MLT*2*pi/24, img_time, max_L);

h_p_line = plot(x, y, 'b--', 'LineWidth', 2);

%% Draw earth sun/shade icon
% Left side: dark
x = cos(theta).*(cos(theta) <= 0);
y = sin(theta);
fill(x, y, 'k');

% Right side: light
x = cos(theta).*(cos(theta) >= 0);
fill(x, y, 'w');

% Draw a circle around
x = cos(theta);
plot(x, y, 'k', 'LineWidth', 1);


%% Mark plasmapause from the palmer plasmapause database file
if ~isempty(palmer_pp_db_filename_or_struct)
	mark_pp_on_fits(palmer_pp_db_filename_or_struct, img_datenum, img_ax);
end

%% Legend
if ~bNOANNOT
	if exist('h_pp_loc', 'var')
		legend([h_p_line h_pp_loc], 'Palmer', 'Plasmapause');
	else
		legend(h_p_line, 'Palmer');
	end
	
	increase_font(gcf);
end

%% Assign output arguments
if nargout >= 1, varargout{1} = info; end
if nargout >= 2, varargout{2} = imdata; end
