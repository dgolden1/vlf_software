%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code intended to extract a frequency time series by mixing and low pass
% filtering
%Author: Mark Golkowski
%Stanford University
%make taps=0 to mix down only and not filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data_aut=extract_freq(dane_in, fmix, fs, bw,taps)
dane_in=reshape(dane_in,length(dane_in),1);

%Mix Down data

dt=1/fs;
t=[0:dt:length(dane_in)/fs-dt];
if length(fmix)==1
fmix=fmix*ones(length(t),1);
elseif length(fmix)==2
    fmix=linspace(fmix(1), fmix(2),length(t))';
else
    disp('Error fmix variable has wrong dimensions')
    return;
end

i=sqrt(-1);
mdata_in=dane_in.*exp(i.*2.*pi.*cumsum(fmix)*dt);

if taps>0
%Filter mixed down data
hfs=fs/2; n=taps; Wn=bw/hfs;
B=fir1(n,Wn);
%     figure(7)
% [H,W,S]=freqz(B,1,4*1024,fs);
% freqzplot(H,W,'Hz');
% title(sprintf('%d taps',n'))
% axis([0 500 -80 0])
data_aut=filtfilt(B,1,mdata_in);
else
    data_aut=mdata_in;
end

