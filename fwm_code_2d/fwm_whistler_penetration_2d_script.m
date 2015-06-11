% fwm_whistler_penetration_2d_script

clear;

time_start = now;
disp(sprintf('Script begun at %s', datestr(time_start)));

plot_path = '/media/vlf-alexandria-array/data_products/dgolden/fwm_output/';

% f_min = 500;
% f_max = 1e3;
% f_vec = logspace(log10(f_min), log10(f_max), 5);
f_vec = [500 1000 2000 5000];
L_vec = [2 2.44 3 4 5];
wn_angle_vec = linspace(-pi/4, pi/4, 5);
% gnd_vec = {'seawater', 'ice'};

% f_vec = 4000;
% L_vec = 4;
% wn_angle_vec = 0;
gnd_vec = {'conductor'};

n_iterations = length(f_vec)*length(L_vec)*length(wn_angle_vec)*length(gnd_vec);

showplots = [0 0 0 0 0];

it_no = 1;
for hh = 1:length(f_vec)
	for ii = 1:length(L_vec)
		for jj = 1:length(gnd_vec)
			for kk = 1:length(wn_angle_vec)
				tic;
				
				disp(sprintf('*** ITERATION %d of %d ***', it_no, n_iterations));
				
				f = f_vec(hh);
				L = L_vec(ii);
				gnd = gnd_vec{jj};
				wn_angle = wn_angle_vec(kk);
				
				[S, x, hi, P_init] = fwm_whistler_penetration_2d(f, L, wn_angle, gnd, showplots);

				filetags = sprintf('%s_f%04.0f_L%1.2f_wn%+04.0f', gnd, f, L, wn_angle*180/pi);

				sfigure(2);
				print('-dpng', fullfile(plot_path, 'gnd_p', sprintf('gnd_p_rx_%s.png', filetags)));

				sfigure(3);
				print('-dpng', fullfile(plot_path, 'p_full', sprintf('p_full_%s.png', filetags)));

				save(fullfile(plot_path, 'mat', sprintf('S_%s.mat', filetags)), 'S', 'x', 'hi', 'f', 'L', 'wn_angle', 'gnd', 'P_init');
				
				disp(sprintf('Iteration %d took %0.0f seconds\n', it_no, toc));
				
				it_no = it_no + 1;
			end
		end
	end
end

time_end = now;
disp(sprintf('Script finished at %s', datestr(time_end)));
disp(sprintf('Took %s hours, %s minutes, %s seconds', datestr(time_end - time_start, 'HH'), ...
	datestr(time_end - time_start, 'MM'), datestr(time_end - time_start, 'SS')));
