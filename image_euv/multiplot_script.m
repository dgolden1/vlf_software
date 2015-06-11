% palmer_single_day_multiplot script

fits_dir = '/home/dgolden/vlf/case_studies/image_euv_2001/fits';
multiplot_dir = '/home/dgolden/temp/multiplots';

d = dir(fullfile(fits_dir, '2001-*'));

for kk = 1:length(d)
	year = 2001;
	month = str2double(d(kk).name(6:7));
	day = str2double(d(kk).name(9:10));
	palmer_single_day_multiplot(datenum([year month day 0 0 0]));
	orient tall;
	print('-dpsc', fullfile(multiplot_dir, sprintf('palmer_multiplot_%04d_%02d_%02d.ps', year, month, day)));
	close;
end
