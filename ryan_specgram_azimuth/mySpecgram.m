function [B,F,T] = mySpecgram(x,nfft,Fs,window,noverlap,fullFFTflag)
%syntax: [B,F,T] = mySpecgram(x,nfft,Fs,window,noverlap,fullFFTflag)
%accepts one channel (real) or complex channel

nx = length(x);
nwind = length(window);
if nx < nwind    % zero-pad x if it has length less than the window length
    x(nwind)=0;  nx=nwind;
end
x = x(:); % make a column vector for ease later
window = window(:); % be consistent with data set

ncol = fix((nx-noverlap)/(nwind-noverlap));
colindex = 1 + (0:(ncol-1))*(nwind-noverlap);
rowindex = (1:nwind)';
if length(x)<(nwind+colindex(ncol)-1)
    x(nwind+colindex(ncol)-1) = 0;   % zero-pad x
end

y = zeros(nwind,ncol);

% put x into columns of y with the proper offset
% should be able to do this with fancy indexing!
y(:) = x(rowindex(:,ones(1,ncol))+colindex(ones(nwind,1),:)-1);

% Apply the window to the array of offset signal segments.
y = window(:,ones(1,ncol)).*y;

% now fft y which does the columns
y = fft(y,nfft);
if ~any(any(imag(x))) & ~fullFFTflag    % x purely real and don't want full FFT
    select = 1:nfft/2+1;
    y = y(select,:);    %comment this out if want full FFT for real signals
else
    select = 1:nfft;
end
f = (select - 1)'*Fs/nfft;

%t = (colindex-1)'/Fs; ORIGINAL
t = ((colindex-1) + (nwind-1)/2)'/Fs;  %centered around window
B = y;
F = f;
T = t;
