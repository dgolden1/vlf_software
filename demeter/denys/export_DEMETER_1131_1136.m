%% Exporting DEMETER VLF (1131 and 1136) to text files
% File: export_DEMETER_1131_1136.m
% -------------------------------------------------------------------------
% Output:
%
% txt files in the working directory
% 
% Input:
% 
% Data file in working directory:
% DMT_N1_1131_*.DAT
% DMT_N1_1136_*.DAT
% 
%
% -------------------------------------------------------------------------
% The program needs next functions/subprograms:
%
% -> GetDataTiming1131.m
% -> IsDataContinuous1131.m
% -> readLevel1Block1.m
% -> readLevel1Block2.m
% -> readLevel1Block4_1131.m
% -> ReadDataFile_1131.m
% -> ReadDataFile_1136.m
%
% The program is called by next programs:
%
% NONE
%
% ------------------------------------------------------------------------- 
% Author: Denys Piddyachiy (depi@stanford.edu)
%
% -------------------------------------------------------------------------

clear all
close all

%% Initial parameters

SampleFreq = 40000;                   % should equal or less than original

display('BEGINNING OF PROCCESSING===================================================')

%% Export E,B fields
ReadDataFile_1131
Efield = double(Efield);
save('VLF_E-field.txt','Efield','-ascii')
display('E-field is saved to "VLF_E-field.txt"')
clear Efield

ReadDataFile_1136
Bfield = double(Bfield);
save('VLF_B-field.txt','Bfield','-ascii')
display('B-field is saved to "VLF_B-field.txt"')
clear Bfield


%% Position and time export
passPointsDeltaT = 1; % sec
passPoints.second = floor(first.second):passPointsDeltaT:ceil(last.second);
passPoints.lat = ppval(LatSpline,passPoints.second);
passPoints.long = ppval(LongSpline,passPoints.second);

matrixToExport = [passPoints.second; passPoints.lat; passPoints.long]';
save('position.txt','matrixToExport','-ascii')
display('[Second Lat Long] are saved to "position.txt"')

firstSecondToExport = first.second;
save('second_of_the_first_data_point_from_0000_UT.txt','firstSecondToExport','-ascii')
display('"second_of_the_first_data_point_from_0000_UT.txt" is created')

