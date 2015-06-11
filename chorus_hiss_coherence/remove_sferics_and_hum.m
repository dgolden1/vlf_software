function output_filenames = remove_sferics_and_hum(output_dir, input_dir, input_filenames, station_name, cal_datenum, fs_dec, channel)
% Scripts to use Dan's sferic removal and Morris and Ryan's hum removal
% on a bunch of files and resave them
% 
% output_filenames = remove_sferics_and_hum(output_dir, input_dir, input_filenames, station_name, cal_datenum, fs_dec, channel)
% 
% input_filenames is a cell array of filenames

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

%% Setup
% addpath(fullfile(danmatlabroot, 'vlf', 'jeremie_sferic_removal'));
addpath(fullfile(danmatlabroot, 'vlf', 'sferic_removal'));
addpath(fullfile(danmatlabroot, 'vlf', 'humblaster'));

% Input and output directories
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'quadcoredan.stanford.edu'
    default_output_dir = '/home/dgolden/temp';
    default_input_dir = '/media/polarbear/input/palmer_2003_02_02_uncleaned/20sec_awesome';
  case 'polarbear'
    default_output_dir = '/home/dgolden1/output/palmer_2003_02_02_cleaned';
    default_input_dir = '/home/dgolden1/input/palmer_2003_02_02_uncleaned/20sec_awesome';
  otherwise
    default_output_dir = nan;
    default_input_dir = nan;
    % error('Unknown hostname %s', hostname(1:end-1));
end

if ~exist('output_dir', 'var') || isempty(output_dir)
  output_dir = default_output_dir;
end
if ~exist('input_dir', 'var') || isempty(output_dir)
  input_dir = default_input_dir;
end
if ~exist('fs_dec', 'var') || isempty(fs_dec)
  fs_dec = 20e3;
end

% Figure handles
s = [];

%% Parallel
% PARALLEL = true;
% poolsize = matlabpool('size');
% if PARALLEL && poolsize == 0
%   matlabpool('open');
% end
% if ~PARALLEL && poolsize ~= 0
%   matlabpool('close');
% end
% if ~PARALLEL
%   disp('Warning: PARALLEL is false');
% end

output_filenames = {};

%% Cycle through files
if ~exist('input_filenames', 'var') || isempty(input_filenames)
  fprintf('Processing all files in %s\n', input_dir);
  d = [dir(fullfile(input_dir, '*.mat')); dir(fullfile(input_dir, '*.MAT'))];
  input_filenames = {d.name};
end

% Decimation parameters
f_max = fs_dec/2; % Hz

% Sferic removal parameters can be different for different stations
switch station_name
  case 'southpole'
    sf_rem_thresh = 0.1;
  otherwise
    sf_rem_thresh = 0.01;
end
sf_rem_b_slowtail_filter = true;


% Spectrogram parameters
window = 1024;
noverlap = 512;
nfft = 1024;

