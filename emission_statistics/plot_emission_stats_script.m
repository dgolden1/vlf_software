close all;

addpath(fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence')); % For find_terminator.m

[~, mm] = datevec([events.start_datenum]);
[~, mm_se] = datevec(synoptic_epochs);
  
for kk = 1:12
  plot_emission_stats(events(mm == kk), synoptic_epochs(mm_se == kk), 'cum_spec_v3', 'chorus');
  
  caxis([-20 -16]);
  title(sprintf('Chorus emissions %s', datestr([2000 kk 1 0 0 0], 'mmm')));
  
  [dawn_datenum, dusk_datenum] = find_terminator(-64.77, -64.05, 100e3, datenum([2000 kk 15 0 0 0]));
  dawn_datenum = fpart(dawn_datenum - 4/24); % Convert to Palmer MLT
  dusk_datenum = fpart(dusk_datenum - 4/24); 
  
  yl = ylim;
  hold on;
  plot(dawn_datenum*[1 1], yl, '--', 'linewidth', 4, 'color', [.8 .7 0]); % Yellow
  plot(dusk_datenum*[1 1], yl, '--', 'linewidth', 4, 'color', [.3 .6 1]); % Blue
  
%   print('-dpdf', sprintf('~/temp/cum_spec_chorus_%02d', kk));
  set(gcf, 'color', 'none');
  export_fig(sprintf('/home/dgolden/temp/cum_spec_chorus-%02d', kk-1), '-pdf');
  
  close;
end

% for kk = 2000:2010
%   [yy, ~] = datevec([events.start_datenum]);
%   [yy_se, ~] = datevec(synoptic_epochs);
%   
%   plot_emission_stats(events(yy == kk), synoptic_epochs(yy_se == kk), 'cum_spec_v3', 'hiss');
%   
%   caxis([-20 -16]);
%   title(sprintf('Hiss %04d', kk));
%   
%   print('-dpng', '-r70', sprintf('~/temp/cum_spec_hiss_%04d', kk));
% end
