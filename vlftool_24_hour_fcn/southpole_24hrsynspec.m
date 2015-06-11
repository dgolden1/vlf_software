function southpole_24hrsynspec(yyyy_mm_dd, synop_source_path, destin_path)
% southpole_24hrsynspec(yyyy_mm_dd, synop_source_path,
% destin_path)
% Script to make a 24-hour synoptic spectrogram from synoptic data at the
% south pole
% 
% yyyy_mm_dd is a 3-element vector (e.g., [2008 01 12] for Jan 12, 2008).
% If left blank, it defaults to floor(now - 1.25).

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Setup
global DF;
vlfDefaults;

if ~exist('destin_path', 'var')
	synop_source_path = 'c:\VLF_DAQ_DISTRO\Synoptic';
	destin_path = 'c:\VLF_DAQ_DISTRO\Spectrogram\24hour\upload';
end

if ~exist('yyyy_mm_dd', 'var') || isempty(yyyy_mm_dd)
	% yyyy_mm_dd = [2009 05 21];
	yyyy_mm_dd = datevec(floor(now - 1.25)); % If before 6 am, two days ago.  Otherwise, yesterday.
end
yyyy_mm_dd = yyyy_mm_dd(1:3);
start_datenum = datenum([yyyy_mm_dd 0 0 0]);

%% Process
% Get list of files for this day
if isunix
  d = [dir(fullfile(synop_source_path, '*.mat')); dir(fullfile(synop_source_path, '*.MAT'))];
else
  d = dir(fullfile(synop_source_path, '*.mat'));
end

bb_start_datenum = zeros(size(d));
for kk = 1:length(d)
  bb_start_datenum(kk) = get_bb_fname_datenum(fullfile(synop_source_path, d(kk).name), true);
end

d = d(bb_start_datenum >= start_datenum & bb_start_datenum < start_datenum + 1);
if isempty(d)
  error('No files found in %s for %s', synop_source_path, datestr(start_datenum, 31));
end

%% Get synoptic offsets into files
start_sec = 0; % Seconds after the synoptic epoch
duration = 5;
[filenames_out, file_offsets, channel_out] = get_synoptic_offsets('pathname', synop_source_path, ...
  'filenames_in', {d.name}, 'start_sec', start_sec, 'duration', duration);

%% Run the processing on the newly-created synoptic files
t_start = now;
fprintf('Creating synoptic spectrogram from %d files from %s\n', length(filenames_out), datestr(start_datenum, 31));

DF.VLF.UT = [];
DF.VLF.freq = [];
DF.VLF.psd = [];
% full_filenames = cellfun(@(x) fullfile(synop_source_path, x), filenames_out, 'uniformoutput', false);

idx = mod(channel_out, 2) == 1; % N/S channel
full_filenames = filenames_out(idx);
startSec = file_offsets(idx); % Seconds after the beginning of the file

endSec = startSec + duration;
bSavePlot = true;
numRows = 2;
f_uc = [40e3 10e3];
f_lc = [300 300];
bContSpec = false;
bProc24 = true;
dbOffset = 0;

vlftoolfcn(full_filenames, startSec, endSec, bSavePlot, destin_path, numRows, f_uc, f_lc, bContSpec, bProc24, dbOffset);
% increase_font(gcf, 14);
% vlf_process_24_dan(full_filenames, destin_path);

t_end = now;
fprintf('Processing completed in %0.0f seconds\n', (t_end - t_start)*86400);
