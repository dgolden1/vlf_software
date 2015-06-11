function plot_demeter_data_availability(L_max, h_ax)
% Plot Demeter ephemeris and burst mode availability by L and MLT
% 
% INPUTS
% L_max: maximum L extent of plot
% h_ax: an optional vectors of two axes handles on which to put the plots

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
if ~exist('L_max', 'var')
  L_max = 6;
end
if ~exist('h_ax', 'var')
  h_ax = {[], []};
else
  assert(length(h_ax) == 2);
  h_ax = num2cell(h_ax);
end

Re = 6371e3; % Earth radius (m)

%% Load and transform ephemeris data
eph = load('/media/scott/spacecraft/demeter/ephemeris/processed/demeter_ephemeris.mat');
dL = 0.25;
L_edges = (1:dL:(L_max + dL)).';
MLT_edges = (0:24).';

altitude = 690*1e3; % DEMETER altitude, meters

max_lat = 65; % Maximum invariant latitude of DEMETER survey data, degrees
max_L = 1/cos(max_lat*pi/180)^2; % Maximum L

eph.xyz_sm = onera_desp_lib_coord_trans([repmat(Re + altitude, length(eph.lat), 1), eph.lat, eph.lon], 'rll2sm', eph.datenum);
eph.MLT = mod(atan2(eph.xyz_sm(:,2), eph.xyz_sm(:,1))*24/(2*pi) + 12, 24);
eph.r = Re + altitude;
eph.L = eph.r./(1 - (eph.xyz_sm(:,3)./eph.r).^2)/Re;

b_survey = eph.L < max_L;

eph.durations = median(diff(eph.datenum))*86400; % Seconds

%% Plot survey mode data
plot_l_mlt(eph.L(b_survey), eph.MLT(b_survey), L_edges, MLT_edges, eph.durations, 'h_ax', h_ax{1});

if isempty(h_ax{1})
  c = colorbar;
  ylabel(c, 'log_{10} seconds');
  title('Demeter Survey Mode Availability');

  increase_font;
end

%% Load burst mode data
burst = load('/media/scott/spacecraft/demeter/ephemeris/processed/demeter_burst_mode_times.mat');

burst.MLT = interp1(eph.datenum, eph.MLT, burst.start_datenum);
burst.L = interp1(eph.datenum, eph.L, burst.start_datenum);
burst.durations = (burst.end_datenum - burst.start_datenum)*86400;

for fieldname = {'durations', 'L', 'MLT'}
  burst.(fieldname{1})(isnan(burst.MLT)) = [];
end

%% Plot burst mode data
plot_l_mlt(burst.L, burst.MLT, L_edges, MLT_edges, burst.durations, 'h_ax', h_ax{2});

if isempty(h_ax{2})
  c = colorbar;
  ylabel(c, 'log_{10} seconds');
  title('Demeter Burst Mode Availability');

  increase_font;
end
