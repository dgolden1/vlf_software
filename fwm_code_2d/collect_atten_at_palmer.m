% Script to collect info from each run and save attenuation from z=0, x=0
% to z=0, x=distance to Palmer

% By Daniel Golden (dgolden1 at stanford dot edu) April 2008
% $Id$

%% Setup
fwm_output_dir = '/media/vlf-alexandria-array/data_products/dgolden/fwm_output/2008-04-14/mat';
l_shell_dist_file = '/home/dgolden/vlf/vlf_software/dgolden/palmer_distance_to_l/palmer_distances.mat'; % File containing distances from Palmer to different L-shells
hi_x_dir = '/media/vlf-alexandria-array/data_products/dgolden/fwm_output';

load(l_shell_dist_file);
load(fullfile(hi_x_dir, 'x.mat'));

%% 
d = dir(fullfile(fwm_output_dir, 'S*.mat'));

f_vec = zeros(size(d));
L_vec = zeros(size(d));
wn_vec = zeros(size(d));
gnd_type_vec = cell(size(d));
P_init_vec = zeros(size(d));
P_src_vec = zeros(size(d));
P_palmer_vec = zeros(size(d));
palmer_dist_vec = zeros(size(d));

kill_idx = false(size(d));

for kk = 1:length(d)
	filename = d(kk).name;
	load(fullfile(fwm_output_dir, filename));
	
	if L < 2.44,
		kill_idx(kk) = true;
		continue;
	end
	
	f_vec(kk) = f;
	L_vec(kk) = L;
	wn_vec(kk) = wn_angle;
	P_init_vec(kk) = P_init;
	
	gnd_power = squeeze(sqrt(sum(S(:,1,:).^2)))/P_init;
	
	% Find distance from this L-shell (closest point) to Palmer
	palmer_dist_vec(kk) = interp1(l_shells, palmer_distances, L);
	
	% Get power under source and at palmer
	P_src_vec(kk) = interp1(x/1e3, gnd_power, 0);
	P_palmer_vec(kk) = interp1(x/1e3, gnd_power, palmer_dist_vec(kk));
end

f_vec(kill_idx) = [];
L_vec(kill_idx) = [];
wn_vec(kill_idx) = [];
P_init_vec(kill_idx) = [];
P_src_vec(kill_idx) = [];
P_palmer_vec(kill_idx) = [];
palmer_dist_vec(kill_idx) = [];


% %% Reshape outputs as P_src_vec(f, L, wn)
% f_vec_unique = sort(unique(f_vec));
% L_vec_unique = sort(unique(L_vec));
% wn_vec_unique = sort(unique(wn_vec));
% 
% P_src_mat = zeros(length(f_vec_unique), length(L_vec_unique), length(wn_vec_unique));
% P_palmer_mat = zeros(length(f_vec_unique), length(L_vec_unique), length(wn_vec_unique));
% P_init_mat = zeros(length(f_vec_unique), length(L_vec_unique), length(wn_vec_unique));
% palmer_dist_mat = zeros(length(f_vec_unique), length(L_vec_unique), length(wn_vec_unique));
% P_src_mat(:) = P_src_vec(:); % Assumes that P_src_vec goes in the right order!
% P_palmer_mat(:) = P_palmer_vec(:);
% P_init_mat(:) = P_init_vec(:);
% palmer_dist_mat(:) = palmer_dist_vec(:);
% 
% f_vec = f_vec_unique;
% L_vec = permute(L_vec_unique, [3 1 2]);
% wn_vec = permute(wn_vec_unique, [2 3 1]);

%% Save
save('palmer_atten.mat', 'f_vec', 'L_vec', 'wn_vec', 'P_init_vec', 'P_src_vec', 'P_palmer_vec', 'palmer_dist_vec');
