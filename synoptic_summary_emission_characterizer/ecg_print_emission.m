function ecg_print_emission(event, output_dir, bPNG, bEPS)
% Function to print a single emission to an image file

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

f_lc = max(300, event.f_lc/2);
f_uc = min(10e3, event.f_uc*2);
ecg_zoom_emission([], event.start_datenum, event.end_datenum, db_filename, f_lc, f_uc);

em_type_str = strrep(event.emission_type, ', ', '_'); % Replace commas with underscores

filename = sprintf('%s_%s', datestr(event.start_datenum, 'yyyy-mm-ddTHHMM'), em_type_str);
if bPNG
	print('-dpng', fullfile(output_dir, filename));
end
if bEPS
	print('-depsc', fullfile(output_dir, filename));
end
