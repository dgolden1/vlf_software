function plot_gnd_power(f_target, L_target, gnd_type_target, wn_target)
% plot_gnd_power(f_target, L_target, gnd_type_target, wn_target)
% Make overlapping plots of power received on the ground

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Setup
% close all;
% clear;

PALMER_L_SHELL = 2.44;

if ~exist('bSelectFiles', 'var') || isempty(bSelectFiles)
	bSelectFiles = false;	
end

fwm_output_dir = '/media/vlf-alexandria-array/data_products/dgolden/fwm_output/mat';
hi_x_dir = '/media/vlf-alexandria-array/data_products/dgolden/fwm_output';

bPlot2d = true;
bPlot3d = false;
bPlotComplicatedPlot = true;
bPlotAttenRate = false;
bRejectConductor = false; % True to not plot any runs using conductor for layer 0 (it's the same as seawater)

bDbLim = true;
db_max = -100;
db_min = -200;
atten_max = 1;
atten_min = -5;
xmin = -2000;
xmax = 2000;

%% Choose what to plot

if ~exist('f_target', 'var'), f_target = 1000; end
if ~exist('L_target', 'var'), L_target = 2.44; end
if ~exist('gnd_type_target', 'var'), gnd_type_target = 'seawater'; end
if ~exist('wn_target', 'var'), wn_target = 0; end

%% Load files
d = dir(fullfile(fwm_output_dir, 'S*.mat'));

f_vec = [];
L_vec = [];
wn_vec = [];
gnd_type_vec = {};
P_init_vec = [];

legend_txt = {};
S_vec = zeros(3, 121, 4096, 0);

if bSelectFiles
	error('I''ll finish this later. --Dan 2008-04-04');
	
	[filename, pathname] = uigetfile('*.mat', 'Select fwm_whistler_penetration output file', 'MultiSelect', 'on');
	if ~ischar(filename) && ~iscell(filename) % If user pressed cancel
		return;
	elseif ~iscell(filename)
		filename = {filename};
	end
	
	for kk = 1:length(filename)
		load(fullfile(pathname, filename{kk}));
		
	end
	
else
	for kk = 1:length(d)
		filename = d(kk).name;
		remain = filename;

		[token, remain] = strtok(remain, '_'); % leading S
		assert(strcmp(token, 'S'));
		[gnd_type, remain] = strtok(remain, '_'); % ground type
		[token, remain] = strtok(remain, '_'); % f
		f = str2double(token(2:end));
		[token, remain] = strtok(remain, '_'); % L
		L = str2double(token(2:end));
		[token, remain] = strtok(remain, '_'); % wave normal
		wn = str2double(token(3:6));

		assert(isempty(remain));

		if ~isempty(f_target) && f ~= f_target, continue; end
		if ~isempty(L_target) && L ~= L_target, continue; end
		if ~isempty(wn_target) && wn_target ~= wn, continue; end
		if ~isempty(gnd_type_target) && ~strcmp(gnd_type, gnd_type_target), continue; end
		if bRejectConductor && strcmp(gnd_type, 'conductor'), continue; end

% 		legend_txt{end+1} = sprintf('%s, f=%04.0f, L=%0.2f, wn=%03.0f', gnd_type, f, L, wn);
		legend_txt{end+1} = sprintf('f=%04.0f, L=%0.2f, wn=%03.0f', f, L, wn);

		f_vec(end+1) = f;
		L_vec(end+1) = L;
		wn_vec(end+1) = wn;
		gnd_type_vec{end+1} = gnd_type;

		load(fullfile(fwm_output_dir, filename));

		P_init_vec(end+1) = P_init;
		S_vec(:,:,:,end+1) = S;
	end
end

if isempty(S_vec)
	disp('No valid files');
	return;
end

%% Sort by wavenormal angle (which is by default sorted by name, which is confusing)
[junk, sort_i] = sort(wn_vec);
f_vec = f_vec(sort_i);
L_vec = L_vec(sort_i);
wn_vec = wn_vec(sort_i);
gnd_type_vec = {gnd_type_vec{sort_i}};
P_init_vec = P_init_vec(sort_i);
legend_txt = {legend_txt{sort_i}};
S_vec = S_vec(:,:,:,sort_i);

%% Extract ground power and load x and y axes
S_gnd_vec = zeros(size(S_vec, 4), size(S_vec, 3)); % S_gnd_vec(measurement #, x value)
for kk = 1:size(S_vec, 4)
	S_vec_t = squeeze(sqrt(sum(S_vec(:,:,:,kk).^2)))/P_init_vec(kk);
	S_gnd_vec(kk,:) = S_vec_t(1,:);
end

load(fullfile(hi_x_dir, 'x.mat'));
load(fullfile(hi_x_dir, 'hi.mat'));

%% 2-D Plot
if bPlot2d
	figure;
	plot(x/1e3, 10*log10(S_gnd_vec), 'LineWidth', 2);
	grid on;
	xlim([xmin xmax]);
	if bDbLim, ylim([db_min db_max]); end
	xlabel('x (km)');
	ylabel('Power (dB)');
	title('Total power received on ground (normalized dB)');
	
	% Add Palmer's location
	load('../palmer_distance_to_l/palmer_distances.mat');
	dist = interp1(l_shells, palmer_distances, L_target);
	hold on;
	yl = ylim;
	plot(dist*[1 1], yl, 'k--', 'LineWidth', 2);

	legend(legend_txt, 'Distance to Palmer');
	
	increase_font(gca);
end

%% 3-D color plot
if bPlot3d
	if isempty(f_target)
		yticks = f_vec;
	elseif isempty(L_target)
		yticks = L_vec;
	elseif isempty(wn_target)
		yticks = wn_vec;
	else
		error('I don''t know how to make the y limits');
	end

	figure;
	imagesc(x/1e3, yticks, 10*log10(S_gnd_vec));
	axis xy;
	grid on;
	xlim([xmin xmax]);
	xlabel('x (km)');
	ylabel('Power (normalized dB)');
	set(gca, 'ytick', yticks)
	title('Total power received on ground (dB)');
end

%% Complicated plot with a lot of junk
if bPlotComplicatedPlot && length(f_vec) == 1
	figure;
	
	% Plot spatial power distribution
	subplot(3, 3, 1:2);
	imagesc(x/1e3, hi, 10*log10(S_vec_t));
	axis xy;
	pos = get(gca, 'Position');
	set(gca, 'Position', [pos(1) pos(2) pos(3)*0.9 pos(4)]); % Smush axis in x-direction a little
% 	xlim([xmin xmax]);
	xlim([-xmax xmax]);
	xlabel('x (km)');
	ylabel('Height (km)');
	title('Net power distribution');
	
	c = colorbar;
	if bDbLim, caxis([db_min db_max]); end
	set(get(c, 'YLabel'), 'String', 'Power (normalized dB)');
	set(get(c, 'ylabel'), 'Rotation', 270);
	set(get(c, 'ylabel'), 'VerticalAlignment', 'bottom');
	
	% Plot wave injection geometry
	subplot(3, 3, 3);
	plot_wave_injection_geometry(L_vec, wn_vec*pi/180, gnd_type_vec{1}, false, false);
	
	% Plot power received on ground
	subplot(3, 3, 4:9)
	plot(x/1e3, 10*log10(S_gnd_vec), 'LineWidth', 2);

	pos = get(gca, 'Position');
	set(gca, 'Position', [pos(1) pos(2) pos(3) pos(4)*0.85]); % Smush axis in y-direction a little

	grid on;
% 	xlim([xmin xmax]);
	xlim([-xmax xmax]);
	if bDbLim, ylim([db_min db_max]); end
	xlabel('x (km)');
	ylabel('Power (dB)');
	title('Total power received on ground (normalized dB)');

	% Add Palmer's location
	load('../palmer_distance_to_l/palmer_distances.mat');
	dist = interp1(l_shells, palmer_distances, L_target);
	power_at_dist = interp1(x/1e3, 10*log10(S_gnd_vec), dist);
	hold on;
	mk = plot(dist, power_at_dist, 'ro');
	set(mk, 'MarkerSize', 10);
	set(mk, 'MarkerFaceColor', 'r');
	set(mk, 'MarkerEdgeColor', 'k');
	set(mk, 'LineWidth', 1);

	legend(legend_txt, 'Distance to Palmer');

	increase_font(gcf);
end

%% Attenuation Rate
if bPlotAttenRate
	figure;
	
	slope_x_min = 100e3;

	atten_rate_units = 100e3; % Attenuation rate will be expressed in "dB/atten_rate_units"
	
	dx = mean(diff(x));

% 	S_gnd_vec_lowpass = lowpass_power(S_gnd_vec); % Lowpass to remove high frequency wiggles
% 	atten_rate_db = diff(10*log10(S_gnd_vec_lowpass).').';

	atten_rate_db = diff(10*log10(S_gnd_vec).').';
	atten_rate_db(10*log10(S_gnd_vec(:,2:end)) < db_min) = NaN; % Don't plot slope for really low values of the wave (which are just noise)
% 	atten_rate_db(:,abs(x) < slope_x_min) = NaN; % Don't plot slope for really small x values, which have really high slopes
	atten_rate_db(:, x < 0) = -atten_rate_db(:, x < 0); % Reverse sign for x < 0 (otherwise, it looks like amplification)
	
	plot(x(2:end)/1e3, atten_rate_db/dx*atten_rate_units, 'LineWidth', 2);
	grid on;
	xlim([xmin xmax]);
	ylim([atten_min atten_max]);
	xlabel('x (km)');
	ylabel(sprintf('Loss rate (dB/%d km)', atten_rate_units/1e3));
	title('Attenuation rate of power received on ground');
	legend(legend_txt);
	
	increase_font(gca);

end

