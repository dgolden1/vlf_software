function whLoadData ( filename, pathname)
% used by the Plot Full Synoptic Data functionality

global DF

DF.bbrec.data = [];

matLoadExcept(fullfile(pathname, filename),'data');

%% VERSION VARIABLE IS DIFFERENT IN DIFFERENT VERSIONS
if( exist( 'Version', 'var' ) )
	VERSION = Version;
elseif( exist( 'VERSION', 'var' ) )
	VERSION = VERSION;
else
	disp('hhhmmm, where is the VERSION variable?');
end;

if( VERSION >= 2005 )

	DF.bbrec.Fc = Fc;
	DF.bbrec.Fs = Fs;
	DF.bbrec.VERSION = VERSION;
	DF.bbrec.adc_channel_number = adc_channel_number;

  	DF.bbrec.adc_sn = adc_sn;
  	DF.bbrec.adc_type = adc_type;
  	DF.bbrec.altitude = altitude; 
  	DF.bbrec.antenna_bearings = antenna_bearings;
  	DF.bbrec.antenna_description = antenna_description;
  	DF.bbrec.cal_factor = cal_factor;
  	DF.bbrec.call_sign = call_sign;
  	DF.bbrec.computer_sn = computer_sn;
  	DF.bbrec.filter_taps = filter_taps;
  	DF.bbrec.gps_quality =  gps_quality;
  	DF.bbrec.gps_sn = gps_sn;
  	DF.bbrec.hardware_description = hardware_description;
  	DF.bbrec.is_amp = is_amp;
  	DF.bbrec.is_broadband = is_broadband;
  	DF.bbrec.is_msk = is_msk;
  	DF.bbrec.latitude = latitude;
  	DF.bbrec.longitude = longitude;
  	DF.bbrec.start_day = start_day;
  	DF.bbrec.start_hour = start_hour;
  	DF.bbrec.start_minute = start_minute;
  	DF.bbrec.start_month = start_month;
  	DF.bbrec.start_second = start_second+startSec;
  	DF.bbrec.start_year = start_year;
  	DF.bbrec.station_description = char(station_description');
  	DF.bbrec.station_name = strtok(char(station_name), '_');

	num_channels = 1;
	if( ~newvariables )
		% PUT IN SAME FORMAT AS PRE-2005 FILES
		tmp.startDate= datenum( start_year, start_month,  start_day, ...
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
		DF.bbrec = tmp;
	end;
else

	DF.bbrec.startDate= datenum( start_year, start_month,  start_day, ...
		start_hour,  start_minute, start_second);
	DF.bbrec.nChannels=num_channels;
	DF.bbrec.channelSequence=channel_sequence';
	DF.bbrec.sampleFrequency=channel_sampling_freq(1); 
	DF.bbrec.ADgains=channel_gain';
	DF.bbrec.location.altitude=antenna_altitude;
	DF.bbrec.antennaHeadings=antenna_heading';
	DF.bbrec.location.latitude=antenna_latitude;
	DF.bbrec.location.longitude=antenna_longitude;
	DF.bbrec.channelOffset_ns=time_diff_ns;
	DF.bbrec.version=Version; 
	DF.bbrec.comments=char(comments)';
 	DF.bbrec.site=(strtok(siteName,'_'));

	Fs = DF.bbrec.sampleFrequency;
end;

dataloc = fullfile(pathname, filename);
%load( dataloc, 'data');
varData = matGetVariableInfo(dataloc,'data');

startSec = 0;
endSec = startSec + str2num(get(findobj('Tag','lengthData'),'string'));

numSecs = varData{2}(1)/DF.bbrec.sampleFrequency/num_channels;
plotLength = str2num(get(findobj('Tag','lengthData'),'string'));
startTime = DF.bbrec.startDate;

k=1;
for m=1:floor(numSecs/plotLength)
    vlfNewFigure( 'bbfig1' );
    
    startSample = DF.bbrec.nChannels*round( DF.bbrec.sampleFrequency * startSec );
    endSample = DF.bbrec.nChannels*round( DF.bbrec.sampleFrequency * endSec );
    
    seconds = num2str(mod(startSec,60));
    minutes = floor(startSec/60);
    tempdate = datestr(startTime,0);
    minutes = num2str(minutes + str2num(tempdate(end-4:end-3)));
    if (length(seconds)<2) seconds = ['0' seconds];end
    if (length(minutes)<2) minutes = ['0' minutes];end
    tempdate(end-4:end-3) = minutes;
    tempdate(end-1:end) = seconds;
    DF.bbrec.startDate = datenum(tempdate);
    
    iiCol = k;

    if( DF.calcPSD )
        disp('----- calcPSD');
        [p, f] = vlfCalcPSD;
        DF.VLF.UT = [DF.VLF.UT DF.bbrec.startDate];
        DF.VLF.freq = f;
        DF.VLF.psd = [DF.VLF.psd p];
    end;
    
    partial_data = matGetVariable(dataloc,'data',endSample-startSample,startSample);
    
    for( n = 1:num_channels )
       DF.bbrec.data(n,:) = partial_data(n:num_channels:end)';
    end;

    vlfPlotSpecgram( 1, iiCol);

    if( DF.numRows > 1 )
        vlfPlotSpecgram( 2, iiCol);
    end;

    if( k == 1 )
        [y,mo,d,h,mi,s] = datevec(DF.bbrec.startDate);
        yyyy = datestr( DF.bbrec.startDate, 'yyyy');
        mm = datestr( DF.bbrec.startDate, 'mm');
        mmm = datestr( DF.bbrec.startDate, 'mmm');
        dd = datestr( DF.bbrec.startDate, 'dd');
        hh = datestr( DF.bbrec.startDate, 'HH');
        MM = datestr( DF.bbrec.startDate, 'MM');

        set(DF.fig, 'Name', [yyyy mm dd]);
        if( DF.numPlots == 1 )
            saveName = [lower(DF.bbrec.site) '_' yyyy mm dd '_' ...
                hh MM ];
        else
            saveName = [lower(DF.bbrec.site) '_' yyyy mm dd '_' ...
                hh '-'];
        end;
        doy = jday(DF.bbrec.startDate);

        h_t = axes( 'Pos', [DF.titleX  DF.titleY 0.001 0.001]);
        set(h_t, 'Visible', 'off');
        titlestr = [DF.bbrec.site '   ' yyyy ' ' mmm ' ' dd ...
            ' (Day ' doy ')   ' ...
            num2str( endSec - startSec ) ' sec snapshots'];
        text(0, 0, titlestr, 'Horiz', 'center');
    end;

    if( DF.numPlots > 1 )
        hh = datestr( DF.bbrec.startDate, 'HH');
        saveName =  [saveName hh];
    end;
    
    saveName(end-1:end) = minutes;
    DF.saveName = [saveName seconds];

    if( DF.savePlot == 1 )
        vlfSavePlot;
    end;
    startSec = endSec;
    endSec = endSec + plotLength;
end


clear DF.bbrec.data
DF.bbrec.data = [];
%  else
%     startSample = num_channels * round( Fs * startSec );
%     endSample = num_channels * round( Fs * endSec );

%     interlacedData = matGetVariable(fullfile(pathname, filename), 'data', ...
%          endSample-startSample, startSample);
% 
%     for( k = 1:num_channels )
%        bb.data(k,:) = interlacedData(k:num_channels:end)';
%     end;
% end
