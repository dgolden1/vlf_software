function varargout = vlf_spec(TypeOfData, JPEGLocation, fileName, db_low, db_high, f_high)
% total_time = vlf_spec(TypeOfData, JPEGLocation, fileName, db_low, db_high, f_high)
% Make a bunch of spectrograms of broadband data

% INPUTS
% TypeOfData:
%   0 -- Two channel AWESOME
%   1 -- Three channel AWESOME
%   2 -- Two channel interleaved
%   3 -- Two channel 12.5 kHz sampling interleaved
%   4 -- Three channel Buoy interleaved 100 kHz
%   5 -- Three channel Buoy interleaved 10 kHz
%   6 -- One channel Bloodhound data
%   7 -- The data that doesnt exist
%   8 -- Fraser-Smith McMurdo data
% JPEGLocation: directory string where the output products (JPEGs) will be saved
% fileName: a matlab string with the full path of the input file. If fileName is not
% specified, the user will be prompted to select a file.
% db_low: lower level of colorbar in dB
% db_high: higher level of colorbar in dB
% f_high: upper cutoff frequency (in kHz)
%
% OUTPUTS
% total_time: time in seconds that vlf_spec took to run
%
% vlf_spec*.mat;*.dat;*.raw
% Function originally by Morris Cohen
% Modified by Daniel Golden (dgolden1 at stanford dot edu) April 2007

% $Id$

%% Argument Wrangling
% All arguments are required
error(nargchk(2, 6, nargin));

if ~(TypeOfData >= 0 && TypeOfData <= 8)
  error('Invalid TypeOfData (%d).\nTypeOfData must be between 0 and 8 (inclusive)', ...
    TypeOfData);
end
if ~isstr(JPEGLocation) || isempty(JPEGLocation)
  error('Invalid JPEGLocation. JPEGLocation must be a valid Matlab string');
end

if ~exist('db_low', 'var') || isempty(db_low),  db_low = 35; end
if ~exist('db_high', 'var') || isempty(db_high), db_high = 70; end
if ~exist('f_high', 'var') || isempty(f_high), f_high = 8; end


%% More Setup

total_time = 0;

% 1 -- Time Series Plot, NS and EW
% 2 -- Specgram, NS and EW
% 3 -- FFT, NS and EW
% 4 -- X-Y plot
% 5 -- Combined specgram
% 6 -- Combined time series
FigureActivator = [0 1 0 0 0 0];

% 0 -- Standard spectrogram (style A)
% 1 -- Standard ELF spectrogram
% 2 -- Crazy-ass Mark style spectrogram (style C)
DisplayMode = 0;

ProcessEntireFile = 1;
SegmentLength = 60;
FileLength = 1800;  % in seconds

if DisplayMode == 0 % Standard spectrogram
  DownsampleFactor = round(50/f_high);
  WindowFactor = 3;  % default is ~10.24 ms (1024 samples at 100kHz)
  NFFTFactor = 1;  % default is window length
  OverlapFactor = 0;  % overlap between each window (usually 1/2).  Close to 1 means small increments for each window
  theta = pi/180*(0);
  Gain = 1;%10^(11.4/20);
  %     ColorbarMax = 70;
  %     ColorbarMin = 30;
  ColorbarMax = db_high;
  ColorbarMin = db_low;
  fc_low = 0E3;
  fc_high = 50E3;
  CleanTransmitters = 0;
  CleanHum = 0;
  CleanDCBias = 0;
elseif DisplayMode == 1
  DownsampleFactor = 3;
  WindowFactor = 8.00;
  NFFTFactor = 2;
  OverlapFactor = 3/4;
  theta = pi/180*(0);
  Gain = 1;%10^(11.4/20);
  ColorbarMax = 98;
  ColorbarMin = ColorbarMax-76;
  fc_low = 0E3;
  fc_high = 50E3;
  CleanTransmitters = 0;
  CleanHum = 0;
  CleanDCBias = 1;
elseif DisplayMode == 2
  DownsampleFactor = 8;
  WindowFactor = 16;
  NFFTFactor = 8;
  OverlapFactor = 1/2;
  theta = pi/180*(0);
  Gain = 1;%10^(11.4/20);
  ColorbarMax = 98;
  ColorbarMin = ColorbarMax-76;
  fc_low = 0E3;
  fc_high = 50E3;
  CleanTransmitters = 0;
  CleanHum = 0;
  CleanDCBias = 1;
else
  Error('Unrecognized Spectrogram Mode')
end

if ~exist('NumChannels', 'var')
  if TypeOfData == 1 || TypeOfData == 4 || TypeOfData == 5
    NumChannels = 3;
  elseif TypeOfData == 0 || TypeOfData == 2 || TypeOfData == 3 || TypeOfData == 8 %#ok<OR2>
    NumChannels = 2;
  else
    NumChannels = 1;
  end
