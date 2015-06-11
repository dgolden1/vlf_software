function [Ap,phip,An,phin,f] = bb_azimuth_calc_freq2(z,NFFT,fs,varargin);
%syntax: [Ap,phip,An,phin,f] = bb_azimuth_calc_freq2(z,NFFT,fs,t0);
%
%No scaling is performed on mags - must do scaling in calling function
%
%z must be a m*n matrix, where each row represents a new time-domain vector
%
%--- Ryan Said, 8/3/2006 ---

if(nargin == 4)
    t0 = varargin{1};
else
    t0 = 0;
end

f = [1:NFFT/2-1]/NFFT*fs;
Bf = fft(z,NFFT,2).*repmat(exp(i*2*pi*[0:NFFT-1]/NFFT*fs*t0),size(z,1),1);
Ap = abs(Bf(:,2:NFFT/2));
phip = angle(Bf(:,2:NFFT/2));
An = abs(Bf(:,NFFT:-1:NFFT/2+2));
phin = angle(Bf(:,NFFT:-1:NFFT/2+2));
