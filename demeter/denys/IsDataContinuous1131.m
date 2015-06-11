function out = IsDataContinuous1131(fid)
%IsDataContinuous1131 Checks if data file 1131 or 1136 have continuous data

global AllBlockSize1131 FrameNumber1131 BlockDuaration1131

fseek(fid,0,'bof'); % rewinds file position to beginning
[y, m, d, Second1, OrbitN1, OrbitType1] = readLevel1Block1(fid);
fseek(fid,0,'bof'); % rewinds file position to beginning
fseek(fid,AllBlockSize1131*(FrameNumber1131-1),'cof'); % skip to last block
[y, m, d, Second2, OrbitN2, OrbitType2] = readLevel1Block1(fid);
fseek(fid,0,'bof'); % rewinds file position to beginning

if OrbitN1 ~= OrbitN2
    out = false;
    disp(['Orbit ',num2str(OrbitN1),'_',num2str(OrbitType1),' is interrupted']);
    return
end

expectedSecond2 = Second1 + (FrameNumber1131 - 1)*BlockDuaration1131;
delta = abs(Second2 - expectedSecond2);

if delta > BlockDuaration1131*0.01
    out = false;
    disp(['Orbit ',num2str(OrbitN1),'_',num2str(OrbitType1),' is not continuous']);
    return
end

out = true;

end

