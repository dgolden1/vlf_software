function create_attenuation_plot
% Makes a plot where each pixel is an L value and frequency, and the
% amplitude is the attenuation from the injection point to Palmer

% By Daniel Golden (dgolden1 at stanford dot edu) Dec 2008
% $Id$

%% Setup
input_dir = '/media/vlf-alexandria-array/data_products/dgolden/output/ion_summer_night';

b_load_values = 0;
b_save_values = 0;

%% X-shift - get distance from Palmer to other l-shells
load('../palmer_distance_to_l/palmer_distances.mat', 'l_shells', 'palmer_distances');

%% Get list of files
d = dir(fullfile(input_dir, 'fwm3d_*.mat'));
f_list = zeros(1, length(d));
L_list = zeros(1, length(d));
name_list = {d.name};
for kk = 1:length(d)
	f_list(kk) = str2double(d(kk).name(8:11));
	L_list(kk) = str2double(d(kk).name(14:16))/100;
end

%% Big loop
if b_load_values
	load('attenuation_matrix.mat', 'f_list', 'L_list', 'B_palmer');
else
	B_palmer = zeros(1, length(d)); % dB-fT
	for kk = 1:length(d)
		load(fullfile(input_dir, name_list{kk}), 'B', 'xkm', 'ykm', 'zkm');

		B_db = squeeze(10*log10(sum(abs(B/1e-15).^2)));
		B_max = max(B_db(:));

		y_mid = find(ykm == 0);

		% Distance from injection point (xkm = 0) to Palmer
		x_shift = interp1(l_shells, palmer_distances, L_list(kk));
		if L_list(kk) < 2.44, x_shift = -x_shift; end

		avg_radius = 50; % Radius from palmer, in km, to average around to get Palmer's amplitude
		
		% B_palmer is attenuation, from maximum value in ionosphere, to
		% a small radius around Palmer
		B_palmer(kk) = mean(interp1(xkm, squeeze(B_db(1, :, y_mid)), linspace(x_shift - avg_radius, x_shift + avg_radius, 20))) - B_max;
	end
end

if ~b_load_values && b_save_values
	save('attenuation_matrix.mat', 'f_list', 'L_list', 'B_palmer');
end

%% Plot
figure;
numcols = floor(length(d)/5);
numel = numcols*5;
L_list_mat = reshape(L_list(1:numel), 5, numcols);
f_list_mat = reshape(f_list(1:numel), 5, numcols);
B_palmer_mat= reshape(B_palmer(1:numel), 5, numcols);

p = pcolor(f_list_mat, L_list_mat, B_palmer_mat);
set(p, 'linestyle', 'none');
c = colorbar;
set(get(c, 'ylabel'), 'String', 'dB-fT');
xlabel('f (Hz)');
ylabel('L shell');

n_pts_int = 40;
L_list_mat_i = repmat(linspace(L_list_mat(1,1), L_list_mat(5, 1), n_pts_int).', 1, n_pts_int);
f_list_mat_i = repmat(linspace(f_list_mat(1,1), f_list_mat(1, numcols), n_pts_int), n_pts_int, 1);
B_palmer_mat_i = interp2(f_list_mat, L_list_mat, B_palmer_mat, f_list_mat_i, L_list_mat_i);

p = pcolor(f_list_mat_i, L_list_mat_i, -B_palmer_mat_i);
set(p, 'linestyle', 'none');
c = colorbar;
set(get(c, 'ylabel'), 'String', 'dB-fT');
xlabel('f (Hz)');
ylabel('L shell');
title('Attenuation from space to Palmer');

increase_font(gcf, 16);
