function [Lat, Long, Alt, LThour, L] = readLevel1Block2(fid)
%readLevel1Block2 

Lat = single(fread(fid,1,'float32'));
Long = single(fread(fid,1,'float32'));
Alt = single(fread(fid,1,'float32'));
LThour = single(fread(fid,1,'float32'));
fseek(fid,16,'cof');
L = single(fread(fid,1,'float32'));
fseek(fid,54,'cof'); % skip to the end of Block 2

end

