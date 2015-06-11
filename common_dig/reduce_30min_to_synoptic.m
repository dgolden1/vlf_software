function new_filelist = reduce_30min_to_synoptic(sourcedir, filenames, destdir, num_channels, syn_min, syn_len, yymmdd, b_remove_original)
% new_filelist = reduce_30min_to_synoptic(sourcedir, filenames, destdir, num_channels, syn_min, syn_len, yymmdd, b_remove_original)
% Function to take 30-minute continuous files from sourcedir, reduce them
% to a few seconds every 15 minutes (at 5, 20, 35 and 50 minutes) synoptic
% files, and copy them to the destination directory.
% 
% This is a shoehorn that will allow scripts that are meant for synoptic data to run on
% continous data.
% 
% INPUTS
% sourcedir: source directory containing continous data
% filenames: names of files in source directory to process.  If not specified,
%  other arguments are used to determine source files.
% destdir: destination directory for synoptic output
% num_channels: 2 to operate on N/S (000) and E/W (001) channels. 1 to
%  operate only on N/S channel
% syn_min: vector of synoptic minutes (e.g., [5 20 35 50]). Should be
%  sorted in ascending order
% syn_len: length of synoptic interval in seconds
% yymmdd: 3-element vector containing the specific year, month and day to
%  process; useful if multiple days reside in one folder
% b_remove_original: true to delete original continuous data files
% 
% Currently only works on non-interleaved data (filenames end with 000_mat
% or 001_mat)

% Dependencies:
% get_bb_fname_datenum
% copy_pared_data
% resizeData
% matGetEtc

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Setup
if ~exist('b_remove_original', 'var') || isempty(b_remove_original)
	b_remove_original = false;
end
if ~exist('yymmdd', 'var')
	yymmdd = '';
end
if b_remove_original
	b_remove_original = false;
	warning('b_remove_original not supported at this time');
end

fs = 1e5;

%% Get file list
if ~exist('filenames', 'var') || isempty(filenames)
  % Get directory listings
  d0 = dir(fullfile(sourcedir, '*_000.mat'));
  if num_channels == 2
  	d1 = dir(fullfile(sourcedir, '*_001.mat'));
  elseif num_channels == 1;
  	d1 = [];
  elseif num_channels ~= 1
  	error('num_channels (%d) must be 1 or 2', num_channels);
  end
  
  % Remove files that are missing from one or the other channel
  if num_channels == 2
  	d0 = remove_other_files(d1, d0);
  	d1 = remove_other_files(d0, d1);
  end
  
  d = [d0; d1];
  
  % Select a specific date
  if ~isempty(yymmdd)
    mask = false(size(d));
    for kk = 1:length(d)
      dateidx = strfind(d(kk).name,  datestr(datenum([yymmdd(1) yymmdd(2) yymmdd(3) 0 0 0]), 'yymmdd'));
      if ~isempty(dateidx) && dateidx(1) == 3
        mask(kk) = true;
      end
    end
    d = d(mask);
  end

  filenames = {d.name};
end

%% Run through files and run copy_pared_data on them in turn
new_filelist = {};
for kk = 1:length(filenames)
	full_filename = fullfile(sourcedir, filenames{kk});
    try
        [varNames,varTypes,varOffsets,varDimensions] = matGetVarInfo(full_filename);
    catch er
       disp(sprintf('Error reading %s: %s Skipping...', filenames{kk}, er.message));
       continue;
    end
	datadim = varDimensions(cellfun(@(x) ~isempty(x), strfind(varNames, 'data')), :); % Length of data in seconds
	if ~isvector(datadim)
		error('data variable is not a vector');
	end
	
	data_length_datenum = datenum([0 0 0 0 0 max(datadim)/fs]);
	data_start_datenum = get_bb_fname_datenum(full_filename);
	data_end_datenum = data_start_datenum + data_length_datenum;
	data_start_datevec = datevec(data_start_datenum);

	for ll = 1:length(syn_min)
		syn_start_datenum = datenum([data_start_datevec(1:4) syn_min(ll) 0]);
		
		% If the data file didn't start on the hour, this synoptic interval
		% data might be earlier than the start of the data; try the next
		% hour
		if syn_start_datenum < data_start_datenum, syn_start_datenum = syn_start_datenum + 1/24; end
		syn_end_datenum = syn_start_datenum + syn_len/86400;
		
		% Process the data if the data file contains this synoptic interval
		if syn_end_datenum <= data_end_datenum
			start_sec = round((syn_start_datenum - data_start_datenum)*86400);
			this_new_filelist = copy_pared_data(full_filename, destdir, start_sec, syn_len, '', true, false);
			if iscell(this_new_filelist)
				new_filelist{end+1} = this_new_filelist{1};
			else
				new_filelist{end+1} = this_new_filelist;
			end
		end
	end
end

disp('');

%% Function
function other_filelist = remove_other_files(source_filelist, other_filelist)
% Removes files from "other_filelist" that do not have files for the same
% time in "source_filelist" (to ensure that data isn't missing from two
% channel data, for example)

if isempty(source_filelist) || isempty(other_filelist)
	other_filelist = [];
	return;
end

if strfind(other_filelist(1).name, '_000.mat')
	suffix = '_000.mat';
elseif strfind(other_filelist(1).name, '_001.mat')
	suffix = '_001.mat';
end

mask = true(length(other_filelist), 1);
for kk = 1:length(other_filelist)
	prefix = strrep(other_filelist(kk).name, suffix, '');
	found = strfind({source_filelist.name}, prefix);
	if isempty(found)
		mask(kk) = false;
	end
end
other_filelist = other_filelist(mask);
