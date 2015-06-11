%% Reading data from 1132 (Survey E-field) file
% ReadDataFile_1132

% Originally by Denys Piddyachiy
% Modified by Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

filename = '/media/scott/spacecraft/demeter/Level1/General/1132_survey_VLF_E_psd/2007/DMT_N1_1132_160361_20070704_045537_20070704_053154.DAT';
DataFile = dir(filename); 
FileToOpen = filename;
FileSize = DataFile.bytes;

fid = fopen(FileToOpen,'r','b','US-ASCII');

if fid < 0
    disp(['Cannot open file ',DataFile.name]);
end

fseek(fid,204,'cof'); % skip common blocks 1, 2 and 3

readLevel1Block4_1132_header;

AllBlockSize1132 = 204 + 114 + Nb*Nbf*4;
%nBlockElements1132 = Nb;
FrameNumber1132 = FileSize/AllBlockSize1132;
BlockDuaration1132 = TotalTimeDuration;
SpectrumDuration = double(TotalTimeDuration)/double(Nb);

% initialization of output
PowerSpectrum = zeros(FrameNumber1132*Nb,Nbf,'single');
Lat = zeros(FrameNumber1132,1,'single');
Long = zeros(FrameNumber1132,1,'single');
Alt = zeros(FrameNumber1132,1,'single');
LThour = zeros(FrameNumber1132,1,'single');
L = zeros(FrameNumber1132,1,'single');
SecondBlock1 = zeros(FrameNumber1132,1,'single');
SpectrumSecond = zeros(FrameNumber1132*Nb,1);

% reading main data
fseek(fid,0,'bof');
for iFrame = 1:FrameNumber1132
    [Year, Month, Day, SecondBlock1(iFrame), OrbitN, OrbitType] = readLevel1Block1(fid);
    [Lat(iFrame), Long(iFrame), Alt(iFrame), LThour(iFrame), L(iFrame)] =...
        readLevel1Block2(fid);
    fseek(fid,76,'cof'); % skip block 3
    fseek(fid,114,'cof'); % skip block 4 header
    for iNb = 1:Nb
        PowerSpectrum((iFrame-1)*Nb+iNb,1:Nbf) = fread(fid,Nbf,'float32=>single');
        SpectrumSecond((iFrame-1)*Nb+iNb) = SecondBlock1(iFrame) + (double(iNb)-1)*SpectrumDuration;
    end
end

fclose(fid);

BlockSecond = SecondBlock1;
SpectrumFrequency = FrequencyRange(1):FrequencyResolution:FrequencyRange(2);
 
%% Spline approximation of attitude parameters
% Example of usage
% x = 76300:0.01:76600;
% f = ppval(LatSpline,x);
% figure; plot(x,f,'r-')
LatSpline = spline(BlockSecond(1:end),double(Lat(1:end)));
LongSpline = spline(BlockSecond(1:end),double(Long(1:end)));
AltSpline = spline(BlockSecond(1:1:end),double(Alt(1:1:end)));
LThourSpline = spline(BlockSecond(1:1:end),double(LThour(1:1:end)));
LSpline = spline(BlockSecond(1:1:end),double(L(1:1:end)));
clear Lat Long Alt LThour L


%% Screen output
disp(['E power spectrum has been read from file ',DataFile.name])
disp(['Start time of data: ',datestr(datenum(Year,Month,Day,0,0,SpectrumSecond(1)),'yyyy-mm-dd HH:MM:SS')])
disp(['Stop time of data:  ',datestr(datenum(Year,Month,Day,0,0,SpectrumSecond(end)),'yyyy-mm-dd HH:MM:SS')])