end

if TypeOfData == 2 || TypeOfData == 3 || TypeOfData == 4 || TypeOfData == 5 || TypeOfData == 8
  interleaved = 1;
else
  interleaved = 0;
end

%% Pick Files if a file name wasn't supplied
if ~exist('fileName', 'var') || isempty(fileName)
  [filename0, pathname, filterindex] = uigetfile('*.mat;*.dat;*.raw', 'N/S filename');
  cd(pathname)
  if NumChannels > 1 && interleaved == 0
    [filename1, pathname, filterindex] = uigetfile('*.mat;*.dat;*.raw', 'E/W filename');
  end
  if NumChannels > 2 && interleaved == 0
    [filename2, pathname, filterindex] = uigetfile('*.mat;*.dat;*.raw', 'AUX filename');
  end
elseif TypeOfData == 2
  [pathname, name, ext, versn] = fileparts(fileName);
  cd(pathname)
  filename0 = [name ext];
else
  error(sprintf(['vlf_spec is not yet equipped to take file input for data other than\n' ...
    '100 kHz Palmer data. This is Dan Golden''s fault.'])); %#ok<SPERR>
end

%% Determine length of file to process

if ProcessEntireFile == 0
  length0 = input('Length of N/S spectrogram? ');
  offset0 = input('Offset from start of file in seconds of N/S spectrogram? ');
  if NumChannels > 1
    length1 = input('Length of E/W spectrogram? ');
    offset1 = input('Offset from start of file in seconds of E/W spectrogram? ');
  end
  if NumChannels > 2
    length2 = input('Length of AUX spectrogram? ');
    offset2 = input('Offset from start of file in seconds of AUX spectrogram? ');
  end
else
  length0 = SegmentLength;
  offset0 = 0;
  if NumChannels > 1
    length1 = SegmentLength;
    offset1 = 0;
  end
  if NumChannels > 2
    length2 = SegmentLength;
    offset2 = 0;
  end
end

%% Set sampling frequency

if TypeOfData == 4 || TypeOfData == 6
  channel_sampling_freq = 100000;
elseif TypeOfData == 3
  channel_sampling_freq = 12500;
elseif TypeOfData == 5
  channel_sampling_freq = 10000;
elseif TypeOfData == 7
  channel_sampling_freq = 50000;
elseif TypeOfData == 8
  channel_sampling_freq = matGetVariable(filename0,'channel_sampling_freq',1,0);
else
  % Sometimes the sampling frequency is 'Fs', sometimes it's 'channel_sampling_freq',
  % and sometimes it's something else, at which point we give up
  try
    channel_sampling_freq = matGetVariable(filename0,'Fs',1,0);
  catch
    s = lasterror;
    if strcmp(s.identifier, 'matGetVariable:varNotFound')
      channel_sampling_freq = matGetVariable(filename0,'channel_sampling_freq',1,0);
    else
      rethrow(s);
    end
  end
end
fclose all;

%% Determine length of data segment
fid = fopen(filename0, 'r');
[varNames,varTypes,varOffsets,varDimensions]=matGetVarInfo(fid);
data_index = find(strcmp(varNames, 'data'));
if isempty(data_index)
  error('data or sampling frequency variable does not exist');
end

data_length = max(varDimensions(data_index))/channel_sampling_freq;

% If the data length is less than what was specified, don't try to read
% past the end of it.
% We're assuming that this is interleaved data (so the real length is
% half of data_length)
FileLength = min(FileLength, data_length/2);


