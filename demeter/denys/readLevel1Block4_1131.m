function Efield = readLevel1Block4_1131(fid)
%readLevel1Block4_1131 reads E in uV/m for 1131 or B in nT for 1136

fseek(fid,91,'cof'); % skip to field data
Efield = fread(fid,8192,'float32=>single');

end

