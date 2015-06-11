function [epoch_out, data_out] = clean_dfb(epoch, data, b_decimate, instrument, b_ac)
% Clean DFB data by eliminating anomalies and dealing with noise floors
% 
% [epoch_out, data_out] = clean_dfb(epoch, data, b_decimate, instrument, b_ac)
% 
% This function will (a) eliminate high-amplitude anomalies, (b) eliminate
% any epochs where any of the channels are below their noise floor and (c)
% decimate the signal by a factor of 15, being sure not to smooth over
% (big) data gaps (if b_decimate is true)
% 
% The bottom three channels will be discarded, since I don't use them and
% I'm not going to spend time figuring out their properties

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
if ~exist('b_decimate', 'var') || isempty(b_decimate)
  b_decimate = false;
end

if strcmpi(instrument, 'scm')
  noise_floors = 10.^[-2.36, -2.96, -3.02]; % These are slightly above the noise floor, nT
  min_anomaly_thresh = 1; % data values larger than 1 nT are anomalous
elseif strcmpi(instrument, 'efi')
  noise_floors = [1 1 1]*0.0178; % Slightly above the noise floor, mV/m (-35 dB-mV/m)
  min_anomaly_thresh = 10; % data values larger than 10 mV/m are anomalous
else
  error('Unknown instrument %s', instrument);
end

%% Exclude samples where any channel is > 1 nT or <= 0
% idx_valid = all(data(:, 1:3) <= 1 & data(:, 1:3) > 0, 2);
% data_v1 = data(idx_valid, 1:3); % Ditch lower three channels
% epoch_v1 = epoch(idx_valid);

data = data(:,1:3); % Retain only upper 3 channels
if strcmpi(instrument, 'scm')
  % On the SCM, if the value goes way below the instrument noise floor,
  % it's due to an anomaly
  idx_anomaly = any(data(:, 1:3) > min_anomaly_thresh, 2) | data(:, 1) <= noise_floors(1)/2 | data(:, 2) <= noise_floors(2)/2 | data(:, 3) <= noise_floors(3)/2;
elseif strcmpi(instrument, 'efi')
  % On the EFI, if the value goes below the instrument noise floor, the
  % value is legit but constrained by the instrument resolution
  idx_anomaly = any(data(:, 1:3) > min_anomaly_thresh, 2);
end
epoch_anomaly = epoch(idx_anomaly);

% Edges of bins, where if an epoch is in a given bin, the nearest anomaly
% to that epoch is the anomaly corresponding to that bin
anomaly_edges = [min(epoch); epoch_anomaly(1:end-1) + diff(epoch_anomaly)/2; max(epoch)];
[~,bin] = histc(epoch, anomaly_edges);
assert(all(bin > 0));
bin(bin == length(anomaly_edges)) = length(anomaly_edges) - 1; % The last bin is values on the rightmost bin's right edge; put it IN the rightmost bin
dist_to_anomaly = abs(epoch - epoch_anomaly(bin));

% Remove data within 1 minute of anomalies
idx_valid = dist_to_anomaly >= 1/1440;

% EFI data between 2008-10-06 and 2008-10-17 is screwed up; the noise floor
% of all channels is really high for some reason
if strcmpi(instrument, 'efi')
  idx_valid(epoch >= datenum([2008 10 06 0 0 0]) & epoch < datenum([2008 10 17 0 0 0])) = false;
end

data_v1 = data(idx_valid, :);
epoch_v1 = epoch(idx_valid);

%% Decimate to reduce data volume
% We can't decimate over data gaps!  Then discontinuities in the values
% across the gaps get smeared over other values.

if b_decimate
  dec_factor = 15; % Samples are nominally 4 seconds apart; increase the inter-sample distance by this factor

  min_data_gap = 10/1440; % Minimum gap between samples to be considered a data gap (days)
  dg = find(diff(epoch_v1) > min_data_gap);

  data_smooth = cell(0, 3);
  epoch_smooth = cell(0, 1);
  for kk = 1:(length(dg)+1)
    % Indices into this continuous block
    if kk == 1
      this_idx = 1:dg(kk); % First block from index 1 to start of first gap
    elseif kk == length(dg) + 1
      this_idx = dg(kk-1)+1:length(epoch_v1); % Last block from end of last gap to index end
    else
      this_idx = dg(kk-1)+1:dg(kk); % Middle blocks from end of last gap to start of this gap
    end

    % Skip data segments with very few values
    if length(this_idx) < 24 % decimate says length must be > 24
      continue;
    end

    for jj = 1:3
      error('I should use a smoothing filter followed by subsampling; decimate introduces artifacts in |amplitude| data');
      data_smooth{end+1, jj} = decimate(data_v1(this_idx, jj), dec_factor);
    end
    epoch_smooth{end+1,1} = epoch_v1(this_idx(1:dec_factor:end));
  end

  data_out = abs(cell2mat(data_smooth));
  epoch_out = cell2mat(epoch_smooth);
else
  data_out = data_v1;
  epoch_out = epoch_v1;
end

%% Set values where any channel is below its noise floor to 0
% idx_any_below_floor = data_out(:, 1) <= noise_floors(1) | data_out(:, 2) <= noise_floors(2) | data_out(:, 3) <= noise_floors(3);
% data_out(idx_any_below_floor, :) = 0;

for kk = 1:3
  idx_below_floor = data_out(:, kk) <= noise_floors(kk);
  data_out(idx_below_floor, kk) = 0;
end

1;
