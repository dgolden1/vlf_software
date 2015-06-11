function make_nldn_date_files(year, output_dir)
% Make files for getting NLDN data from Ryan

% Ryan Says...
% make 12 .txt files, one for each month.  Call them jan.txt, feb.txt, etc ...
% 
% In each .txt file, place one line per day.  Each line should read:
% mm/dd/year 00:00:00 mm/dd/year 23:59:59
% 
% For example, the july 27th request would read as 
% 07/27/2003 00:00:00 07/27/2003 23:59:59

for mm = 1:12
	mm_str = lower(datestr(datenum([0 mm 1 0 0 0]), 'mmm'));
  this_filename = fullfile(output_dir, [mm_str '.txt']);
	fid = fopen(this_filename, 'w');

	dd = 1;
	date_vec = [year mm dd 0 0 0];
	while date_vec(2) == mm
		str = sprintf('%s 00:00:00 %s 23:59:59\r\n', datestr(date_vec, 'mm/dd/yyyy'), datestr(date_vec, 'mm/dd/yyyy'));
		fprintf(fid, str);
% 		disp(str);
		
		dd = dd + 1;
		date_vec = datevec(datenum([year mm dd 0 0 0]));
	end
	fclose(fid);
	fprintf('Wrote %s\n', this_filename);
end
