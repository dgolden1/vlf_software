function [Year, Month, Day, Second, OrbitN, OrbitType] = readLevel1Block1(fid)
%readLevel1Block1 reads Block1 of any Level1 data

% Originally by Denys Piddyachiy
% Modified by Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

fseek(fid,8,'cof'); % skip Standard CCSDS date
TimeMatrix = fread(fid,7,'int16');
Year = TimeMatrix(1);
Month = TimeMatrix(2);
Day = TimeMatrix(3);
Hour = TimeMatrix(4);
Min = TimeMatrix(5);
Sec = TimeMatrix(6);
Millisec = TimeMatrix(7);
Second = Hour*3600 + Min*60 + Sec + Millisec*.001;
OrbitN = fread(fid,1,'int16');
OrbitType = fread(fid,1,'int16');
fseek(fid,12,'cof'); % skip to the end of Block 1

end

