function [bb_start_datenum, station, xmit, channel, type] = get_nb_fname_datenum(bb_filename)
% [bb_start_datenum, bb_end_datenum, station, channel] = get_bb_fname_datenum(bb_filename)
% Parse a broadband filename to get its date
% 
% If b_use_filename is true (default), the date is gleaned from the file
% name. Otherwise, the date is gleaned from the "start_year" etc variables
% within the file.
% 
% bb_end_datenum is only available when b_use_filename is false

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
station = cell(size(bb_filename));
channel = nan(size(bb_filename));

for kk = 1:length(bb_filename)
	if ~b_use_filename
		error('~b_use_filename not implemented');
	else
		assert(~isempty(bb_filename{kk}));

		year = 0;
		month = 0;
		day = 0;
		sec = 0;

		channel(kk) = nan;

		[pathstr, name, ext] = fileparts(bb_filename{kk});
		
		% NNYYMMDDHHMMSSNNN_CCCA (modern ~2004 awesome narrowband format)
		if ~isempty(regexpi(name, '^[a-z]{2}[0-9]{12}[a-z]{3}_[0-9]{3}[a-z]$'))
			station{kk} = upper(name(1:2));
			year = 2000 + str2double(name(3:4));
			month = str2double(name(5:6));
			day = str2double(name(7:8));
			hour = str2double(name(9:10));
			minute = str2double(name(11:12));
			sec = str2double(name(13:14));
			
			xmit_i_start = regexpi(name, '[a-z]+_[0-9]{3}[a-z]$');
			xmit_i_end = regexpi(name, '_[0-9]{3}[a-z]$') - 1;
			xmit = name(xmit_i_start:xmit_i_end);
			
			channel = str2double(name(xmit_i_end+2:xmit_i_end+4));
			switch name(xmit_i_end+5)
				case 'A'
					type = 'lowresampl';
				case 'B'
					type = 'lowresphase';
				case 'C'
					type = 'highresampl';
				case 'D'
					type = 'highresphase';
				otherwise
					error('Invalid type: %s', name(xmit_i_end+5));
			end
		else
			error('bb_fname_datenum:UnknownNameFmt', 'Unrecognized name format: ''%s''', [name ext]);
		end

		bb_start_datenum(kk) = datenum([year month day hour minute sec]);
	end
end

%% Output variables
if length(station) == 1
	station = station{1};
end
