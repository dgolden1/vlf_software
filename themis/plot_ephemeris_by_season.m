function plot_ephemeris_by_season
% A simple script to plot THEMIS ephemeris by season to show how I'm
% screwed or not when computing Palmer statistics

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
% close all;

probes = {'A', 'B', 'C', 'D', 'E'};

L_edges = 2:0.25:10;
MLT_edges = 0:1:24;

%% Make plots
% Super Subplot parameters
hspace = 0.01;
vspace = 0.05;
hmargin = [0.08 0];
vmargin = [0.1 0.08];

figure;
for kk = 1:12
  start_datenum = datenum([2007 (kk-1)*3+11 1 0 0 0]);
  end_datenum = datenum([2007 kk*3+11 1 0 0 0]); 
  for jj = 1:length(probes)
    eph(jj) = get_ephemeris(probes{jj}, start_datenum, end_datenum);
%     idx = abs(eph(jj).lat) > 2; % Exclude magnetosonic waves near the equator
%     for name = fieldnames(eph)
%       eph(jj).(name{1}) = eph(jj).(name{1})(idx);
%     end
    
  end
  epoch = cell2mat({eph.epoch}.');
  L = cell2mat({eph.L}.');
  MLT = cell2mat({eph.MLT}.');
  
%   h = subplot(3, 4, kk);
  h = super_subplot(3, 4, kk, hspace, vspace, hmargin, vmargin);
  plot_l_mlt(L, MLT, L_edges, MLT_edges, 600, 'h_ax', h);

  if kk < 9
    xlabel('');
    set(gca, 'xticklabel', []);
  end
  if mod(kk-1, 4) ~= 0
    ylabel('');
    set(gca, 'yticklabel', []);
  end
  title(sprintf('%s to %s', datestr(start_datenum, 29), datestr(end_datenum-1, 29)));
end