%% Do processing and spectrogram generation
KeepGoing = 1;
while KeepGoing == 1
  tic
  
  if ProcessEntireFile == 1 && offset0 > 0
    channel_sampling_freq = channel_sampling_freq*DownsampleFactor;
  end
  if TypeOfData <= 3 || TypeOfData == 8
    data_ns = matGetVariable(filename0, 'data',length0*(interleaved+1)*channel_sampling_freq, offset0*(interleaved+1)*channel_sampling_freq);
    fclose all;
    if NumChannels > 1 && interleaved == 0
      data_ew = matGetVariable(filename1, 'data',length1*(interleaved+1)*channel_sampling_freq, offset1*(interleaved+1)*channel_sampling_freq);
      fclose all;
    end
    if NumChannels > 2 && interleaved == 0
      data_aux = matGetVariable(filename2, 'data',length2*channel_sampling_freq, offset2*channel_sampling_freq);
    end
    if interleaved == 1 && TypeOfData ~= 8
      if NumChannels > 1
        data_ew = data_ns(2:(NumChannels):end);
      end
      if NumChannels > 2
        data_aux = data_ns(3:(NumChannels):end);
      end
      data_ns_temp = data_ns(1:(NumChannels):end);
      clear data_ns;
      data_ns = data_ns_temp;
      clear data_ns_temp;
    end
    if TypeOfData == 8
      Error('Not yet implemented')
    end
  elseif TypeOfData <= 5
    buoyfileid = fopen(fullfile(pathname, filename0), 'r');
    data_before = fread(buoyfileid, offset0*channel_sampling_freq*NumChannels, 'int16');
    data_all = fread(buoyfileid, length0*channel_sampling_freq*NumChannels, 'int16');
    fclose all;
    data_ns = data_all(1:3:end);
    data_ew = data_all(2:3:end);
    data_aux = data_all(3:3:end);
    clear data_all;
  elseif TypeOfData == 6
    bloodhoundfileid = fopen(fullfile(pathname, filename0), 'r');
    data_before = fread(bloodhoundfileid, offset0*channel_sampling_freq*NumChannels, 'int16', 'ieee-le');
    data_ns = fread(bloodhoundfileid, length0*channel_sampling_freq*NumChannels, 'int16', 'ieee-le');
    fclose all;
  elseif TypeOfData == 7
    bloodhoundfileid = fopen(fullfile(pathname, filename0), 'r');
    data_before = fread(bloodhoundfileid, offset0*channel_sampling_freq*NumChannels*2, 'int16', 'ieee-le');
    data_ns = fread(bloodhoundfileid, length0*channel_sampling_freq*NumChannels*2, 'int16', 'ieee-le');
    data_ns = data_ns(1:2:end);
  end
  
  if ProcessEntireFile == 1 && offset0 > 0
    channel_sampling_freq = channel_sampling_freq/DownsampleFactor;
  end
  
  if CleanDCBias == 1
    data_ns2 = data_ns - mean(data_ns);
    clear data_ns;
    data_ns = data_ns2;
    clear data_ns2;
    if NumChannels > 1
      data_ew2 = data_ew - mean(data_ew);
      clear data_ew;
      data_ew = data_ew2;
      clear data_ew2;
    end
    if NumChannels > 2
      data_aux2 = data_aux - mean(data_aux);
      clear data_aux;
      data_aux = data_aux2;
      clear data_aux2;
    end
  end
  
  if ProcessEntireFile ~= 1 || offset0 == 0
    Window = round(1024*WindowFactor/1E5*channel_sampling_freq/DownsampleFactor);
    NFFT = round(Window*NFFTFactor);
    Overlap = round(Window*OverlapFactor);
  end
  
  if DownsampleFactor ~= 1
    data_ns_downsampled = resample(data_ns,1,DownsampleFactor);
    clear data_ns;
    data_ns = data_ns_downsampled;
    clear data_ns_downsampled;
    if NumChannels > 1
      data_ew_downsampled = resample(data_ew,1,DownsampleFactor);
      clear data_ew;
      data_ew = data_ew_downsampled;
      clear data_ew_downsampled;
    end
    if NumChannels > 2
      data_aux_downsampled = resample(data_aux,1,DownsampleFactor);
      clear data_aux;
      data_aux = data_aux_downsampled;
      clear data_aux_downsampled;
    end
    if ProcessEntireFile ~= 1 || offset0 == 0
      channel_sampling_freq = channel_sampling_freq/DownsampleFactor;
    end
  end
  
  if theta ~= 0 && NumChannels > 1
    A = [cos(theta) sin(theta); -sin(theta) cos(theta)];
    data_rotated = A*[data_ns' ; data_ew'];
    clear data_ns;
    clear data_ew;
    data_ns = data_rotated(1,:)';
    data_ew = data_rotated(2,:)';
    clear data_rotated;
  end
  
  if Gain ~= 1
    data_ns_gained = data_ns*Gain;
    clear data_ns;
    data_ns = data_ns_gained;
    clear data_ns_gained;
    if NumChannels > 1
      data_ew_gained = data_ew*Gain;
      clear data_ew;
      data_ew = data_ew_gained;
      clear data_ew_gained;
    end
    if NumChannels > 2
      data_aux_gained = data_aux*Gain;
      clear data_aux;
      data_aux = data_aux_gained;
      clear data_aux_gained;
    end
  end
  
  if fc_low > 0
    data_ns_HPF = Noninterleaved_VLF_High_Pass_Filter(data_ns, fc_low, channel_sampling_freq);
    clear data_ns;
    data_ns = data_ns_HPF;
    clear data_ns_HPF;
    if NumChannels > 1
      data_ew_HPF = Noninterleaved_VLF_High_Pass_Filter(data_ew, fc_low, channel_sampling_freq);
      clear data_ew;
      data_ew = data_ew_HPF;
      clear data_ew_HPF;
    end
    if NumChannels > 2
      data_aux_HPF = Noninterleaved_VLF_High_Pass_Filter(data_aux, fc_low, channel_sampling_freq);
      clear data_aux;
      data_aux = data_aux_HPF;
      clear data_aux_HPF;
    end
  end
  
  if fc_high < channel_sampling_freq/2/DownsampleFactor
    data_ns_HPF = Noninterleaved_VLF_Low_Pass_Filter(data_ns, fc_low, channel_sampling_freq);
    clear data_ns;
    data_ns = data_ns_HPF;
    clear data_ns_HPF;
    if NumChannels > 1
      data_ew_HPF = Noninterleaved_VLF_Low_Pass_Filter(data_ew, fc_low, channel_sampling_freq);
      clear data_ew;
      data_ew = data_ew_HPF;
      clear data_ew_HPF;
    end
    if NumChannels > 2
      data_aux_HPF = Noninterleaved_VLF_Low_Pass_Filter(data_aux, fc_low, channel_sampling_freq);
      clear data_aux;
      data_aux = data_aux_HPF;
      clear data_aux_HPF;
    end
  end
  
  if TypeOfData <= 3 || TypeOfData == 8
    start_day0 = matGetVariable(filename0,'start_day',1,0);
    fclose all;
    start_hour0 = matGetVariable(filename0,'start_hour',1,0);
    fclose all;
    start_minute0 = matGetVariable(filename0,'start_minute',1,0);
    fclose all;
    start_month0 = matGetVariable(filename0,'start_month',1,0);
    fclose all;
    start_second0 = matGetVariable(filename0,'start_second',1,0);
    fclose all;
    start_year0 = matGetVariable(filename0,'start_year',1,0);
    fclose all;
    if interleaved == 1
      try
        station_name0=matGetVariable(filename0,'siteName',20,0);
      catch
        station_name0=matGetVariable(filename0,'station_name',20,0);
      end
      % Some Palmer station names have underscores in them, which is annoying
      if strcmp(station_name0, 'PALMER__') || strcmp(station_name0, 'Palmer Station')
        station_name0 = 'PALMER';
      end
    else
      station_name0=matGetVariable(filename0,'station_name',20,0);
    end
    fclose all;
    startdate0 = datenum(start_year0, start_month0,  start_day0, start_hour0, start_minute0, start_second0);
    fclose all;
    
    if NumChannels > 1 && interleaved == 1
      station_name1 = station_name0;
      startdate1 = startdate0;
    end
    if NumChannels > 2 && interleaved == 1
      station_name2 = station_name0;
      startdate2 = startdate0;
    end
    
    if NumChannels > 1 && interleaved == 0
      start_day1 = matGetVariable(filename1,'start_day',1,0);
      fclose all;
      start_hour1 = matGetVariable(filename1,'start_hour',1,0);
      fclose all;
      start_minute1 = matGetVariable(filename1,'start_minute',1,0);
      fclose all;
      start_month1 = matGetVariable(filename1,'start_month',1,0);
      fclose all;
      start_second1 = matGetVariable(filename1,'start_second',1,0);
      fclose all;
      start_year1 = matGetVariable(filename1,'start_year',1,0);
      fclose all;
      station_name1 = matGetVariable(filename1,'station_name',20,0);
      fclose all;
      startdate1 = datenum(start_year1, start_month1,  start_day1, start_hour1, start_minute1, start_second1);
    end
    if NumChannels > 2 && interleaved == 0
      start_day2 = matGetVariable(filename2,'start_day',1,0);
      fclose all;
      start_hour2 = matGetVariable(filename2,'start_hour',1,0);
      fclose all;
      start_minute2 = matGetVariable(filename2,'start_minute',1,0);
      fclose all;
      start_month2 = matGetVariable(filename2,'start_month',1,0);
      fclose all;
      start_second2 = matGetVariable(filename2,'start_second',1,0);
      fclose all;
      start_year2 = matGetVariable(filename2,'start_year',1,0);
      fclose all;
      station_name2 = matGetVariable(filename2,'station_name',20,0);
      fclose all;
      startdate2 = datenum(start_year2, start_month2,  start_day2, start_hour2, start_minute2, start_second2);
      fclose all;
    end
  else
    start_day0 = 26;
    start_hour0 = 23;
    start_minute0 = 20;
    start_month0 = 1;
    start_second0 = 00;
    start_year0 = 2007;
    station_name0 = 'VLF Data';
    startdate0 = datenum(start_year0, start_month0,  start_day0, start_hour0, start_minute0, start_second0);
    start_day1 = start_day0;
    start_hour1 = start_hour0;
    start_minute1 = start_minute0;
    start_month1 = start_month0;
    start_second1 = start_second0;
    start_year1 = start_year0;
    station_name1 = station_name0;
    startdate1 = startdate0;
    start_day2 = start_day0;
    start_hour2 = start_hour0;
    start_minute2 = start_minute0;
    start_month2 = start_month0;
    start_second2 = start_second0;
    start_year2 = start_year0;
    station_name2 = station_name0;
    startdate2 = startdate0;
  end
  
  if TypeOfData == 8
    station_name0 = 'Arrival Heights';
    station_name1 = 'Arrival Heights';
  end
  
  %%%%%%%%%%%%%%%%%%%
  
  if CleanTransmitters == 1 && NumChannels > 1
    [NS_clean,EW_clean] = Remove_Transmitters(data_ns,data_ew,channel_sampling_freq,1,1,0.5,0);
    clear data_ns;
    clear data_ew;
    data_ns = NS_clean;
    data_ew = EW_clean;
    clear NS_clean;
    clear EW_clean;
    if NumChannels > 2
      [AUX_clean,AUX2_clean] = Remove_Transmitters(data_aux,data_aux,channel_sampling_freq,1,1,0.5,0);
      clear data_aux;
      data_aux = AUX_clean;
      clear AUX_clean;
      clear AUX2_clean;
    end
  end
  
  if CleanHum == 1
    NS_clean = HumFilter(data_ns);
    clear data_ns;
    data_ns = NS_clean;
    clear NS_clean;
    if NumChannels > 1
      EW_clean = HumFilter(data_ew);
      clear data_ew;
      data_ew = EW_clean;
      clear EW_clean;
    end
    if NumChannels > 2
      AUX_clean = HumFilter(data_aux);
      clear data_aux;
      data_aux = AUX_clean;
      clear AUX_clean;
      clear AUX2_clean;
    end
  end
  
  if FigureActivator(2) == 1
    sfigure(2);
    [B0, F0, T0]=specgram(data_ns,NFFT,channel_sampling_freq,Window, Overlap);
    if NumChannels > 1
      sfigure(2);
      [B1, F1, T1]=specgram(data_ew,NFFT,channel_sampling_freq,Window, Overlap);
    end
    if NumChannels > 2
      sfigure(gcf);
      [B2, F2, T2]=specgram(data_aux,NFFT,channel_sampling_freq,Window, Overlap);
    end
  end
  
  if FigureActivator(3) == 1
    [f_ns H_f_ns freq_ns FFT_f_ns] = fftconvert(data_ns, channel_sampling_freq);
    if NumChannels > 1
      [f_ew H_f_ew freq_ew FFT_f_ew] = fftconvert(data_ew, channel_sampling_freq);
    end
    if NumChannels > 2
      [f_aux H_f_aux freq_aux FFT_f_aux] = fftconvert(data_aux, channel_sampling_freq);
    end
  end
  
  if FigureActivator(5) == 1 && NumChannels > 1 && length0 == length1 && offset0 == offset1
    if NumChannels > 2
      data_ns_up = resample(data_ns, 2, 1);
      data_ew_up = resample(data_ew, 2, 1);
      data_aux_up = resample(data_aux, 2, 1);
      data_combined = data_ns.^2 + data_ew.^2 + data_aux.^2;
    else
      data_ns_up = resample(data_ns, 2, 1);
      data_ew_up = resample(data_ew, 2, 1);
      data_combined = data_ns.^2 + data_ew.^2;
    end
    data_combined_temp = 2.0*(data_combined - mean(data_combined));
    clear data_combined;
    data_combined = data_combined_temp;
    clear data_combined_temp;
    [Bc, Fc, Tc]=specgram(data_combined,NFFT*2,2*channel_sampling_freq,Window*2, Overlap*2);
  end
  
  if FigureActivator(1) == 1
    if ProcessEntireFile == 0 && ~ishandle(1)
      figure(1);
    else
      set(0, 'CurrentFigure', 1);
      clf;
    end
    
    subplot(NumChannels,1,1);
    plot(offset0+(1:length(data_ns))/channel_sampling_freq,data_ns/2^15)
    axis xy;
    ylabel('Magnetic Field','FontSize',16)
    title_text=sprintf(' %s UT   %s Antenna',datestr(startdate0,'dd-mmm-yyyy'),'N/S');
    title([char(station_name0) title_text],'FontSize',18);
    xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate0,13)),'FontSize',16);
    set(gca,'FontSize',16)
    a = axis;
    axis([offset0 offset0+length0 -1 1])
    if NumChannels > 1
      subplot(NumChannels,1,2);
      plot(offset1+(1.5:(length(data_ew)+0.5))/channel_sampling_freq,data_ew/2^15)
      axis xy;
      ylabel('Magnetic Field','FontSize',16)
      title_text=sprintf(' %s UT   %s Antenna',datestr(startdate0,'dd-mmm-yyyy'),'E/W');
      title([char(station_name0) title_text],'FontSize',18);
      xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate0,13)),'FontSize',16);
      set(gca,'FontSize',16)
      a = axis;
      axis([offset1 offset1+length1 -1 1])
    end
    if NumChannels > 2
      subplot(NumChannels,1,3);
      plot((1:length(data_aux))/channel_sampling_freq,data_aux/2^15)
      axis xy;
      ylabel('Magnetic Field','FontSize',16)
      title_text=sprintf(' %s UT   %s Antenna',datestr(startdate2,'dd-mmm-yyyy'),'Aux');
      title([char(station_name2) title_text],'FontSize',18);
      xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate2,13)),'FontSize',16);
      set(gca,'FontSize',16)
      a = axis;
      axis([a(1) a(2) -1 1])
    end
  end
  
  %     if ProcessEntireFile ~= 1 || offset0 == 0
  %         ColorbarMin = ColorbarMin - 20*log10(DownsampleFactor) + 20*log10(WindowFactor);
  %         ColorbarMax = ColorbarMax - 20*log10(DownsampleFactor) + 20*log10(WindowFactor);
  %     end
  
  if FigureActivator(2) == 1
    if ProcessEntireFile == 0 && ~ishandle(1)
      sfigure(2);
    else
      sfigure(2);
      clf;
    end
    
    subplot(NumChannels,1,1);
    imagesc(T0+offset0,F0/1000,20*log10(abs(B0)),[ColorbarMin ColorbarMax]);
    axis xy;
    theAxis = axis;
    axis([theAxis(1) theAxis(2) fc_low/1000 min(fc_high/1000/DownsampleFactor,channel_sampling_freq/2000)])
    ylabel('Frequency (kHz)','FontSize',16)
    title_text=sprintf(' %s UT   %s Antenna',datestr(startdate0,'dd-mmm-yyyy'),'N/S');
    title([char(station_name0) title_text],'FontSize',18);
    xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate0,13)),'FontSize',16);
    set(gca,'FontSize',16)
    h=colorbar;
    set(h,'FontSize',16)
    if NumChannels > 1
      subplot(NumChannels,1,2);
      imagesc(T1+offset1,F1/1000,20*log10(abs(B1)),[ColorbarMin ColorbarMax]);
      axis xy;
      theAxis = axis;
      axis([theAxis(1) theAxis(2) fc_low/1000 min(fc_high/1000/DownsampleFactor,channel_sampling_freq/2000)])
      ylabel('Frequency (kHz)','FontSize',16)
      title([char(station_name1) sprintf(' %s UT   %s Antenna',datestr(startdate1,'dd-mmm-yyyy'),'E/W')],'FontSize',18);
      xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate1,13)),'FontSize',16);
      set(gca,'FontSize',16)
      h=colorbar;
      set(h,'FontSize',16)
    end
    if NumChannels > 2
      subplot(NumChannels,1,3);
      imagesc(T2+offset2,F2/1000,20*log10(abs(B2)),[ColorbarMin ColorbarMax]);
      axis xy;
      theAxis = axis;
      axis([theAxis(1) theAxis(2) fc_low/1000 min(fc_high/1000/DownsampleFactor,channel_sampling_freq/2000)])
      ylabel('Frequency (kHz)','FontSize',16)
      title([char(station_name2) sprintf(' %s UT   %s Antenna',datestr(startdate2,'dd-mmm-yyyy'),'AUX')],'FontSize',18);
      xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate1,13)),'FontSize',16);
      set(gca,'FontSize',16)
      h=colorbar;
      set(h,'FontSize',16)
    end
  end
  
  if FigureActivator(3) == 1
    if ProcessEntireFile == 0 && ~ishandle(1)
      figure(3);
    else
      set(0, 'CurrentFigure', 3);
      clf;
    end
    
    subplot(NumChannels,1,1);
    plot(freq_ns, log10(FFT_f_ns))
    axis xy;
    theaxis = axis;
    axis([fc_low min(channel_sampling_freq/2,fc_high) theaxis(3) theaxis(4)])
    ylabel('FFT Magnitude (Log Scale)','FontSize',16)
    title_text=sprintf(' %s UT   %s Antenna',datestr(startdate0,'dd-mmm-yyyy'),'N/S');
    title([char(station_name0) title_text],'FontSize',18);
    xlabel('Frequency','FontSize',16);
    set(gca,'FontSize',16)
    if NumChannels > 1
      subplot(NumChannels,1,2);
      plot(freq_ns, log10(FFT_f_ns))
      axis xy;
      theaxis = axis;
      axis([fc_low min(channel_sampling_freq/2,fc_high) theaxis(3) theaxis(4)])
      ylabel('FFT Magnitude (Log Scale)','FontSize',16)
      title_text=sprintf(' %s UT   %s Antenna',datestr(startdate0,'dd-mmm-yyyy'),'E/W');
      title([char(station_name0) title_text],'FontSize',18);
      xlabel('Frequency','FontSize',16);
      set(gca,'FontSize',16)
    end
    if NumChannels > 2
      subplot(NumChannels,1,3);
      plot(freq_aux, log10(FFT_f_aux))
      axis xy;
      theaxis = axis;
      axis([fc_low min(channel_sampling_freq/2,fc_high) theaxis(3) theaxis(4)])
      ylabel('FFT Magnitude (Log Scale)','FontSize',16)
      title_text=sprintf(' %s UT   %s Antenna',datestr(startdate2,'dd-mmm-yyyy'),'E/W');
      title([char(station_name2) title_text],'FontSize',18);
      xlabel('Frequency','FontSize',16);
      set(gca,'FontSize',16)
    end
  end
  
  if FigureActivator(4) == 1 && NumChannels > 1
    if ProcessEntireFile == 0 && ~ishandle(1)
      figure(4);
    else
      set(0, 'CurrentFigure', 4);
      clf;
    end
    
    plot(data_ns,data_ew)
    axis xy;
    ylabel('EW Value','FontSize',16)
    title_text=sprintf('X-Y Plot');
    title([char(station_name0) title_text],'FontSize',18);
    xlabel('NS Value','FontSize',16);
    set(gca,'FontSize',16)
  end
  
  if FigureActivator(5) == 1
    if ProcessEntireFile == 0 && ~ishandle(1)
      figure(5);
    else
      set(0, 'CurrentFigure', 5);
      clf;
    end
    
    subplot(2,1,1)
    imagesc(Tc+offset0,Fc/1000,20*log10(abs(Bc)),[2*ColorbarMin 2*ColorbarMax]);
    axis xy;
    theAxis = axis;
    axis([theAxis(1) theAxis(2) 2*fc_low/1000/DownsampleFactor 2*min(fc_high/1000/DownsampleFactor,channel_sampling_freq/2000)])
    ylabel('Doubled Frequency (kHz)','FontSize',16)
    title_text=sprintf(' %s UT   %s Antenna',datestr(startdate0,'dd-mmm-yyyy'),'Combined');
    title([char(station_name0) title_text],'FontSize',18);
    xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate0,13)),'FontSize',16);
    set(gca,'FontSize',16)
    h=colorbar;
    set(h,'FontSize',16)
    
    subplot(2,1,2)
    plot(offset0+(1:length(data_combined))/channel_sampling_freq,data_combined/2^30)
    axis xy;
    ylabel('Combined Magnetic Field','FontSize',16)
    title_text=sprintf(' %s UT   %s Antenna',datestr(startdate0,'dd-mmm-yyyy'),'N/S');
    title([char(station_name0) title_text],'FontSize',18);
    xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate0,13)),'FontSize',16);
    set(gca,'FontSize',16)
    a = axis;
    axis([offset0 offset0+length0 -1 1])
  end
  
  if FigureActivator(6) == 1 && NumChannels > 1
    if ProcessEntireFile == 0 && ~ishandle(1)
      figure(6);
    else
      set(0, 'CurrentFigure', 6);
      clf;
    end
    
    if NumChannels > 2
      plot(offset0+(1:length(data_ns))/channel_sampling_freq,sqrt((data_ns.^2+data_ew.^2+data_aux.^2)/3)/2^15)
    else
      plot(offset0+(1:length(data_ns))/channel_sampling_freq,sqrt((data_ns.^2+data_ew.^2)/2)/2^15)
    end
    axis xy;
    ylabel('Magnetic Field Intensity','FontSize',16)
    title_text=sprintf(' %s UT',datestr(startdate0,'dd-mmm-yyyy'));
    title([char(station_name0) title_text],'FontSize',18);
    xlabel(sprintf('Time (seconds) after %s UT',datestr(startdate0,13)),'FontSize',16);
    set(gca,'FontSize',16)
    a = axis;
    axis([offset0 offset0+length0 0 1])
  end
  
  
  offset0 = offset0 + SegmentLength;
  if NumChannels > 1
    offset1 = offset1 + SegmentLength;
  end
  if NumChannels > 2
    offset2 = offset2 + SegmentLength;
  end
  if offset0 + SegmentLength > FileLength
    length0 = FileLength - offset0;
    if NumChannels > 1
      length1 = FileLength - offset1;
    end
    if NumChannels > 2
      length2 = FileLength - offset2;
    end
  end
  
  if ~(ProcessEntireFile == 1 && offset0 + SegmentLength <= FileLength)
    KeepGoing = 0;
  end
  
  if ProcessEntireFile == 1
    FileNameSecond = start_second0 + offset0-SegmentLength;
    FileNameMinute = start_minute0;
    FileNameHour = start_hour0;
    FileNameDay = start_hour0;
    while FileNameSecond >= 60
      FileNameSecond = FileNameSecond-60;
      FileNameMinute = FileNameMinute+1;
    end
    while FileNameMinute >= 60
      FileNameMinute = FileNameMinute-60;
      FileNameHour = FileNameHour+1;
    end
    
    if FileNameSecond < 10
      FileNameSecondString = ['0' int2str(FileNameSecond)];
    else
      FileNameSecondString = int2str(FileNameSecond);
    end
    if FileNameMinute < 10
      FileNameMinuteString = ['0' int2str(FileNameMinute)];
    else
      FileNameMinuteString = int2str(FileNameMinute);
    end
    if FileNameHour < 10
      FileNameHourString = ['0' int2str(FileNameHour)];
    else
      FileNameHourString = int2str(FileNameHour);
    end
    if start_day0 < 10
      FileNameDayString = ['0' int2str(start_day0)];
    else
      FileNameDayString = int2str(start_day0);
    end
    if start_month0 < 10
      FileNameMonthString = ['0' int2str(start_month0)];
    else
      FileNameMonthString = int2str(start_month0);
    end
    
    
    % Save JPEG
    increase_font;
    
    if FigureActivator(1) == 1
      cd(JPEGLocation)
      filename = [station_name0 '-' int2str(start_year0) '-' FileNameMonthString '-' FileNameDayString 'T' FileNameHourString '-' FileNameMinuteString '-' FileNameSecondString '-' 'Time.png'];
      saveas(1,filename,'png');
      disp(sprintf('Saved %s', fullfile(JPEGLocation, filename)));
      cd(pathname)
    end
    if FigureActivator(2) == 1
      cd(JPEGLocation)
      filename = [station_name0 '-' int2str(start_year0) '-' FileNameMonthString '-' FileNameDayString 'T' FileNameHourString '-' FileNameMinuteString '-' FileNameSecondString '-' 'Spec.png'];
      saveas(2,filename,'png');
      disp(sprintf('Saved %s', fullfile(JPEGLocation, filename)));
      cd(pathname)
    end
    if FigureActivator(3) == 1
      cd(JPEGLocation)
      filename = [station_name0 '-' int2str(start_year0) '-' FileNameMonthString '-' FileNameDayString 'T' FileNameHourString '-' FileNameMinuteString '-' FileNameSecondString '-' 'FFT.png'];
      saveas(3,filename,'png')
      disp(sprintf('Saved %s', fullfile(JPEGLocation, filename)));
      cd(pathname)
    end
    if FigureActivator(4) == 1
      cd(JPEGLocation)
      filename = [station_name0 '-' int2str(start_year0) '-' FileNameMonthString '-' FileNameDayString 'T' FileNameHourString '-' FileNameMinuteString '-' FileNameSecondString '-' 'XY.png'];
      saveas(4,filename,'png')
      disp(sprintf('Saved %s', fullfile(JPEGLocation, filename)));
      cd(pathname)
    end
    if FigureActivator(5) == 1
      cd(JPEGLocation)
      filename = [station_name0 '-' int2str(start_year0) '-' FileNameMonthString '-' FileNameDayString 'T' FileNameHourString '-' FileNameMinuteString '-' FileNameSecondString '-' 'UniTime.png'];
      saveas(5,filename,'png')
      disp(sprintf('Saved %s', fullfile(JPEGLocation, filename)));
      cd(pathname)
    end
    if FigureActivator(6) == 1
      cd(JPEGLocation)
      filename = [station_name0 '-' int2str(start_year0) '-' FileNameMonthString '-' FileNameDayString 'T' FileNameHourString '-' FileNameMinuteString '-' FileNameSecondString '-' 'UniSpec.png'];
      saveas(6,filename,'png')
      disp(sprintf('Saved %s', fullfile(JPEGLocation, filename)));
      cd(pathname)
    end
  end
  
  disp(sprintf('Created image %d of %d in %0.2f seconds', round(offset0/SegmentLength), round(FileLength/SegmentLength), toc))
  total_time = total_time + toc;
end

%% Assign output arguments
if nargout > 0
  varargout{1} = total_time;
end