for kk = 1:length(input_filenames)
  t_file_start = now;
  % disp(sprintf('Processing file %s', input_filenames{kk}));

  %% Load data
  file_struct = load(fullfile(input_dir, input_filenames{kk}));
  file_struct.data = file_struct.data - mean(file_struct.data );
  
  %% Massage the data before cleaning if it needs it
  data_massaged = massage_data(file_struct.data, file_struct.Fs, station_name, cal_datenum);

  HB = get_humblaster_parameters(station_name, cal_datenum);
  if HB.b_humblast
    num_subplots = 3;
  else
    num_subplots = 2;
  end


  %% Decimate
  bb_dec_factor = file_struct.Fs/fs_dec;
  if fpart(bb_dec_factor) ~= 0
    error('decimated sampling frequency (%0.2f Hz) must be a factor of original sampling frequency (%0.2f Hz)', ...
      fs_dec, file_struct.Fs);
  end
  data_dec = decimate(data_massaged, bb_dec_factor);
  fs_dec = file_struct.Fs/bb_dec_factor;

  % Spectrogram of original
  h = sfigure(1); clf; figure_grow(1);
  s(end+1) = subplot(num_subplots, 1, 1);
  spectrogram_cal(data_dec, window, noverlap, nfft, fs_dec, station_name, cal_datenum); xlabel('');
  title(sprintf('%s original', strrep(input_filenames{kk}, '_', '\_')));
  
  %% Sferic removal
  t_sferic_start = now;

  % Don't remove sferics unless the periodogram is a certain amount above
  % the mediogram (i.e., the signal has significant impulsive noise)
  % between 5 and 15 kHz
  window_imp = 2^nextpow2(fs_dec*0.002); % Make the window at least 2 ms
  [~, F, ~, P] = spectrogram_dan(data_dec, window_imp, window_imp/2, window_imp, fs_dec);
  s_periodogram = 10*log10(mean(P, 2));
  s_mediogram = 10*log10(median(P, 2));
  medio_perio_diff = s_periodogram(F > 5e3 & F < 15e3) - s_mediogram(F > 5e3 & F < 15e3);
  
  if mean(medio_perio_diff) >= 3 % threshold on "impulsiveness"
    if file_struct.Fs ~= 1e5
      error('Data fs (%0.0f) must be 100 kHz for sferic removal', file_struct.Fs/1e3);
    end

    % Find sferics in original (100 kHz sampled) data
    [t_imp_start, t_imp_end] = find_sferics(data_massaged, file_struct.Fs, sf_rem_thresh);
    
    % If we find impulses which are more than 100 ms long, or the median
    % distance between impulses is less than 10 ms, our threshold must
    % be too low.  Iteratively double it until we don't have that problem.
    find_sferics_count = 1;
    while ~isempty(t_imp_start) && (max(t_imp_end - t_imp_start) > 0.1 || median(diff(t_imp_start)) < 0.01)
      sf_rem_thresh = sf_rem_thresh*2;
      [t_imp_start, t_imp_end, det_sig, det_fs, det_thresh] = find_sferics(data_massaged, file_struct.Fs, sf_rem_thresh);
      find_sferics_count = find_sferics_count + 1;
    end

    % Remove sferics
    data_sf_cleaned = remove_sferics(data_dec, fs_dec, t_imp_start, t_imp_end, sf_rem_b_slowtail_filter);
  else
    data_sf_cleaned = remove_sferics(data_dec, fs_dec, [], [], sf_rem_b_slowtail_filter);
  end

%   fprintf('Cleaned sferics in %s\n', time_elapsed(t_sferic_start, now));

  % Spectrogram of sferic cleaned
  s(end+1) = subplot(num_subplots, 1, 2);
  spectrogram_cal(data_sf_cleaned, window, noverlap, nfft, fs_dec, station_name, cal_datenum); xlabel('');
  title(sprintf('%s sferic cleaned', strrep(input_filenames{kk}, '_', '\_')));
  
  %% Humstraction
%   t_start = now;
%  data_hum_cleaned = humstractor(data_sf_cleaned, fs_dec, 60, a, b, 0, 0);
%   t_total = now - t_start;
%   disp(sprintf('Pass 3: cleaned hum in %0.0f sec', t_total*86400));

  %% Humblasting
  t_humblast_start = now;
  
  if HB.b_humblast
    [data_hum_cleaned, UpsampledHumEstimate, HumFrequencies, HumMeanSquaredError] = ...
      HumBlaster(data_sf_cleaned, fs_dec, HB.EstimationHarmonicNumbers, HB.OptimizationHarmonicNumbers, HB.SubtractionHarmonicNumbers, HB.NominalHumFrequency, HB.EstimationSegmentLength, HB.LeastSquaresSegmentLength, HB.UseEstimation);
  else
    data_hum_cleaned = data_sf_cleaned;
  end
  
