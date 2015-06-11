function new_filenames = convert_interleaved_to_twochannel(input_filename, output_dir, station_code, which_channel)
% new_filenames = convert_interleaved_to_twochannel(input_filename, output_dir, station_code, num_channels)
% Function to convert interleaved broadband data to two-channel broadband
% data.
% 
% Station code is a 2-letter capital letter designation for the station
% (e.g., PA for Palmer). It is only used for the output filename.
% 
% which_channels can either be 'N/S' (even numbered channel), 'E/W' (odd
% numbered channel) or 'both' (default)
% 
% Generated N/S files end in _002.mat and generated E/W files end in
% _003.mat (the standard for synoptic data).

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

%% Error checking
if ~exist('num_channels', 'var') || isempty(num_channels)
	num_channels = 2;
end
if num_channels < 1 || num_channels > 2
	error('num_channels (%d) must be an integer between 1 and 2', num_channels);
end

if ~(length(station_code) == 2 && all(isstrprop(station_code, 'upper')))
	error('station_code must be a two letter upper case station code');
end

if ~exist('which_channel', 'var') || isempty(which_channel)
  which_channel = 'both';
end

%% Everything else
switch lower(which_channel)
  case 'n/s'
    channel_vec = 1;
  case 'e/w'
    channel_vec = 2;
  case 'both'
    channel_vec = [1 2];
  otherwise
    error('Weird channel: %s', which_channel);
end

s_old = matLoad(input_filename);
new_filenames = {};
for channel = channel_vec
	new_filenames{end+1} = save_channel(s_old, output_dir, station_code, channel);
end

if length(new_filenames) == 1
	new_filenames = new_filenames{1};
end

function new_filename = save_channel(s_old, output_dir, station_code, channel_num)

if channel_num == 1
	channel_suffix = '_002.mat';
elseif channel_num == 2
	channel_suffix = '_003.mat';
else
	error('Weird channel number (%d)', channel_num);
end

old_datenum = datenum([s_old.start_year s_old.start_month s_old.start_day ...
	s_old.start_hour s_old.start_minute s_old.start_second]);
% Old versions of Matlab switch the day and hour when datestringing
% yymmddHHMMSS!
output_filename = [station_code, datestr(old_datenum, 'yymmdd'), datestr(old_datenum, 'HHMMSS'), channel_suffix];

dms_ns = degrees2dms(s_old.antenna_latitude);
if dms_ns(1) < 0, NS = 'S'; else NS = 'N'; end
latitude = sprintf('%s %02dd%02d''%04.1f"', NS, abs(dms_ns(1)), dms_ns(2), dms_ns(3));
dms_ew = degrees2dms(s_old.antenna_longitude);
if dms_ew(1) < 0, EW = 'W'; else EW = 'E'; end

s.Fc = 0;
s.Fs = s_old.channel_sampling_freq(channel_num);
s.VERSION = 2009; % This version is 2009!
s.adc_channel_number = channel_num;
s.adc_sn = [];
s.adc_type = 'NI PCI_6034E';
s.altitude = s_old.antenna_altitude;
s.antenna_bearings = s_old.antenna_heading(channel_num);
s.antenna_description = '';
s.cal_factor = 1;
s.call_sign = [];
s.computer_sn = [];
s.filter_taps = [];
s.gps_quality = 'interleaved converted';
s.gps_sn = [];
s.hardware_description = '';
s.is_amp = [];
s.is_broadband = 1;
s.is_msk = 0;
s.latitude = sprintf('%s %02dd%02d''%04.1f"', NS, abs(dms_ns(1)), dms_ns(2), dms_ns(3));
s.longitude = sprintf('%s %02dd%02d''%04.1f"', EW, abs(dms_ew(1)), dms_ew(2), dms_ew(3));
s.start_day = s_old.start_day;
s.start_hour = s_old.start_hour;
s.start_minute = s_old.start_minute;
s.start_month = s_old.start_month;
s.start_second = s_old.start_second;
s.start_year = s_old.start_year;
s.station_description = char(s_old.comments.');
s.station_name = char(s_old.siteName.');

% Variables must be written explicitly, since Matlab is stupid and refuses to
% write int16 values to the version 4 format. Also, it writes text arrays
% as arrays of floats, which is wasteful and stupid
new_filename = fullfile(output_dir, output_filename);

write_twochannel_data(new_filename, s, s_old.data(channel_num:2:end))
