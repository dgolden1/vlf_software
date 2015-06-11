function sp_plot_cum_spec
% Main function to plot south pole cumulative spectrograms

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'vlf', 'emission_statistics')); % For plot_cum_spec_v4

load(fullfile(vlfcasestudyroot, 'southpole_emissions', 'nnet_output_2001_2008.mat'));

b_radial = true;

% create_one_cum_spec(chorus_datenums, chorus_f, input_datenums, 'Chorus', b_radial);
create_one_cum_spec(hiss_datenums, hiss_f, input_datenums, 'Hiss', b_radial);


function create_one_cum_spec(epoch, spec_f, input_datenums, em_type, b_radial)
%% Function: create a single cumulative spectrogram

% log_spec_dir = fullfile(scottdataroot, 'user_data', 'dgolden', 'southpole_bb_cleaned', 'southpole_log_specs');
load(fullfile(vlfcasestudyroot, 'southpole_emissions', 'log_mediograms.mat'), 'f', 'file_time', 's_mediogram');
DF.f = f;

%% Create columns
columns = zeros(100, length(epoch));
last_day = floor(epoch(1));
t_day_start = now;
for kk = 1:length(epoch)
  this_idx = abs(file_time - epoch(kk)) < 1/86400;
  assert(sum(this_idx) == 1);
  DF.s_mediogram = s_mediogram(:,this_idx);

  % Put this PSD within the appropriate frequency range into the column.
  % The rest of the column gets 0.
  idx_f = DF.f >= spec_f(1, kk) & DF.f <= spec_f(2, kk);
  columns(idx_f, kk) = DF.s_mediogram(idx_f);
  columns(~idx_f, kk) = nan;
%   columns(idx_f, kk) = 1; % For normalized occurrence only
  
  if floor(epoch(kk)) > last_day
    fprintf('Processed %s in %s\n', datestr(last_day, 'yyyy-mm-dd'), time_elapsed(t_day_start, now));
    last_day = floor(epoch(kk));
    t_day_start = now;
  end
end

%% Plot Cumulative Spectrogram
plot_cum_spec_v4(fpart(epoch), log10(f), columns, 'norm_datenums', input_datenums, 'b_radial', b_radial, 'mlt_offset', -3.5);
title(sprintf('South Pole %s Cumulative Spectrogram %s -- %s', em_type, datestr(floor(min(input_datenums)), 'yyyy-mm-dd'), datestr(floor(max(input_datenums)), 'yyyy-mm-dd')));
set(gcf, 'color', 'w');
c = colorbar;
ylabel(c, 'avg dB');
caxis([-20 -17]);
increase_font;

plot_f_lines(f);

1;
