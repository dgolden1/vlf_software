% Run plot_emission_stats in a few ways

% By Daniel Golden (dgolden1 at stanford dot edu) December 2007
% $Id$


close all;
clear;

em_type_vec = {'chorus', 'hiss', 'chorus_only', 'hiss_only', ...
	'chorus_and_hiss', 'chorus_or_hiss'};

pathname = '/home/dgolden/vlf/presentations/2008-06-22_GEM_poster/images';

for kk = 1:length(em_type_vec)
	load(
end

for jj = 1:length(em_type_vec)
	em_type = em_type_vec{jj};
	plot_emission_stats(plotwhat, [], em_type, [], [], hist_type)
	filename = sprintf('hist_dst_norm_%s', em_type);
% 	print('-dpng', fullfile(pathname, filename));
% 	print('-dpdf', fullfile(pathname, filename));
	save(fullfile('~/temp/', [filename '.mat']));
	poster_print(filename);
	close;
end
