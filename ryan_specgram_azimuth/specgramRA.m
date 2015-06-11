function [X,F,T,F_RA,T_RA,S_RA] = specgramRA(x,nfft,Fs,window,noverlap,fullFFTflag)
%syntax: [X,F,T,F_RA,T_RA,S_RA] = specgramRA(x,nfft,Fs,window,noverlap,fullFFTflag)
%
%x is a single channel

X = mySpecgram(x,nfft,Fs,window,noverlap,fullFFTflag);

% -- construct reassignment windows --
Nw = length(window);
if ( mod(Nw,2) )    %odd length window
    Mw = (Nw-1)/2;
    framp = [(0:Mw),(-Mw:-1)]';
    tramp = (-Mw:Mw)';
else
    Mw = Nw/2;
    framp = [(0:Mw-1),(-Mw:-1)]' + 0.5;
    tramp = (-Mw:Mw-1)' + 0.5;
end

%note: without scaling, -imag(ifft(framp.*fft(window)))*2*pi/Nw ~ ([0;diff(h)] +[diff(h);0])/2)

%scale the ramps to the desired units
tramp = tramp/Fs;       % ramp in seconds   (multiply by Fs to get index)
framp = framp * Fs/Nw;  % ramp in Hz (multiply by Nw/Fs to get index)

w_t = tramp.*window;
w_dt = -imag(ifft(framp.*fft(window)));


% -- compute auxiliary spectra --
Xt = mySpecgram(x,nfft,Fs,w_t,noverlap,fullFFTflag);
Xdt = mySpecgram(x,nfft,Fs,w_dt,noverlap,fullFFTflag);


[rows,cols] = size(X);
nonzero = find(abs(X)>0);
% -- compute time corrections --
tcorrect = zeros(rows,cols);
tcorrect(nonzero) = real(Xt(nonzero)./X(nonzero));
T_vec = ([0:cols-1]*(Nw-noverlap) + (Nw-1)/2 )/Fs;
T_mat = ones(rows,1)*T_vec;
T_RA = T_mat + tcorrect; % in seconds

% -- compute frequency corrections --
fcorrect = zeros(rows,cols);
fcorrect(nonzero) = -imag(Xdt(nonzero)./X(nonzero));
if(fullFFTflag)
    F_vec = [0:nfft-1]'*Fs/nfft;   %linear
    %F_vec = [0:nfft/2,nfft/2-1:-1:1]'*Fs/nfft;  %fold over
    F_mat = F_vec*ones(1,cols);
    fcorrect = Fs/2 - abs(fcorrect - Fs/2);
else
    F_vec = [0:nfft/2]'*Fs/nfft;
    F_mat = F_vec*ones(1,cols);
end
% analysis bin frequencies in Hz
F_RA = F_mat + fcorrect;  % in Hz

if(nargout > 5) %compute reassigned spectrogram on T_vec, F_vec grid
    S_RA  = zeros(rows,cols);
    thr_dB = 70; %reassign everything 40 dB down from max
    maxM = max(max(abs(X+eps)));
    Threshold = 10^((20*log10(maxM)-thr_dB)/20);
    %reverse index to real quantity assignment:
    time_index_RA = round((T_RA*Fs - (Nw-1)/2)/(Nw-noverlap) + 1);
    freq_index_RA = round(F_RA*nfft/Fs + 1);
    for jj=1:cols    %cols are t, rows are f
        for ii = 1:rows %Do each time instant at the same time (cycle through rows by column)
            if abs(X(ii,jj))>Threshold
                jj_hat = time_index_RA(ii,jj);
                jj_hat=min(max(jj_hat,1),cols);
                ii_hat= freq_index_RA(ii,jj);
                if(fullFFTflag)
                    ii_hat=rem(rem(ii_hat-1,nfft)+nfft,nfft)+1; %sawtooth from 1:nfft
                else
                    ii_hat = min(max(ii_hat,1),rows);
                end
                %NOTE: add up squared values, not absolute values
                S_RA(ii_hat,jj_hat)=S_RA(ii_hat,jj_hat) + abs(X(ii,jj))^2 ;
            else
                S_RA(ii,jj)=S_RA(ii,jj) + abs(X(ii,jj))^2 ;
            end
        end
    end
end

F = F_vec;
T = T_vec;
