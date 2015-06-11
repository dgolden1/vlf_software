function [DataType, Status, DataCoordinateSystem, ComponentName, DataUnit, Nb, Nbf, TotalTimeDuration, FrequencyResolution, FrequencyRange, FirstSpectrumUT] = readLevel1Block4_1132_header(fid)

% Originally by Denys Piddyachiy
% Modified by Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$


DataType = fread(fid,21,'char')';
Status = fread(fid,32,'int8');
DataCoordinateSystem = fread(fid,9,'char')';
ComponentName = fread(fid,3,'char')';
DataUnit = fread(fid,16,'char')';
Nb = fread(fid,1,'int8');
Nbf = fread(fid,1,'int16');
TotalTimeDuration = fread(fid,1,'float32');
FrequencyResolution = fread(fid,1,'float32');
FrequencyRange = fread(fid,2,'float32');
FirstSpectrumUT = fread(fid,7,'int16');


