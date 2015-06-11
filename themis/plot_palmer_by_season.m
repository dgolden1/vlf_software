function plot_palmer_by_season(events)
% Plot a bunch of Palmer cumulative spectrograms by season
% Compliments plot_ephemeris_by_season.m

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
% load fullfile(vlfcasestudyroot, 'chorus_hiss_detection', 'databases', 'auto_chorus_hiss_db_em_char_all_reprocessed.mat');
% close all;

em_type = 'chorus';
% em_type = 'hiss';

addpath(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence')); % For find_terminator.m
addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics')); % For plot_cum_spec_v4.m, data_gaps.mat

dg = load('data_gaps.mat');
synoptic_epochs = dg.synoptic_epochs(dg.b_data);

month_doys = datenum([2001*ones(13, 1) (1:13).' ones(13, 1) zeros(13, 3)]).' - datenum([2001 0 0 0 0 0]);
month_names = datestr(datenum([2001 0 0 0 0 0]) + month_doys(1:end-1), 'mmm');
month_names = mat2cell(month_names, ones(12, 1), 3);

%% Parse out this emission type
events = events(strcmp({events.type}, em_type));

%% Plot
% Super Subplot parameters
hspace = 0.01;
vspace = 0.05;
hmargin = [0.08 0];
vmargin = [0.1 0.08];
figure;

switch em_type
  case 'chorus'
    f = linspace(400, 6e3, 64);
    freq_lines = (2:2:4)*1e3;
  case 'hiss'
    f = linspace(400, 3e3, 64);
    freq_lines = (1:2)*1e3;
end
df = diff(f(1:2));

[~, month] = datevec([events.start_datenum]);
[~, month_syn_epoch] = datevec(synoptic_epochs);
  
for kk = 1:12
%   start_datenum = datenum([2007 (kk-1)*3+11 1 0 0 0]);
%   end_datenum = datenum([2007 kk*3+11 1 0 0 0]);
%   idx = [events.start_datenum] >= start_datenum & [events.end_datenum] < end_datenum;
%   idx_synoptic_epoch = synoptic_epochs >= start_datenum & synoptic_epochs < end_datenum;
%   term_date = mean(start_datenum, end_datenum);

  idx = month == kk;
  idx_synoptic_epoch = month_syn_epoch == kk;
  term_date = mean(datenum([2001 kk 01 0 0 0]), datenum([2001 kk+1 01 0 0 0]));

  these_events = events(idx);
  ec = [these_events.ec];
  
  if sum(idx) == 0
    continue;
  end
  
  ax = super_subplot(3, 4, kk, hspace, vspace, hmargin, vmargin);
  
  % Amplitudes are in dB-fT; change to dB-fT/Hz^(1/2) by dividing by
  % bandwidth
  ampl = 10*log10(10.^([ec.ampl_true]/10)./([these_events.f_uc] - [these_events.f_lc]));
  ampl_mtx = repmat(ampl, length(f), 1);
  f_mtx = repmat(f(:), 1, length(ampl));
  ampl_mtx(f_mtx < repmat([these_events.f_lc], length(f), 1) | f_mtx > repmat([these_events.f_uc], length(f), 1)) = -20;

  plot_cum_spec_v4(fpart([events(idx).start_datenum]), f, ampl_mtx, ...
    'norm_datenums', fpart(synoptic_epochs(idx_synoptic_epoch)), ...
    'mlt_offset', -4, 'min_img_val', -20, 'b_radial', true, ...
    'freq_lines', freq_lines, 'h_ax', ax);
  
  [dawn_datenum, dusk_datenum] = find_terminator(-64.77, -64.05, term_date);
  dawn_datenum = fpart(dawn_datenum - 4/24); % Convert to Palmer MLT
  dusk_datenum = fpart(dusk_datenum - 4/24); 
  
  r_min = 0.3;
  r_max = 1;
  plot([r_min, r_max].*cos(dawn_datenum*2*pi + pi), [r_min, r_max].*sin(dawn_datenum*2*pi + pi), '--', 'linewidth', 2, 'color', [.8 .7 0]); % Yellow
  plot([r_min, r_max].*cos(dusk_datenum*2*pi + pi), [r_min, r_max].*sin(dusk_datenum*2*pi + pi), '--', 'linewidth', 2, 'color', [.3 .6 1]); % Blue

  axes(ax);
  caxis([-20 -16]);

  colorbar off;
  if kk < 9
    xlabel('');
    set(gca, 'xticklabel', []);
  end
  if mod(kk-1, 4) ~= 0
    ylabel('');
    set(gca, 'yticklabel', []);
  end
  
%   title(sprintf('%s to %s', datestr(start_datenum, 29), datestr(end_datenum-1, 29)));
  title(sprintf(datestr([2001 kk 01 0 0 0], 'mmm')));
end
