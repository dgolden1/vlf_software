function write_twochannel_data(filename, s, data)
% write_twochannel_data(filename, s, data)
% Function to write 2-channel data in Matlab version 4 file format in a
% manner similiar to - but not exactly the same as - the AWESOME receiver
% format. Some data types will be different than the AWESOME data and the
% order of variables in the binary file will be different. Variable names
% will be the same.
% 
% This function doesn't do any error checking. That's up to you!

% s is a struct with fields equal to the usual variable names as follows:
% s.Fc
% s.Fs
% s.VERSION
% s.adc_channel_number
% s.adc_sn
% s.adc_type
% s.altitude
% s.antenna_bearings
% s.antenna_description
% s.cal_factor
% s.call_sign
% s.computer_sn
% s.filter_taps
% s.gps_quality
% s.gps_sn
% s.hardware_description
% s.is_amp
% s.is_broadband
% s.is_msk
% s.latitude
% s.longitude
% s.start_day
% s.start_hour
% s.start_minute
% s.start_month
% s.start_second
% s.start_year
% s.station_description
% s.station_name
% 
% data is packaged separately

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Open file and errror checking
[fid, msg] = fopen(filename, 'w');
if fid < 1
	error('Unable to open %s for write: %s', filename, msg);
end

%% Write all variables except for data
s_names = fieldnames(s);

for kk = 1:length(s_names)
	% Don't write the data variable here
	if strcmp(s_names{kk}, 'data')
		continue;
	end
	
	var = s.(s_names{kk});
	vclass = class(var);
	
	% Ensure that text is stored as an unsigned char (Matlab loads the
	% characters as doubles)
	switch s_names{kk}
		case {'adc_type', 'gps_quality', 'latitude', 'longitude', 'station_description'}
			vclass = 'char';
	end
	
	switch vclass
		case 'char'
			varTypeCode = 50;
			varType = 'uchar';
		case 'double'
			if all(var == floor(var)) && all(abs(var) < intmax);
				varTypeCode = 20;
				varType = 'int32';
			else
				varTypeCode = 0;
				varType = 'double';
			end
		otherwise
			error('Unknown variable class ''%s''', vclass);
	end
	varRows = size(var, 1);
	varCols = size(var, 2);
	varImag = 0;
	varName = [s_names{kk} 0];
	varNameLength = length(s_names{kk}) + 1;
	fwrite(fid, [varTypeCode varRows varCols varImag varNameLength], 'int32');
	fwrite(fid, varName, 'uchar');
	fwrite(fid, var, varType);
end

%% Write data
varTypeCode = 30;
varRows = length(data);
varCols = 1;
varImag = 0;
varNameLength = 5;
varName = ['data' 0];
fwrite(fid, [varTypeCode varRows varCols varImag varNameLength], 'int32');
fwrite(fid, varName, 'uchar');
fwrite(fid, data, 'int16');

%% Clean up
fclose(fid);
