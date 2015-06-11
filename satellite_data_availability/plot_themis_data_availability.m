function plot_themis_data_availability(varargin)
% Plot Themis ephemeris availability by L and MLT
% plot_themis_data_availability('param', value, ...)
% 
% PARAMETERS
% L_max: maximum L extent of plot (default: 6)
% probe: either a single probe (e.g., 'A'), a cell array of probes (e.g.,
% {'A', 'B', 'D'}, or 'all' (default)
% h_ax: an axis handles on which to put the plot

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
p = inputParser;
p.addParamValue('L_max', 6);
p.addParamValue('probe', 'all');
p.addParamValue('h_ax', []);
p.parse(varargin{:});
L_max = p.Results.L_max;
probe = p.Results.probe;
h_ax = p.Results.h_ax;


%% Load and transform ephemeris data
if iscell(probe)
  themis_id_list = probe;
elseif strcmp(probe, 'all')
	themis_id_list = {'A', 'B', 'C', 'D', 'E'};
else
  themis_id_list = {probe};
end

L = [];
MLT = [];
datenums = [];
for kk = 1:length(themis_id_list)
  eph(kk) = load(sprintf('/media/scott/spacecraft/themis/ephemeris/themis_%s_ephemeris_2007_02_27_2011_03_06.mat', ...
                         themis_id_list{kk}));

  L = [L; eph(kk).L];
  MLT = [MLT; eph(kk).MLT];
  datenums = [datenums; eph(kk).datenum];
end

dL = 0.25;
L_edges = (1:dL:(L_max + dL)).';
MLT_edges = (0:24).';

durations = median(diff(datenums))*86400; % Seconds

%% Plot ephemeris data
plot_l_mlt(L, MLT, L_edges, MLT_edges, durations, 'h_ax', h_ax);

probe_list_str = '';
for kk = 1:(length(themis_id_list) - 1)
  probe_list_str = [probe_list_str, themis_id_list{kk}, ', '];
end
probe_list_str = [probe_list_str, themis_id_list{end}];
if length(themis_id_list) == 1
  probe_str = 'Probe';
else
  probe_str = 'Probes';
end

if isempty(h_ax)
  c = colorbar;
  ylabel(c, 'log_{10} seconds');
  title(sprintf('THEMIS 2007-02-27 -- 2011-03-06 (%s %s)', probe_str, probe_list_str));

  increase_font;
end
