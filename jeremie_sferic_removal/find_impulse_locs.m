function imp_centers = find_impulse_locs(signal, pw, threshold_lvl, fs, b_slowtail_filter)
% imp_centers = find_impulse_locs(signal, pw, threshold_lvl, fs, b_slowtail_filter)
% 
% INPUTS
% signal: input signal
% pw: the length of signal (in samples) you need to replace
% threshold_lvl: is an adjustable value which amounts to a level of
%  impulse necessary before the algorithm decides to correct
% fs: sampling frequency
% b_slowtail_filter: true to filter sferic slowtails out of signal (allows
% better peak detection of broadband sferics).
% 
% OUTPUT:
% The function returns a vector which contains the locations in signal
%  which are in error.

% Originally by Jeremie Papon (jpapon at gmail dot com)
% Modified by Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

if(nargin<3)
    threshold_lvl = 15;
end

%% Highpass filter data to remove sferic slow tails
if b_slowtail_filter
  Fstop = 500;    % Stopband Frequency
  Fpass = 1000;   % Passband Frequency
  Astop = 60;     % Stopband Attenuation (dB)
  Apass = 1;      % Passband Ripple (dB)

  h = fdesign.highpass('fst,fp,ast,ap', Fstop, Fpass, Astop, Apass, fs);
  Hd = design(h, 'butter', 'MatchExactly', 'stopband');
  signal = filter(Hd, signal(:));
end

%% Find impulses
temp = signal(:);
win = 100;
kaiwin = kaiser(win,1);
P = 15;
p_vec = win+1:2:length(temp);

evals= zeros(1,length(temp));
evals_temp = zeros(1, length(p_vec));

warning('Parfor disabled!');
for kk = 1:length(p_vec)
% parfor kk = 1:length(p_vec)
  p = p_vec(kk);
    window = kaiwin.*temp(p-win:p-1);
    [w,A,sbc,fpe] = arfit(window,P,P);
    temp_y = fliplr(window(end-P+1:end));
    evals_temp(kk) = abs(temp(p) - sum(A*temp_y)); 
end
evals(p_vec) = evals_temp;


pr = ceil(pw/2);
mean_error = mean(evals);
maxval = find(evals == max(evals), 1);
p = 1;
while(evals(maxval) > threshold_lvl * mean_error)
  nb4 = min(30, maxval-1);
  naft = min(30, length(signal) - maxval);
    temp = signal(maxval-nb4:maxval+naft).^2;
    adjmax = find(temp == max(temp), 1);
    imp_centers(p) = maxval-(nb4+1-adjmax);
    evals(imp_centers(p)-pr+(nb4+1-adjmax):imp_centers(p)+pr+(nb4+1-adjmax)) = 0;
  
%     temp = signal(maxval-30:maxval+30).^2;
%     adjmax = find(temp == max(temp), 1);
%     imp_centers(p) = maxval-(31-adjmax);
%     evals(imp_centers(p)-pr+(31-adjmax):imp_centers(p)+pr+(31-adjmax)) = 0;
  
    p = p +1;
    maxval = find(evals == max(evals), 1);
end
if(p == 1)
    imp_centers = [];
end
