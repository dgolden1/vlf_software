function emission_file_converter(output_dir, input_dir, input_filenames, varargin)
% Used to convert from 3-minute synoptic interleaved files on Alexandria to
% 20-second AWESOME N/S channel files in a given directory
% 
% PARAMETERS
% b_is_interleaved: true if all files are interleaved; false if all files
% are two-channel files (required)
% start_sec: start_second of each file (default: 5)
% b_decimate: true (default) to decimate to fs = 20 kHz
% which_channel: 'N/S', 'E/W' or 'both' (default)
% station_code: two-letter station filename prefix (e.g., 'PA' for palmer)
%  (default: 'BB')

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Parse inputs
p = inputParser;
p.addRequired('b_is_interleaved');
p.addParamValue('start_sec', 5*ones(size(input_filenames)));
p.addParamValue('b_decimate', true);
p.addParamValue('which_channel', 'both');
p.addParamValue('station_code', 'BB');
p.parse(varargin{:});

b_is_interleaved = p.Results.b_is_interleaved;
start_sec = p.Results.start_sec;
b_decimate = p.Results.b_decimate;
which_channel = p.Results.which_channel;
station_code = p.Results.station_code;

%% Setup
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  %       case 'vlf-alexandria'
  %               output_dir = '/array/data_products/dgolden/output/xcorr_ga';
  case 'quadcoredan.stanford.edu'
    input_dir_default = '/media/vlf-alexandria-array/raw_data/broadband/palmer/2003';
    output_dir_default = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/test_cases/chorus_with_hiss';
  case 'polarbear'
    input_dir_default = '/media/vlf-alexandria-array/raw_data/broadband/palmer/2003';
    output_dir_default = '/home/dgolden1/output/';
  case 'vlf-alexandria'
    input_dir_default = '/array/raw_data/broadband/palmer/2003';
    ouput_dir_default = '/array/data_products/dgolden/output';
  otherwise
    input_dir_default = '';
    output_dir_default = '';
end

if ~exist('start_sec', 'var')
  start_sec = 5*ones(size(input_filenames));
end

if b_decimate
  f_uc = 10e3; % New upper cutoff frequency for subsampling, kHz (this is 1/2 the new Fs)
else
  f_uc = 50e3;
end

%% Parallel
% PARALLEL = true;
%
% if ~PARALLEL
%   warning('Parallel mode disabled!');
% end
%
% poolsize = matlabpool('size');
% if PARALLEL && poolsize == 0
%   matlabpool('open');
% end
% if ~PARALLEL && poolsize ~= 0
%   matlabpool('close');
% end

%% Select input files and output directory
if ~exist('output_dir', 'var') || isempty(output_dir)
  output_dir = uigetdir(output_dir_default, 'Choose output directory');
  if ~ischar(output_dir)
    return;
  end
end

if ~exist('input_filenames', 'var') || isempty(input_filenames)
  fprintf('No files to convert\n');
end

t_start = now;

%% Pare data
duration = 10;
new_suffix = '_pared';
b_use_newdate = true;
pared_filename = cell(size(input_filenames));
% warning('Parfor disabled!');
% for kk = 1:length(input_filenames)
parfor kk = 1:length(input_filenames)
  if isscalar(start_sec)
    this_start_sec = start_sec;
  else
    this_start_sec = start_sec(kk);
  end
  
  try
    pared_filename{kk} = copy_pared_data(fullfile(input_dir, input_filenames{kk}), output_dir, ...
      this_start_sec, duration, new_suffix, b_use_newdate, b_is_interleaved);
  catch er
    warning('Unable to pare %s: %s', input_filenames{kk}, er.message);
    continue;
  end
  [pathstr, name, ext] = fileparts(pared_filename{kk});
  %   disp(sprintf('Wrote pared file %s', [name ext]));
end
pared_filename(cellfun(@isempty, pared_filename)) = [];
if isempty(pared_filename)
  return;
end
disp('Wrote pared files');

%% Convert from interleaved to 2-channel
if b_is_interleaved
%   warning('Parfor disabled!');
%   for kk = 1:length(pared_filename)
  parfor kk = 1:length(pared_filename)
    awesome_filename{kk} = convert_interleaved_to_twochannel(pared_filename{kk}, ...
      output_dir, station_code, which_channel);
    [pathstr, name, ext] = fileparts(awesome_filename{kk});
    %   disp(sprintf('Wrote AWESOME file %s', [name ext]));
  end
  disp('Wrote AWESOME files');
else
  awesome_filename = pared_filename;
end

%% Subsample
if b_decimate
  new_suffix = '_ss';
  parfor kk = 1:length(awesome_filename)
    [fs_new, this_ss_filename] = subsample_resave_data(awesome_filename{kk}, output_dir, ...
      f_uc, new_suffix);
    ss_filename{kk} = this_ss_filename;
    %   disp(sprintf('Wrote subsampled file %s', just_filename(this_ss_filename)));
  end
  disp('Wrote subsampled files');
else
  ss_filename = awesome_filename;
end

%% Clean up
if b_is_interleaved
  for kk = 1:length(pared_filename)
    delete(pared_filename{kk});
    [pathstr, name, ext] = fileparts(pared_filename{kk});
    % disp(sprintf('Deleted %s', [name ext]));
  end
end
if b_decimate
  for kk = 1:length(awesome_filename)
    delete(awesome_filename{kk});
    [pathstr, name, ext] = fileparts(awesome_filename{kk});
    %  disp(sprintf('Deleted %s', [name ext]));
  end
end

disp('Deleted temporary files');

%% Create spectrograms
% startSec = 0;
% endSec = 20;
% bSavePlot = true;
% numRows = 1;
% f_lc = 0;
% bContSpec = true;
% bProc24 = false;
% dbOffset = 0;
% addpath(fullfile(danmatlabroot, 'vlf', 'vlftool_24_hour_fcn'));
% for kk = 1:length(ss_filename)
%   vlftoolfcn(ss_filename{kk}, startSec, endSec, bSavePlot, output_dir, numRows, f_uc, f_lc, bContSpec, bProc24, dbOffset);
% end

%% Finish
t_end = now;
% disp(sprintf('Finished file conversion in %s', time_elapsed(t_start, t_end)));
