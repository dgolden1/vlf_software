function process_multi_dirs_24(year)
% Make 24-hour plots on a bunch of folders
% $Id$

%% Setup

if ~exist('year', 'var') || isempty(year)
  year = 2001;
end


[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
	case 'vlf-alexandria'
		destinPath = '/home/dgolden/array_dgolden/output/synoptic_summary_plots';
		input_dir = sprintf('/array/raw_data/broadband/palmer/%04d', year);
	case 'quadcoredan.stanford.edu'
		destinPath = '~/temp/';
		input_dir = sprintf('/media/scott/user_data/dgolden/palmer_bb_cleaned/%04d', year);
	case 'scott.stanford.edu'
		destinPath = sprintf('/data/user_data/dgolden/synoptic_summary_plots/%04d', year);
		input_dir = sprintf('/data/user_data/dgolden/palmer_bb_cleaned/%04d', year);
	case 'amundsen.stanford.edu'
		destinPath = '/home/dgolden/output/synoptic_summary_plots';
		input_dir = sprintf('/home/dgolden/scott/user_data/dgolden/palmer_bb_cleaned/%04d', year);
	otherwise
		error('Unknown host (%s)', hostname(1:end-1));
end

%% Parallel
PARALLEL = true;

if ~PARALLEL
	warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
	matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
	matlabpool('close');
end

%% Load list of subdirectories
if ~exist('subdirs', 'var') || isempty(subdirs)
  if exist('process_multi_dirs_24_subdirs.txt', 'file')
    fid = fopen('process_multi_dirs_24_subdirs.txt', 'r');
    subdirs = textscan(fid, '%s');
    subdirs = subdirs{1};
  else
    % Process all subdirectories
    subdir_struct = dir(input_dir);

    % Remove non-directories and directories that start with '.'
    subdir_struct(~[subdir_struct.isdir] | cellfun(@(x) x(1) == '.', {subdir_struct.name})) = [];
    subdirs = {subdir_struct.name};

    fprintf('Processing all (%d) subdirectories in %s\n', length(subdirs), input_dir);
  end
end

%% Process
if ~exist(destinPath, 'dir')
  mkdir(destinPath);
end

t_net_start = now;
progress_temp_dirname = parfor_progress_init;
% warning('Parallel disabled!');
% for kk = 1:length(subdirs)
parfor kk = 1:length(subdirs)
	t_start = now;

  month = str2double(subdirs{kk}(1:2));
  day = str2double(subdirs{kk}(4:5));
  filename_img = fullfile(destinPath, sprintf('palmer_%04d%02d%02d.png', year, month, day));
  filename_spec_amp = fullfile(destinPath, 'spec_amps', sprintf('palmer_%04d%02d%02d.mat', year, month, day));

  if exist(filename_spec_amp, 'file')
	  iteration_number = parfor_progress_step(progress_temp_dirname, kk);
    fprintf('Output file %s exists (%d of %d); skipping...\n', filename_spec_amp, iteration_number, length(subdirs));
    continue;
  end

	process_single_subdir(subdirs{kk}, input_dir, destinPath);
	
	iteration_number = parfor_progress_step(progress_temp_dirname, kk);
	disp(sprintf('Processed folder %d of %d in %s', iteration_number, length(subdirs), time_elapsed(t_start, now)));
end
parfor_progress_cleanup(progress_temp_dirname);

disp(sprintf('Processing complete in %s', time_elapsed(t_net_start, now)));

function process_single_subdir(subdir, input_dir, destinPath)
if ~exist(fullfile(input_dir, subdir), 'dir')
	error('Directory ''%s'' does not exist', fullfile(input_dir, subdir));
end
d = dir(fullfile(input_dir, subdir));

mask = true(size(d));
filenames = {};
for jj = 1:length(d)
	[pathstr, name, ext] = fileparts(d(jj).name);
	if strcmpi(ext, '.mat')
		filenames{end+1} = fullfile(input_dir, subdir, [name ext]);
	end
end

if isempty(filenames)
	warning('Directory ''%s'' is empty', fullfile(input_dir, subdir));
	return;
end

filenames = prune_irregular_synoptic_files(filenames);

startSec = 5;
endSec = 10;
bSavePlot = true;
numRows = 1;
f_uc = 8e3;
f_lc = 300;
bContSpec = true;
bProc24 = true;
vlftoolfcn(filenames, startSec, endSec, bSavePlot, destinPath, numRows, f_uc, f_lc, bContSpec, bProc24);
