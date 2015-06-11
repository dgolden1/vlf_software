function bb = vlfExtractBB( pathname, filename, startSec, endSec, newvariables)

% File modified by Daniel Golden (dgolden1 at stanford dot edu) August 2007

% $Id$

% IF newvariables == 1 THEN RETURNS A STRUCT WITH VARIABLES FROM VERSION 2005

if nargin < 2,
   [filename,pathname] = uigetfile('*.mat', 'Choose a BB file to load');
end
if nargin < 3,
   startSec =0;
end
if nargin < 4,
   endSec=inf;
end

if( nargin < 5 )
	newvariables = 0;
end;


matLoadExcept(fullfile(pathname, filename),'data');

% VERSION VARIABLE IS DIFFERENT IN DIFFERENT VERSIONS
if( exist( 'Version', 'var' ) )
	VERSION = Version;
elseif( exist( 'VERSION', 'var' ) )
	VERSION = VERSION;
else
	disp('hhhmmm, where is the VERSION variable?');
end;

if( VERSION >= 2005 )

	bb.Fc = Fc;
	bb.Fs = Fs;
	bb.VERSION = VERSION;
	bb.adc_channel_number = adc_channel_number;

  	bb.adc_sn = adc_sn;
  	bb.adc_type = adc_type;
  	bb.altitude = altitude; 
  	bb.antenna_bearings = antenna_bearings;
  	bb.antenna_description = antenna_description;
  	bb.cal_factor = cal_factor;
  	bb.call_sign = call_sign;
  	bb.computer_sn = computer_sn;
  	bb.filter_taps = filter_taps;
  	bb.gps_quality =  gps_quality;
  	bb.gps_sn = gps_sn;
  	bb.hardware_description = hardware_description;
  	bb.is_amp = is_amp;
  	bb.is_broadband = is_broadband;
  	bb.is_msk = is_msk;
  	bb.latitude = latitude;
  	bb.longitude = longitude;
  	bb.start_day = start_day;
  	bb.start_hour = start_hour;
  	bb.start_minute = start_minute;
  	bb.start_month = start_month;
  	bb.start_second = start_second+startSec;
  	bb.start_year = start_year;
  	bb.station_description = char(station_description');
  	bb.station_name = strtok(char(station_name), '_');

	num_channels = 1;
	if( ~newvariables )
		% PUT IN SAME FORMAT AS PRE-2005 FILES
		tmp.startDate= datenum( start_year, start_month,  start_day, ...
			start_hour,  start_minute, start_second+startSec);
        tmp.startFileDate = datenum( start_year, start_month,  start_day, ...
			start_hour,  start_minute, start_second);
		tmp.nChannels = 1;
		tmp.channelSequence = 1;
		tmp.sampleFrequency = Fs;
		tmp.ADgains = -1;
		tmp.location.altitude = -1;
		tmp.location.latitude = longitude;
		tmp.location.longitude = latitude;
		tmp.antennaHeadings = antenna_bearings;
		tmp.channelOffset_ns = -1;
		tmp.version = VERSION; 
		tmp.comments = char(station_description');
		tmp.site = strtok(char(station_name), '_');
		bb = tmp;
	end;
else

	bb.startDate= datenum( start_year, start_month,  start_day, ...
		start_hour,  start_minute, start_second+startSec);
    bb.startFileDate = datenum( start_year, start_month,  start_day, ...
		start_hour,  start_minute, start_second);
	bb.nChannels=num_channels;
	bb.channelSequence=channel_sequence';
	bb.sampleFrequency=channel_sampling_freq(1); 
	bb.ADgains=channel_gain';
	bb.location.altitude=antenna_altitude;
	bb.antennaHeadings=antenna_heading';
	bb.location.latitude=antenna_latitude;
	bb.location.longitude=antenna_longitude;
	bb.channelOffset_ns=time_diff_ns;
	bb.version=Version; 
	bb.comments=char(comments)';
 	bb.site=(strtok(siteName,'_'));

	Fs = bb.sampleFrequency;
end;


startSample = num_channels * round( Fs * startSec );
endSample = num_channels * round( Fs * endSec );

interlacedData = matGetVariable(fullfile(pathname, filename), 'data', ...
     endSample-startSample, startSample);

for( k = 1:num_channels )
   bb.data(k,:) = interlacedData(k:num_channels:end)';
end;

