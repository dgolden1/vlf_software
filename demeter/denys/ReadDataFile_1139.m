%% Reading data from 1139 file - IAP
% File: ReadDataFile_1139.m
% -------------------------------------------------------------------------
% Ouput:
%
% TimeResolution in s;
% 
% Hdensity in cm^-3;
% Hedensity in cm^-3;
% Odensity in cm^-3;
% IonTemp in K;
% IonVelo in m/s; velocity along the satellite Oz axis
% IonAngleVZ in degree; angle between ion velocity and -Oz axis
% IonAngleXYX in degree; angle between projection of the ions velocity and -Oz axis
% SatellitePotent in V;
% 
% BlockParticleTimeSec matrix in seconds of corresponding points in these
% matrices
% 
% BlockAttitude - Lat, Long, L-shell, Alt;
% 
% Input:
% 
% 
% -------------------------------------------------------------------------
% The program need next functions:
%
% NONE
%
% The program is called by next programs:
%
% <- plot_DEMETER_ground.m
% -------------------------------------------------------------------------

DataFile = dir('DMT_N1_1139_*.DAT'); 
FileToOpen = DataFile.name;
FileSize = DataFile.bytes;
FrameNumber = FileSize/(204+108);

%create empty variables
Hdensity =[];
Hedensity = [];
Odensity = [];
IonTemp = [];
IonVelo = [];
IonAngleVZ = [];
IonAngleXYX = [];
SatellitePotent = [];


fid = fopen(FileToOpen,'r','b');
fseek(fid,0,'bof'); %rewinds file position

BlockParticleTimeSec = [];
BlockAttitude = [];

for i = 1:FrameNumber    
    %convert numbers common to all types of data files
    status = fseek(fid,8,'cof');
    TimeMatrix = fread(fid,7,'int16');
    Year1139 = TimeMatrix(1);
    Month1139 = TimeMatrix(2);    
    Day1139 = TimeMatrix(3);
    ParticleHour = TimeMatrix(4);
    ParticleMin = TimeMatrix(5);
    ParticleSec = TimeMatrix(6);
    ParticleMillisec = TimeMatrix(7);
    CurrentSec = ParticleHour*3600 + ParticleMin*60 + ParticleSec + ParticleMillisec*.001;
    BlockParticleTimeSec = [BlockParticleTimeSec; CurrentSec];

    status = fseek(fid,16,'cof');
    CurrentLat = fread(fid,1,'float32');
    CurrentLong = fread(fid,1,'float32');
    CurrentAlt = fread(fid,1,'float32');
    status = fseek(fid,20,'cof');
    CurrentL = fread(fid,1,'float32');
    BlockAttitude = [BlockAttitude; [CurrentLat, CurrentLong, CurrentL, CurrentAlt]];

    status = fseek(fid,54+76,'cof');
    
    %data specific to each file type        
    status = fseek(fid,42,'cof');
    
    TimeResolution = fread(fid,1,'float32');
    
    DensityUnitInt = fread(fid,6,'int8');
    DensityUnit = char(DensityUnitInt);
    
    TemperatureUnitInt = fread(fid,6,'int8');
    TemperatureUnit = char(TemperatureUnitInt);
    
    VelocityUnitInt = fread(fid,6,'int8');
    VelocityUnit = char(VelocityUnitInt);
    
    PotentialUnitInt = fread(fid,6,'int8');
    PotentialUnit = char(PotentialUnitInt);
    
    AngleUnitInt = fread(fid,6,'int8');
    AngleUnit = char(AngleUnitInt);
    
    nextH = fread(fid,1,'float32');
    Hdensity =[Hdensity, nextH];

    nextHe = fread(fid,1,'float32');
    Hedensity = [Hedensity, nextHe];

    nextO = fread(fid,1,'float32');
    Odensity = [Odensity, nextO];

    nextTemp = fread(fid,1,'float32');
    IonTemp = [IonTemp, nextTemp];

    nextVelo = fread(fid,1,'float32');
    IonVelo = [IonVelo, nextVelo];

    nextAngleVZ = fread(fid,1,'float32');
    IonAngleVZ = [IonAngleVZ, nextAngleVZ];

    nextAngleXYX = fread(fid,1,'float32');
    IonAngleXYX = [IonAngleXYX, nextAngleXYX];

    nextPotent = fread(fid,1,'float32');
    SatellitePotent = [SatellitePotent, nextPotent];
    
end

status = fclose(fid);

%% Screen output
disp(['IAP data have been read from file ',DataFile.name])
disp(['Start time of data: ',datestr(datenum(Year1139,Month1139,Day1139,0,0,BlockParticleTimeSec(1)),'yyyy-mm-dd HH:MM:SS')])
disp(['Stop time of data:  ',datestr(datenum(Year1139,Month1139,Day1139,0,0,BlockParticleTimeSec(end)),'yyyy-mm-dd HH:MM:SS')])
