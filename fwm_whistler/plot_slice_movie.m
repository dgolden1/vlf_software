function plot_slice_movie(f, L)
% plot_slice_movie(f, L)
% Plot a movie of moving volumetric slicesfrom whistler FWM code

% -X IS POLEWARD

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
error(nargchk(2, 2, nargin));

input_dir = '/media/vlf-alexandria-array/data_products/dgolden/output';

b_use_palmer_x_shift = 1;

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

for kk = 1:length(d)
	if (f == f_list(kk)) && (L == L_list(kk))
		load(fullfile(input_dir, name_list{kk}));

		B_db = squeeze(10*log10(sum(abs(B/1e-15).^2)));

		if b_use_palmer_x_shift
			x_shift = interp1(l_shells, palmer_distances, L_list(kk));
			x_plot = xkm - x_shift;
		else
			x_plot = xkm;
		end

		% 			[Xkm, Zkm, Ykm] = meshgrid(x_plot, zkm, ykm);
		% 			s = slice(Xkm, Zkm, Ykm, B_db, 0, [0 140], 0);
		[Xkm, Ykm, Zkm] = meshgrid(x_plot, ykm, zkm);
		
		slice_heights = linspace(140, 0, 50);

		figure;
		frames = getframe;
		frames = repmat(frames, 1, length(slice_heights));
		frameno = 1;
		for jj = 1:length(slice_heights)
			s = slice(Xkm, Ykm, Zkm, permute(B_db, [3 2 1]), 0, 0, [0 slice_heights(jj)]);
			xlabel('x'); ylabel('y'); zlabel('z');
			set(s, 'edgecolor', 'none');

			axis tight;

			c = colorbar;
			set(get(c, 'ylabel'), 'string', 'dB-fT');
			
			drawnow;
			
			print('-dpng', '-r50', sprintf('frame_out/frame%03d', frameno));
			frameno = frameno + 1;
% 			frames(jj) = getframe;
		end
	else
		continue;
	end
end

% movie2avi(frames, 'movie.avi');
