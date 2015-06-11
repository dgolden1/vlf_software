function bb = vlfExtractBB( pathname, filename, startSec, endSec, newvariables, bCombineChannels)
% IF newvariables == 1 THEN RETURNS A STRUCT WITH VARIABLES FROM VERSION 2005
% IF bCombineChannels == 1, then combines channels in a sum of squares sort
% of way

% Originally by Maria Spasojevic
% Modified by Daniel Golden (dgolden1 at stanford dot edu) 2008
% $Id$

%% Setup
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
if nargin < 6
  bCombineChannels = false;
end


matLoadExcept(fullfile(pathname, filename),'data');

% VERSION VARIABLE IS DIFFERENT IN DIFFERENT VERSIONS
if( exist( 'Version', 'var' ) )
  VERSION = Version;
elseif( exist( 'VERSION', 'var' ) )
  VERSION = VERSION;
else
  error('hhhmmm, where is the VERSION variable?');
end;

if(length(VERSION)>=4)
  VERSION=str2double(char(VERSION'));
end

%% Assign supporting variables
if VERSION >= 2005
  b_is_interlaced = false;
  
  % 	bb.Fc = Fc;
  bb.Fs = Fs;
  bb.VERSION = VERSION;
  bb.adc_channel_number = adc_channel_number;
  
  bb.adc_sn = adc_sn;
  bb.adc_type = adc_type;
  bb.altitude = altitude;
  bb.antenna_bearings = antenna_bearings;
  bb.antenna_description = antenna_description;
  bb.cal_factor = cal_factor;
  %   	bb.call_sign = call_sign;
  bb.computer_sn = computer_sn;
  %   	bb.filter_taps = filter_taps;
  bb.gps_quality =  gps_quality;
  bb.gps_sn = gps_sn;
  bb.hardware_description = hardware_description;
  %   	bb.is_amp = is_amp;
  bb.is_broadband = is_broadband;
  %   	bb.is_msk = is_msk;
  bb.latitude = latitude;
  bb.longitude = longitude;
  bb.start_day = start_day;
  bb.start_hour = start_hour;
  bb.start_minute = start_minute;
  bb.start_month = start_month;
  bb.start_second = start_second+startSec;
  bb.start_year = start_year;
  bb.station_description = char(station_description(:))';
  bb.station_name = strtok(char(station_name(:)'), '_');
  
  num_channels = 1;
  if( ~newvariables )
    % PUT IN SAME FORMAT AS PRE-2005 FILES
    tmp.startDate= datenum( start_year, start_month,  start_day, ...
      start_hour,  start_minute, start_second+startSec);
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
    tmp.comments = char(station_description(:)');
    tmp.site = char(station_name(:)');
    bb = tmp;
  end;
else
  b_is_interlaced = true;
  
  bb.startDate= datenum( start_year, start_month,  start_day, ...
    start_hour,  start_minute, start_second+startSec);
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
  bb.site=siteName;
  
  Fs = bb.sampleFrequency;
end;

% Get standardize pretty site name
[bb.site, bb.site_pretty] = standardize_sitename(bb.site);

startSample = num_channels * round( Fs * startSec );
endSample = num_channels * round( Fs * endSec );

%% Extract data
data = matGetVariable(fullfile(pathname, filename), 'data', ...
  endSample-startSample, startSample).';

if( ~isempty(data) )
  if b_is_interlaced
    if bCombineChannels
      bb.data(1,:) = vlfGetCombinedData(num_channels, data, ...
        fullfile(pathname, filename), startSample, endSample);
    else
      [data1, data2] = vlfGetCombinedData(num_channels, data, ...
        fullfile(pathname, filename), startSample, endSample);
      bb.data(1,:) = data1;
      bb.data(2,:) = data2;
    end
  else
    bb.data = data;
  end
else
  bb.data = [];
end;
