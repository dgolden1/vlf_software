function [bb_start_datenum, bb_end_datenum, station_id, channel] = get_bb_fname_datenum(bb_filename, b_use_filename)
% [bb_start_datenum, bb_end_datenum, station_id, channel] = get_bb_fname_datenum(bb_filename, b_use_filename)
% Parse a broadband filename to get its date
% 
% If b_use_filename is true (default), the date is gleaned from the file
% name. Otherwise, the date is gleaned from the "start_year" etc variables
% within the file.
% 
% bb_end_datenum is only available when b_use_filename is false
% 
% If b_use_filename is true and the filename is not in a valid format, the
% returned date is NaN
% 
% channel is 0 (N/S), 1 (E/W) or -1 (interleaved)

% By Daniel Golden (dgolden1 at stanford dot edu) Dec 2008
% $Id$

if ~exist('b_use_filename', 'var') || isempty(b_use_filename)
	b_use_filename = true;
end

% Accept multiple filename inputs
if ~iscell(bb_filename)
	bb_filename = {bb_filename};
end
bb_start_datenum = nan(size(bb_filename));
bb_end_datenum = nan(size(bb_filename));
station_id = cell(size(bb_filename));
channel = nan(size(bb_filename));

for kk = 1:length(bb_filename)
	if ~b_use_filename
		[fid, msg] = fopen(bb_filename{kk}, 'r');
		if fid < 1
			error(msg);
		end
		
		vars = matLoadExcept(fid, 'data');
		
		% Start datenum
		bb_start_datenum(kk) = datenum([vars.start_year, vars.start_month, vars.start_day, ...
			vars.start_hour, vars.start_minute, vars.start_second]);

		% Station
    [blah, name] = fileparts(bb_filename{kk});
    if ischar(name(1:2))
      station_id{kk} = upper(name(1:2));
    else
      station_id{kk} = 'BB';
    end

		% Channel
    if isfield(vars, 'adc_channel_number')
      channel(kk) = vars.adc_channel_number;
    else
			% This is an interleaved file
      channel(kk) = -1;
    end
    
		% Get sampling frequency
		if isfield(vars, 'Fs')
			fs = vars.Fs;
			b_is_interleaved = false;
		elseif isfield(vars, 'channel_sampling_freq')
			fs = vars.channel_sampling_freq;
			b_is_interleaved = true;
		else
			error('Unable to get fs from %s', filenames_in{kk});
		end

		% Get length of data variable
		[varNames, junk, junk, varDimensions] = matGetVarInfo(fid);
		data_dims = varDimensions(strcmp(varNames, 'data'), :);
		if min(data_dims) ~= 1
			error('data variable in %s has weird dimensions (%dx%d)', bb_filename{kk}, data_dims);
		end
		if b_is_interleaved
			file_length_sec = max(data_dims)/fs(1)/2;
		else
			file_length_sec = max(data_dims)/fs;
		end

		bb_end_datenum(kk) = bb_start_datenum(kk) + file_length_sec/86400;

		fclose(fid);
	else
		assert(~isempty(bb_filename{kk}));

		year = 0;
		month = 0;
		day = 0;
		sec = 0;

		channel(kk) = nan;

		[pathstr, name, ext] = fileparts(bb_filename{kk});
		
		% BBHHMMSS.mat or BBHHMM.mat (older pre-awesome format)
		if ~isempty(regexpi(name, '^[a-z]{2}[0-9]{4}$')) || ~isempty(regexpi(name, '^[a-z]{2}[0-9]{6}$'))
			station_id{kk} = upper(name(1:2));
			hour = str2double(name(3:4));
			minute = str2double(name(5:6));
			
			if length(name) == 8 % BBHHMMSS.mat
				sec = str2double(name(7:8));
			elseif length(name) ~= 6
				error('Weird file name length (%d)', length(name));
			end
			
			% Try to get the year, month and day from the path; if this
			% fails, they'll stay set to 0
			if ~isempty(pathstr)
				[pathstr1, MM_DD] = fileparts(pathstr);
				[junk, YYYY] = fileparts(pathstr1);
				if ~isempty(MM_DD) && ~isempty(regexp(MM_DD, '^\d{2}_\d{2}$', 'once')) && ...
						~isempty(YYYY) && ~isempty(regexp(YYYY, '^\d{4}$', 'once'))
					month = str2double(MM_DD(1:2));
					day = str2double(MM_DD(4:5));
					year = str2double(YYYY);
				end
      end
      
      channel(kk) = -1;
			
		% NNYYMMDDHHMMSS_CCC.mat (newer awesome format)
    % Second letter of station_id is sometimes a number, e.g., southpole = S1
		elseif ~isempty(regexpi(name, '^[a-z][a-z0-9][0-9]{12}_[0-9]{3}$'))
			station_id{kk} = upper(name(1:2));
			year = 2000 + str2double(name(3:4));
			month = str2double(name(5:6));
			day = str2double(name(7:8));
			hour = str2double(name(9:10));
			minute = str2double(name(11:12));
			sec = str2double(name(13:14));

			if mod(str2double(name(16:18)), 2) == 0
				channel(kk) = 0; % N/S
			elseif mod(str2double(name(16:18)), 2) == 1
				channel(kk) = 1; % E/W
			else
				error('Weird channel designation (''%s'')', name(16:18));
			end
		% NN_YYYY_MM_DDTHHMM_SS_CCC_cleaned.mat (Dan's cleaned data format)
		elseif ~isempty(regexpi(name, '^[a-z]{2}_[0-9]{4}_[0-9]{2}_[0-9]{2}T[0-9]{4}_[0-9]{2}_[0-9]{3}_cleaned$'))
			station_id{kk} = upper(name(1:2));
			A = sscanf(name, '%*2c_%04d_%02d_%02dT%02d%02d_%02d_%03d_%*s');
			year = A(1);
			month = A(2);
			day = A(3);
			hour = A(4);
			minute = A(5);
			sec = A(6);
			
			channel = mod(A(7), 2);
		% NNYYMMDDHHMMSSNNN_CCCA (modern ~2004 awesome narrowband format)
		elseif ~isempty(regexpi(name, '^[a-z]{2}[0-9]{12}[a-z]{3}_[0-9]{3}[a-z]$'))
			station_id{kk} = upper(name(1:2));
			year = 2000 + str2double(name(3:4));
			month = str2double(name(5:6));
			day = str2double(name(7:8));
			hour = str2double(name(9:10));
			minute = str2double(name(11:12));
			sec = str2double(name(13:14));
    end

    if year == 0
      bb_start_datenum(kk) = nan;
    else
      bb_start_datenum(kk) = datenum([year month day hour minute sec]);
    end
	end
end

if any(isnan(bb_start_datenum))
  nanidx = isnan(bb_start_datenum);
  if sum(nanidx) > 1
    error('Could not parse filename for more than one file');
  else
    error('Could not parse filename %s', bb_filename{nanidx});
  end
end

%% Output variables
if length(station_id) == 1
	station_id = station_id{1};
end
