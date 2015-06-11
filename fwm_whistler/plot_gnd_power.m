function plot_gnd_power(f_vec, L_vec, b_3d_gnd_plot, b_3d_space_plot, b_multi_slice_plot, b_2d_plot)
% plot_gnd_power(f_vec, L_vec, b_3d_gnd_plot, b_3d_space_plot, b_multi_slice_plot, b_2d_plot)
% Plot ground power from whistler FWM code

% -X IS POLEWARD

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
error(nargchk(0, 6, nargin));

if nargin == 0
	warning('No input arguments; gathering all files in input_dir');
end

input_base_dir = fullfile(scottdataroot, 'user_data/dgolden/output/fwm_output/vertical');

disp('Vertical B-field');

% input_dir = fullfile(input_base_dir, 'summer_day'); t_str = 'summer day';
input_dir = fullfile(input_base_dir, 'summer_night'); t_str = 'summer night';
% input_dir = fullfile(input_base_dir, 'winter_day'); t_str = 'winter day';
% input_dir = fullfile(input_base_dir, 'winter_night'); t_str = 'winter night';
% input_dir = fullfile(input_base_dir, 'stanford_eprof3'); t_str = 'stanford eprof3';
% input_dir = '/home/dgolden/vlf/vlf_software/dgolden/fwm_whistler';

if ~exist('f_vec', 'var')
	f_vec = [];
end
if ~exist('L_vec', 'var')
	L_vec = [];
end
if ~exist('b_3d_gnd_plot', 'var') || isempty(b_3d_gnd_plot)
  b_3d_gnd_plot = true;
end
if ~exist('b_3d_space_plot', 'var') || isempty(b_3d_space_plot)
  b_3d_space_plot = true;
end
if ~exist('b_multi_slice_plot', 'var') || isempty(b_multi_slice_plot)
  b_multi_slice_plot = true;
end
if ~exist('b_2d_plot', 'var') || isempty(b_2d_plot)
  b_2d_plot = true;
end

b_use_palmer_x_shift = 0;

%% X-shift - get distance from Palmer to other l-shells
load(fullfile(danmatlabroot, 'vlf', 'palmer_distance_to_l', 'palmer_distances.mat'), 'l_shells', 'palmer_distances');


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
for kk = 1:length(d)
	f = f_list(kk);
	L = L_list(kk);
	if (isempty(f_vec) || ~isempty(find(f_vec == f, 1))) && ...
			(isempty(L_vec) || ~isempty(find(L_vec == L, 1)))
		load(fullfile(input_dir, name_list{kk}), 'B', 'xkm', 'ykm', 'zkm');

%% 3-D Space plot
		if b_3d_space_plot
			y_mid = find(ykm == 0);
			assert(length(y_mid) == 1);

			B_pow_slice = squeeze(sum(abs(B(:,:,:,y_mid)).^2)); %#ok<COLND>

			if b_use_palmer_x_shift
				x_shift = interp1(l_shells, palmer_distances, L_list(kk));
				if L_list(kk) < 2.44, x_shift = -x_shift; end
			else
				x_shift = 0;
			end

			figure;
			imagesc(xkm - x_shift, zkm, 10*log10(B_pow_slice/max(B_pow_slice(:))));
			axis xy equal tight;
			xlabel('x (km)');
			ylabel('z (km)');
			title(sprintf('B-field on ground (f = %04d Hz, L = %0.2f)', f, L));
			c = colorbar('location', 'southoutside');
			set(get(c, 'ylabel'), 'string', 'dB');
			increase_font(gcf, 16);
			figure_squish(gcf, 1/2, 2);
      
      set(gcf, 'tag', '3dspaceplot');
		end

%% Multiple slice plot
		if b_multi_slice_plot
			B_db = squeeze(10*log10(sum(abs(B).^2)));
      B_db = B_db - max(B_db(:));

			if b_use_palmer_x_shift
				x_shift = interp1(l_shells, palmer_distances, L_list(kk));
				x_plot = xkm - x_shift;
			else
				x_plot = xkm;
			end

			figure;
% 			[Xkm, Zkm, Ykm] = meshgrid(x_plot, zkm, ykm);
% 			s = slice(Xkm, Zkm, Ykm, B_db, 0, [0 140], 0);
			[Xkm, Ykm, Zkm] = meshgrid(x_plot, ykm, zkm);
			s = slice(Xkm, Ykm, Zkm, permute(B_db, [3 2 1]), [], 0, [0 140]);
			xlabel('x (km)'); ylabel('y (km)'); zlabel('z (km)');
			title(sprintf('%s, f = %04d Hz, L = %0.2f', t_str, f, L));
			set(s, 'edgecolor', 'none');

			axis tight;

			c = colorbar;
			set(get(c, 'ylabel'), 'string', 'dB');
			increase_font(gcf, 16);
      
      set(gcf, 'tag', 'multisliceplot');
		end

%% 3-D Ground Plot
		if b_3d_gnd_plot
			B_gnd = squeeze(B(:,1,:,:)); %#ok<COLND>

			if b_use_palmer_x_shift
				x_shift = interp1(l_shells, palmer_distances, L_list(kk));
				if L_list(kk) < 2.44, x_shift = -x_shift; end
			else
				x_shift = 0;
      end

      B_gnd_pow = squeeze(sum(abs(B_gnd/1e-15).^2));
      B_gnd_pow = B_gnd_pow/max(B_gnd_pow(:));
      
			figure;
% 			imagesc(xkm - x_shift, ykm, squeeze(10*log10(sum(abs(B_gnd/1e-15).^2))).');
			imagesc(xkm - x_shift, ykm, 10*log10(B_gnd_pow.'));
			axis xy equal tight;
			xlabel('x (km)');
			ylabel('y (km)');
			title(sprintf('B-field on ground (f = %04d Hz, L = %0.2f)', f, L));
			c = colorbar;
			set(get(c, 'ylabel'), 'string', 'dB');
			increase_font(gcf, 16);
      
      set(gcf, 'tag', '3dgndplot');
		end

%% 2-D superimposed plot
		if b_2d_plot
			yc = find(ykm == 0);
			B_db = squeeze(10*log10(sum(abs(B).^2)));
			B_norm_db = B_db - max(B_db(:));
			B_gnd = squeeze(B_norm_db(1,:,yc));


			if b_use_palmer_x_shift
				x_shift = interp1(l_shells, palmer_distances, L_list(kk));
				if L_list(kk) < 2.44, x_shift = -x_shift; end
			else
				x_shift = 0;
			end

			if ~exist('lp_xmat', 'var'), lp_xmat = []; end
			if ~exist('lp_ymat', 'var'), lp_ymat = []; end
			if ~exist('legend_txt', 'var'), legend_txt = {}; end
			lp_xmat(end+1, :) = xkm - x_shift;
			lp_ymat(end+1, :) = B_gnd;

			legend_txt{end+1} = sprintf('f=%d Hz, L=%0.2f', f_list(kk), L_list(kk));

		end

	else
		continue;
	end
end

%% 2-D superimposed plot postprocessing
if b_2d_plot
	figure;
	hold all;
	lines_h = [];

	for kk = 1:size(lp_xmat, 1)
		lines_h(end+1) = plot(lp_xmat(kk,:), lp_ymat(kk,:), 'LineWidth', 2);
	end
	
	grid on;
	xlabel('x (km)');
	ylabel('Normalized dB');
	title(t_str);
	
	increase_font(gcf, 16);
	legend(lines_h, legend_txt);
  
  set(gcf, 'tag', '2dgndpower');
end
