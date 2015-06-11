function plot_palmer_avail_l_mlt(L_max, h_ax)
% Plot the availability of Palmer data by L and MLT
% 
% Look at a range of L shells, with the time in each one weighted by the
% relative attenuation (in units of power ratio) at that L shell vs the
% attenuation at L=2.44 (which has relative attenuation of 1).
% 
% I.e., assume there are 100 seconds of data at L=2.44 and the power is -22
% dB.  At L=3, the power is -44 dB.  So we assume that there are
% 100*10^((-44 - -22)/10) = 0.63 seconds of data at L=3
% 
% INPUTS
% L_max: maximum L extent of plot
% h_ax: an optional axes handles on which to put the plot

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
if ~exist('L_max', 'var')
  L_max = 6;
end
if ~exist('h_ax', 'var')
  h_ax = [];
end

palmer_lat = -64.77; % degrees
palmer_lon = -64.05;
palmer_inv_lat = -50; % Magnetic latitude, degrees
palmer_MLT_offset = -(4 + 1/60); % Offset from UTC in hours
Re = 6371e3; % Earth radius, km

addpath(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence')); % for find_terminator()


%% Map attenuation to L
dist_to_L = load(fullfile(danmatlabroot, 'vlf', 'palmer_distance_to_l', 'palmer_distances.mat'));

fwm = load(fullfile(scottdataroot, 'user_data', 'dgolden', 'output', 'fwm_output', 'vertical', 'summer_night', 'fwm3d_f2000_l000.mat'));

yc = fwm.ykm == 0;
B_db = squeeze(10*log10(sum(abs(fwm.B).^2)));
B_norm_db = B_db - max(B_db(:));
B_gnd_db = squeeze(B_norm_db(1,:,yc));

db_vs_L = interp1(fwm.xkm, B_gnd_db, dist_to_L.palmer_distances); % x values are dist_to_L.l_shells

% figure;
% plot(dist_to_L.l_shells, interp1(fwm.xkm, B_gnd_db, dist_to_L.palmer_distances))

%% Get Palmer data availability and determine SM coordinates
% DG = load(fullfile(danmatlabroot, 'vlf', 'emission_statistics', 'data_gaps.mat'));
% synoptic_epochs = DG.synoptic_epochs(DG.b_data);

DA = load(fullfile(danmatlabroot, 'vlf', 'alexandria_data_availability', 'palmer_data_availability.mat'));
MLT = fpart(DA.start_datenum)*24 + palmer_MLT_offset/24;

%% Set up bins
dL = 0.25;
L_edges = (1:dL:(L_max + dL)).';
MLT_edges = 0:24;
L_centers = L_edges(1:end-1) + diff(L_edges)/2;
MLT_centers = MLT_edges(1:end-1) + diff(MLT_edges)/2;


%% Weight the MLT bins
% Palmer can only see emission during local night (more-or-less)

% Weight each MLT bin by the fraction of the year that it's in darkness
date_vec = datenum([2010 01 01 0 0 0]):7:datenum([2011 01 00 0 0 0]);
MLT_weights = zeros(length(MLT_edges) - 1, 1);
for kk = 1:length(date_vec)
  [dawn_datenum(kk), dusk_datenum(kk)] = find_terminator(palmer_lat, palmer_lon, date_vec(kk));
  
  local_dawn_hour = fpart(dawn_datenum(kk) + palmer_MLT_offset/24);
  local_dusk_hour = fpart(dusk_datenum(kk) + palmer_MLT_offset/24);
  assert(local_dusk_hour > local_dawn_hour);
  
  idx_dark = MLT_centers/24 <= local_dawn_hour | MLT_centers/24 >= local_dusk_hour;
  
  MLT_weights(idx_dark) = MLT_weights(idx_dark) + 1/length(date_vec);
end

% The plot looks dumb and interpolation doesn't work right when some bins
% are zero
MLT_weights(MLT_weights == 0) = 1e-5;

%% Weight the L bins
L_weights = interp1(dist_to_L.l_shells, 10.^((db_vs_L - max(db_vs_L))/10), L_centers);

%% Distributed across L according to relative attenuation and plot
% Measurements are down the rows and different L-shells are across the
% columns
duration_mtx = repmat(DA.duration, 1, length(L_centers));

L_mtx = repmat(L_centers.', length(DA.duration), 1);
MLT_mtx = repmat(MLT, 1, length(L_centers));

plot_l_mlt(L_mtx(:), MLT_mtx(:), L_edges, MLT_edges, duration_mtx(:), ...
  'L_weights', L_weights, 'MLT_weights', MLT_weights, 'h_ax', h_ax);

if isempty(h_ax)
  c = colorbar;
  ylabel(c, 'log_{10} weighted seconds');
  title('Weighted Data Availability');

  increase_font;
end
