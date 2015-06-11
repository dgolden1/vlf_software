function plot_chorus_superposed_cum_spec(min_dst_date, epoch_lims, varargin)
% plot_chorus_superposed_cum_spec(min_dst_date, epoch_lims, 'param', value)
% Plot chorus cumulative spectrogram superposed epoch
% 
% INPUTS
% min_dst_date: dates of the minimum Dst values; the epoch = 0 times
% epoch_lims: range of times with respect to the epoch to search (units of
% days).  E.g., to plot up to one day after the epoch and nothing before,
% set epoch_lims = [0 1]
% 
% PARAMETERS
% 'h_ax': axes on which to plot

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
t_net_start = now;

events = load_emissions;
events_start_datenum = [events.start_datenum];
DG = load(fullfile(danmatlabroot, 'vlf', 'emission_statistics', 'data_gaps.mat'));


%% Parse input arguments
p = inputParser;
p.addParamValue('h_ax', []);
p.parse(varargin{:});
h_ax = p.Results.h_ax;

%% Dependent Globals
AMPL_UNIT = 'dB-fT/Hz^{1/2}';

DB_MIN = -20; % dB-fT/Hz^{1/2}

%% Cycle through events and add them to the spectrogram
f = linspace(0, 10e3, 64);
t = (epoch_lims(1)*96:epoch_lims(2)*96)/96; % Fractions of a day
cum_spec = zeros(length(f), length(t));
count = zeros(size(cum_spec)); % Number of events in each bin (for normalization)

has_data = zeros(length(t), 1); % Add one for each epoch for which we have data at this t
total_events = 0;

for jj = 1:length(min_dst_date)
  dt = events_start_datenum - min_dst_date(jj);
  these_events = events(dt >= t(1) & dt <= t(end));
  
  if DG.synoptic_epochs(end) > min_dst_date(jj) + t(end)
    % Nearest synoptic epoch to this dst epoch (5, 20, 35, 50 minutes past
    % the hour)
    min_dst_date_on_syn_min = (round((min_dst_date(jj) - 5/1440)*96)/96) + 5/1440;

    % Range of synoptic epochs encompassing this dst epoch.  Add factors of
    % +/- 1/86400 to avoid rounding errors.
    data_avail_idx = DG.synoptic_epochs >= min_dst_date_on_syn_min + t(1) - 1/86400 & DG.synoptic_epochs <= min_dst_date_on_syn_min + t(end) + 1/86400;

    % Add one for each epoch for which we have data at this t
    has_data = has_data + double(DG.b_data(data_avail_idx));
  else
    break;
  end
  
  for kk = 1:length(these_events)
    this_event = these_events(kk);

    f_idx = f >= this_event.ec.f_lc & f <= this_event.ec.f_uc;
    t_idx = nearest(this_event.start_datenum - min_dst_date(jj), t);

    cum_spec(f_idx, t_idx) = cum_spec(f_idx, t_idx) + max(0, (this_event.ec.ampl_avg_medio - DB_MIN));
    count(f_idx, t_idx) = count(f_idx, t_idx) + 1;
    
    total_events = total_events + 1;

    % DEBUG
%     temp = zeros(size(cum_spec));
%     temp(f_idx, t_idx) = this_event.ec.ampl_avg_medio - DB_MIN;
%     imagesc(t, f, temp);
%     caxis([0 20]);
%     axis xy;
%     colorbar;
%     title(datestr(this_event.start_datenum));
%     drawnow;

  end
  
  % DEBUG
%   figure(1);
%   plot(t, has_data);
%   figure(2);
%   imagesc(t, f, cum_spec); axis xy;
%   title(sprintf('Epoch: %s', datestr(min_dst_date(jj))));
%   drawnow;
end

%% Normalize by data availability
cum_spec = cum_spec./repmat(has_data.', length(f), 1) + DB_MIN;

%% Plot spectrogram
if ~isempty(h_ax)
  saxes(h_ax);
else
  figure
end

imagesc(t*24, f/1000, cum_spec);
axis xy;
ylim([0.56 7]);


title('Superposed chorus');
xlabel('Hours from epoch');
ylabel('kHz');
  
c = colorbar;
set(get(c, 'ylabel'), 'string', ['avg ' AMPL_UNIT]);

set(gca, 'tickdir', 'out');
grid on;

if isempty(h_ax)
  increase_font(gcf);
  figure_grow(gcf, 1.3, 1);
end

%% Finish up

fprintf('Cumulative spectrogram created in %s\n', time_elapsed(t_net_start, now));
