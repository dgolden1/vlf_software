function  bb=getBBdata(pathname,filename,fromSecond,toSecond)

% bb=getBBdata(pathname,filename,fromSecond,toSecond)
%
% This is the interface to Stanford Broadband data in the 2000+ format.
% This is the only function that should be used to read data files.
%
%
% 2000March22:cPbL@alum.mit.edu
% 2000May2: cPbL: Expanded functionality. Note that if the file has data already in struct form
%  (ie it is a secondary data file, not written by the acquisition program), the 3rd and 4th
%  arguments will be ignored.  This should be fixed.
% 2000Aug23: cPbL and Robert M Barrington Leigh: Major upgrade using our new MAT file reading
%           package. The program only loads the requested portion of data. Also generalized for
%           n channels rather than 2.
% 2000Aug24: cPbL: Found out from Maria that files written in modern .MAT format are not
%          compatible with version 4 files, or with the way in which we write them
%          from C++. Thus we cannot use the mat tools on new files. When the mat tools
%          fail, the entire file is read, as it was prior to August 23.
%
% Bugs:
%  The version must have only precision to three decimal places. This is because there is some
%   truncation problem when Matlab or C converts a float to a double. (!?)
% - If the requested file is a secondary file, in which the data are already in a bb struct,
%     the entire structure is returned (no subsetting).  Needs to be written.
%
% Description of the (Palmer) Broadband snapshot file format, up to version 2000.24:
%   These files are written using the matfile class in C++, which writes files in a 
%   .mat version compatible with Matlab v4.  A number of variables specify various
%   settings and time information, and a large variable called "data" contains all
%   the broadband data from all the channels.  Because the data are saved in real time in a 
%   stream-to-disk mode, they are not deinterlaced before saving. Thus two-channel data
%   are interlaced with alternating data corresponding to channel 0, then 1, then 0, etc.
%   The units for the raw data are digital units (signed 16 bit). The corresponding voltages
%   can be determined from the header information, but calibration data are needed
%   to derive physical units.
%   The header information is hopeful self-explanatory.
%   Note that version 4 MAT files can be created using the "-V4" option of SAVE.
%   However, currently (Aug2000) saveBBdata saves data in a struct, so it must use version 5.
%
% The "bb" struct format is somewhat open-ended. Calibration information should
%   be added by appending a "digitalToVolts" and "voltsToPhysical" members 
%   to the structure.
% 
%

Version = -1;
comments = 'Bad version : no comments';

if nargin < 2,
   [filename,pathname] = uigetfile('BB*.mat', 'Choose a Palmer BB file to load');
end%if
if nargin < 3,
   fromSecond=0;
end%if
if nargin < 4,
   toSecond=inf;
end%if

%fprintf('Loading data... be patient...\n');

% 2000 Aug 23: USe new mat file tools to read all variables except
%   data:
matLoadExcept(fullfile(pathname, filename),'data');
%    and later we load only part of a particular variable using matGetVariable.

% Construct BB structure
%fprintf('\nFile starts at %s.\n',datestr(datenum(start_year , start_month,  start_day, start_hour,  start_minute, start_second)));
bb.startDate= datenum( start_year , start_month,  start_day, start_hour,  start_minute, start_second+fromSecond);
%fprintf('Extracted data starts at %s.\n',datestr(bb.startDate));
bb.nChannels=num_channels;
bb.channelSequence=channel_sequence';
% Following frequency is in Hz.
bb.sampleFrequency=channel_sampling_freq(1); % NOTE!! THIS IS A LIMITATION, FOLLOWING THAT OF VERSION 2000.2: ALL SAMPLING FREQUENCIES MUST BE THE SAME.
bb.ADgains=channel_gain';
bb.location.altitude=antenna_altitude;
bb.antennaHeadings=antenna_heading';
bb.location.latitude=antenna_latitude;
bb.location.longitude=antenna_longitude;
bb.channelOffset_ns=time_diff_ns;
bb.version=round(Version*1000)/1000; % See Bugs, in help info for this function.
bb.comments=char(comments)';
if bb.version < 2000.24, % In version 2000.24, I adopted 8.3 filenames for ISO9660 CD compatibility
   bb.site=(strtok(filename(1:8),'_'));
else
   bb.site=(strtok(siteName,'_'));
end%if bb.version < 2000.24,


if status==-1, % Failed to read file, above, in matReadExcept, so we read the whole thing (above).
   fprintf('Deinterlacing data ....');
      startSample=2*fromSecond*bb.sampleFrequency +1;
      endSample=min([length(data) 2*toSecond*bb.sampleFrequency]);
      bb.data(1,:)=data(startSample:2:endSample)';
      bb.data(2,:)=data(1+(startSample:2:endSample))';
   
else % matLoadExcept seemed to work. Continue with optimal plan:
   
% 23 AUGUST 2000: Load only the requested portion of the data variable!

% Assuming synoptics always start on a minute boundary:
if nargin<3
   fromSecond=0;
   toSecond=Inf;
end%if
endSample= bb.nChannels * round(bb.sampleFrequency * toSecond) ;
startSample= bb.nChannels * round(bb.sampleFrequency * fromSecond);
interlacedData=matGetVariable(fullfile(pathname, filename),'data',endSample-startSample,startSample);

%fprintf('\nNote: Current deinterlacing is done because matGetVariable currently assumes 1-D vectors.\n');
%fprintf('Deinterlacing data ....');
for j=1:bb.nChannels,
   bb.data(j,:)=interlacedData(j:bb.nChannels:end)';
end%for j
%fprintf('\n');

end%if
