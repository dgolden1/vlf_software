%% Reading data from 1143 file - ISL
% File: ReadDataFile_1143.m
% -------------------------------------------------------------------------
% Ouput:
%
% TimeResolution in s;
% ElectronDen in cm^-3;
% IonDen in cm^-3;
% ElectronTemp in K;
% IonVelo in m/s; velocity along the satellite Oz axis
% PlasmaPotent in V;
% FloatingPotent in V;
% SatellitePotentISL in V;
% 
% BlockDensityTimeSec matrix in seconds of corresponding points in these
% matrices
% 
% BlockDensityAttitude - Lat, Long, L-shell, Alt;
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

DataFile = dir('DMT_N1_1143_*.DAT'); 
FileToOpen = DataFile.name;
FileSize = DataFile.bytes;
FrameNumber = FileSize/(204+85);

%create empty variables
ElectronDen = [];
IonDen = [];
ElectronTemp = [];
PlasmaPotent = [];
FloatingPotent = [];
SatellitePotentISL = [];

fid = fopen(FileToOpen,'r','b');
fseek(fid,0,'bof'); %rewinds file position

BlockDensityTimeSec = [];
BlockDensityAttitude = [];

for i = 1:FrameNumber     
    %convert numbers common to all types of data files   
    status = fseek(fid,8,'cof');
    TimeMatrix = fread(fid,7,'int16');
    Year1143 = TimeMatrix(1);
    Month1143 = TimeMatrix(2);    
    Day1143 = TimeMatrix(3);
    DensityHour = TimeMatrix(4);
    DensityMin = TimeMatrix(5);
    DensitySec = TimeMatrix(6);
    DensityMillisec = TimeMatrix(7);
    CurrentSec = DensityHour*3600 + DensityMin*60 + DensitySec + DensityMillisec*.001;
    BlockDensityTimeSec = [BlockDensityTimeSec; CurrentSec];
  
    status = fseek(fid,16,'cof');
    CurrentLat = fread(fid,1,'float32');
    CurrentLong = fread(fid,1,'float32');
    CurrentAlt = fread(fid,1,'float32');
    status = fseek(fid,20,'cof');
    CurrentL = fread(fid,1,'float32');
    BlockDensityAttitude = [BlockDensityAttitude; [CurrentLat, CurrentLong, CurrentL, CurrentAlt]];
        
    status = fseek(fid,54+76,'cof');
    
    %data specific to each file type
    status = fseek(fid,42,'cof');
    
    TimeResolution = fread(fid,1,'float32');
    
    DensityElectronUnitInt = fread(fid,5,'int8');
    DensityElectronUnit = char(DensityElectronUnitInt);
    
    TemperatureElectronUnitInt = fread(fid,5,'int8');
    TemperatureElectronUnit = char(TemperatureElectronUnitInt);
    
    PotentialElectronUnitInt = fread(fid,5,'int8');
    PotentialElectronUnit = char(PotentialElectronUnitInt);

    ElectronDen = [ElectronDen, fread(fid,1,'float32')];
    IonDen = [IonDen, fread(fid,1,'float32')];
    ElectronTemp = [ElectronTemp, fread(fid,1,'float32')];
    PlasmaPotent = [PlasmaPotent, fread(fid,1,'float32')];
    FloatingPotent = [FloatingPotent, fread(fid,1,'float32')];
    SatellitePotentISL = [SatellitePotentISL, fread(fid,1,'float32')];
    
end

status = fclose(fid);

%% Screen output
disp(['ISL data have been read from file ',DataFile.name])
disp(['Start time of data: ',datestr(datenum(Year1143,Month1143,Day1143,0,0,BlockDensityTimeSec(1)),'yyyy-mm-dd HH:MM:SS')])
disp(['Stop time of data:  ',datestr(datenum(Year1143,Month1143,Day1143,0,0,BlockDensityTimeSec(end)),'yyyy-mm-dd HH:MM:SS')])