%   fprintf('Cleaned hum in %s\n', time_elapsed(t_humblast_start, now));

  % Spectrogram of hum cleaned
  if HB.b_humblast
    s(end+1) = subplot(num_subplots, 1, 3);
    spectrogram_cal(data_hum_cleaned, window, noverlap, nfft, fs_dec, station_name, cal_datenum);
    title(sprintf('%s hum cleaned', strrep(input_filenames{kk}, '_', '\_')));
  end
  
  linkaxes(s); s = [];
  increase_font;
  ylim([0 fs_dec/2]);
  
  %% Save output file
  % Increase figure size if we're plotting with -nodisplay
  if strcmp(get(gcf, 'XDisplay'), 'nodisplay')
    figure_grow(gcf, 1.4)
  end

  output_file_struct = file_struct;
  output_file_struct.Fs = fs_dec;
  
  % Save
  switch station_name
    case 'palmer'
      station_id = 'PA';
    case 'southpole'
      station_id = 'SP';
    otherwise
      station_id = input_filenames{kk}(1:2);
  end
  
  switch lower(channel)
    case 'n/s'
      channel_num = 0;
    case 'e/w'
      channel_num = 1;
    otherwise
      error('Invalid channel: %s', channel);
  end
  
  name = sprintf('%s_%04d_%02d_%02dT%02d%02d_%02d_%03d', station_id, file_struct.start_year, ...
    file_struct.start_month, file_struct.start_day, file_struct.start_hour, ...
    file_struct.start_minute, file_struct.start_second, channel_num);
  
  ext = '.mat';
  
  output_filenames{end+1} = fullfile(output_dir, [name '_cleaned' ext]);
  write_twochannel_data(output_filenames{end}, output_file_struct, data_hum_cleaned);
  t_file_end = now;
  % disp(sprintf('Wrote %s; cleaning took %s', just_filename(output_filenames{end}), time_elapsed(t_file_start, t_file_end)));
  
  %% Save output png
  print(h, '-dpng', fullfile(output_dir, [name '_cleaned_diff.png']));
end

function data_filtered = massage_data(raw_data, fs, station_name, data_datenum)
%% Function: massage_data
% Some data needs some additional preprocessing because it's so freaking noisy

switch station_name
  case 'southpole'
    if data_datenum >= datenum([2001 01 01 0 0 0]) && data_datenum < datenum([2002 01 01 0 0 0])
      % Create a mess of notch filters for the multitude of narrowband
      % interference in the south pole data
      fc = [9100, 13.15e3, 18.5e3, 20e3, 20.6e3, 21.6e3, 22.425e3, 22.625e3];
      bw = [200, 150, 200, 300, 200, 300, 100, 150];
      Astops = [5 5 5 5 5 5 5 5]; % Minimum attenuation in dB; this may be overridden if the bandwidth is tight

      filters = {};
      for kk = 1:length(fc)
        bw_pass = bw(kk)*1.5;
        Fpass1 = fc(kk) - bw_pass/2;
        Fstop1 = fc(kk) - bw(kk)/2;
        Fstop2 = fc(kk) + bw(kk)/2;
        Fpass2 = fc(kk) + bw_pass/2;
        Astop = Astops(kk);
        Apass = 1;

        h = fdesign.bandstop('fp1,fst1,fst2,fp2,ap1,ast,ap2', Fpass1, Fstop1, ...
                             Fstop2, Fpass2, Apass, Astop, Apass, fs);
        Hd = design(h, 'butter', 'MatchExactly', 'stopband', 'SOSScaleNorm', 'Linf');

        filters{kk} = Hd;
      end

      % Construct a single cascaded filter
      Hd = dfilt.cascade(filters{:});

      data_filtered = filter(Hd, raw_data);
    else
      data_filtered = raw_data;
    end
  otherwise
    data_filtered = raw_data;
end

function HB = get_humblaster_parameters(station_name, data_datenum)

switch station_name
  case 'palmer'
    HB.b_humblast = true;
    HB.NominalHumFrequency = 60; % Hz
    HB.EstimationHarmonicNumbers = 7:2:31; % Harmonics to fix onto to estimate hum frequency if using Estimation method (not used) 
    HB.OptimizationHarmonicNumbers = 7:2:31; % Harmonics to fix onto to estimate hum frequency if using Optimization method
    HB.SubtractionHarmonicNumbers = 7:2:83; % Up to ~5 kHz
    HB.EstimationSegmentLength = 0.2; % Segment length if using estimation method (not used)
    HB.LeastSquaresSegmentLength = 0.2; % Segment length if using optimization method (I think)
    HB.UseEstimation = 1;
  case 'southpole'
    % I used to not humblast for data before 2003, but this was a mistake;
    % I was looking at the N/S spectrograms instead of the E/W
    % spectrograms, which are pretty much equally noise for all years... I
    % think
    % HB.b_humblast = true;
    HB.b_humblast = false;
    HB.NominalHumFrequency = 60; % Hz
    HB.EstimationHarmonicNumbers = 7:2:15;
    HB.OptimizationHarmonicNumbers = 7:2:15;
    HB.SubtractionHarmonicNumbers = 7:2:55;
    HB.EstimationSegmentLength = 0.2;
    HB.LeastSquaresSegmentLength = 0.2;
    HB.UseEstimation = 1;
end
