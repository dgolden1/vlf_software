function plot_some_narrowband_burstiness_stuff(s_nb, t_nb, fc, bottom_freq, top_freq, freq_skip, plotwhat)
% Function to plot a bunch of the narrowband filters from
% test_burstiness_analysis.m in different ways.
% 
% Stick a breakpoint before the "output_filename = [name '_burst_norm'];"
% line in test_burstiness_analysis, and then run this function

% By Daniel Golden (dgolden1 at stanford dot edu) October 2009
% $Id$

% bottom_freq = 1400;
% top_freq = 3600;
% freq_skip = 600;

freq_vec = top_freq:-freq_skip:bottom_freq; % Reverse order!

% plotwhat = 'hist';
% plotwhat = 'ampl';
% plotwhat = 'ampl_db';

figure;
nplots = length(freq_vec);
for kk = 1:nplots
  s(kk) = subplot(nplots, 1, kk); %#ok<AGROW>
  switch plotwhat
    case 'hist'
      n = histc(db(s_nb(fc == freq_vec(kk), :)), -30:2:40);
      bar(-29:2:41, n, 'barwidth', 1);
      ylabel('count');
      mu = mean(db(s_nb(fc == freq_vec(kk), :)));
      med = median(db(s_nb(fc == freq_vec(kk), :)));
      sigma = std(db(s_nb(fc == freq_vec(kk), :)));
      title(sprintf('%d Hz, \\mu = %0.0f dB, med = %0.0f dB, \\sigma = %0.2f dB', freq_vec(kk), mu, med, sigma));
    case 'ampl'
      plot(t_nb, abs(s_nb(fc == freq_vec(kk), :)));
      ylabel('uncal ampl');
      title(sprintf('%d Hz', freq_vec(kk))); 
    case 'ampl_db'
      plot(t_nb, db(s_nb(fc == freq_vec(kk), :)));
      ylabel('uncal dB');
      title(sprintf('%d Hz', freq_vec(kk))); 
  end
  
  grid on;
end

switch plotwhat
  case 'hist'
    xlabel('uncal dB');
  case {'ampl', 'ampl_db'}
    xlabel('Sec');
end

linkaxes(s);
