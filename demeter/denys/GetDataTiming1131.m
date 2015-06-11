function [first, last] = GetDataTiming1131(fid)
%GetDataTiming1131

global AllBlockSize1131 FrameNumber1131 BlockDuaration1131 SampleFreq1131


fseek(fid,0,'bof'); % rewinds file position to beginning
[first.year, first.month, first.day, first.second, first.OrbitN, first.OrbitType]...
    = readLevel1Block1(fid);
fseek(fid,0,'bof'); % rewinds file position to beginning
fseek(fid,AllBlockSize1131*(FrameNumber1131-1),'cof'); % skip to last block
[last.year, last.month, last.day, last_second, first.OrbitN, first.OrbitType]...
    = readLevel1Block1(fid);
fseek(fid,0,'bof'); % rewinds file position to beginning

last.second = last_second + BlockDuaration1131 - 1/SampleFreq1131;

end

