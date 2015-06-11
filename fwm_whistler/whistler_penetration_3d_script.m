function whistler_penetration_3d_script(f_vec, L_vec, iteration_start, iteration_end, b_use_palmer_limits)
% If L_vec is 0, the simulation is run with b0 as it is at Palmer
% If b_use_palmer_limits is true, the x-limits are defined so that Palmer
% is contained in the simulation grid

% $Id$

%% Make an extra directory for backup files (for running multiple instances on one machine)
addpath(fullfile(danmatlabroot, 'vlf', 'fwm_common'));

%% Pick ionospheric profile
vlf_ion_prof = 'summer_night';
% vlf_ion_prof = 'summer_day';
% vlf_ion_prof = 'winter_night';
% vlf_ion_prof = 'winter_day';


%% Setup
if ~exist('f_vec', 'var') || isempty(f_vec)
	f_vec = [300 1000 2000 4000];
end
if ~exist('L_vec', 'var') || isempty(L_vec)
% 	L_vec = [2 2.44 3 4 5];
	L_vec = 0;
end
if ~exist('b_use_palmer_limits') || isempty(b_use_palmer_limits)
	b_use_palmer_limits = true;
end

total_iterations = length(f_vec)*length(L_vec);
if ~exist('iteration_start') || isempty(iteration_start)
	iteration_start = 1;
end
if ~exist('iteration_end') || isempty(iteration_end)
	iteration_end = total_iterations;
end


%% Host-specific settings
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
	case 'vlf-alexandria'
		output_dir = fullfile('/array/data_products/dgolden/output/vertical', vlf_ion_prof);
		PARALLEL = true;
	case 'scott.stanford.edu'
		output_dir = fullfile('/data/user_data/dgolden/output/fwm_output/vertical', vlf_ion_prof);
		PARALLEL = true;
	case 'amundsen.stanford.edu'
		output_dir = fullfile('/data/user_data/dgolden/output/fwm', vlf_ion_prof);
		PARALLEL = true;
	case 'quadcoredan.stanford.edu'
		output_dir = '~/temp';
		PARALLEL = false;
	otherwise
		error('Weird hostname ''%s''', hostname);
end

%% Set up loop variables
t_net_start = now;

L_vec_map = [0 2 2.44 3 4 5];
x_lim_map = [-100 2000; -900 100; -500 500; -100 800; -100 1600].';
y_lim = [-500 500];
x_lim_default = [-1000 1000];
y_lim_default = [-1000 1000];

if ~b_use_palmer_limits
	y_lim = y_lim_default;
end

[f_mat, L_mat] = meshgrid(f_vec, L_vec);
f_vec_long = f_mat(:);
L_vec_long = L_mat(:);

inv_lat = acos(sqrt(1./L_vec_long));
thB_vec_long = pi/2 - atan(2*tan(inv_lat));
thB_vec_long(L_vec_long == 0) = 0; % If L == 0, that actually means vertical B

x_lim_vec = zeros(2, length(L_vec_long));
for kk = 1:length(L_vec_long)
	if b_use_palmer_limits
		idx = find(L_vec_map == L_vec_long(kk));
		if length(idx) ~= 1
			error('No x-limits defined for L = %f', L_vec_long(kk));
		end
		x_lim_vec(:, kk) = x_lim_map(:, L_vec_map == L_vec_long(kk));
	else
		x_lim_vec(:, kk) = x_lim_default;
	end
end



%% Parallel
if ~PARALLEL
	warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
	matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
	matlabpool('close');
end

%% Load ionospheric profile
load(['ne_palmer_' vlf_ion_prof '.mat']);
ion_prof = [h Ne];

switch vlf_ion_prof
	case {'summer_night', 'winter_night', 'winter_day'}, b_double_tol = false;
	case {'summer_day'}, b_double_tol = false;
end

%% The loop
% warning('parfor disabled!');
% for kk = iteration_start:iteration_end
parfor kk = iteration_start:iteration_end
	t_start = now;

	f = f_vec_long(kk);
	thB = thB_vec_long(kk);
	L = L_vec_long(kk);
	
	disp(sprintf('Iteration %d (f=%04d, L=%0.2f, thB=%0.2f) started at %s', ...
		kk, f, L, thB*180/pi, datestr(now)));

	output_filename = fullfile(output_dir, sprintf('fwm3d_f%04d_l%03d.mat', f, L*100));

	if exist(output_filename, 'file'), continue; end

	backup_filename = sprintf('fwm_whistler_f%04d_L%0.2f', f, L);
	[xkm, ykm, zkm, E, B] = whistler_penetration_3d(thB, f, x_lim_vec(:,kk), y_lim, ...
		[], ion_prof, b_double_tol, backup_filename);
%		[xkm, ykm, zkm, E, B] = whistler_penetration_3d(thB, f, [-750 750], y_lim);


	save_output(output_filename, f, L, thB, xkm, ykm, zkm, E, B)

	close all;
	
	delete(sprintf('%s*.mat', backup_filename));

	fprintf('Processed f=%0.0f, L=%0.1f (iteration %d of %d) in %s\n', ...
		f, L, kk - iteration_start + 1, iteration_end - iteration_start + 1);
%		!rm whistlerpenetrfull_FWM_*.mat
end

fprintf('Finished in %s\n', time_elapsed(t_net_start, now));

function save_output(output_filename, f, L, thB, xkm, ykm, zkm, E, B)
save(output_filename, 'f', 'L', 'thB', 'xkm', 'ykm', 'zkm', 'E', 'B');
