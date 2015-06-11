function convert_nldn_text_to_bin_daily
% convert_nldn_text_to_bin_daily
% Convert ASCII NLDN files to Matlab files, one for each day

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

%% Setup
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
        case 'polarbear'
			source_dir = '~/input/nldn/';
			dest_dir = '~/input/nldn/daily/';
        case 'quadcoredan.stanford.edu'
			source_dir = '/home/dgolden/vlf/case_studies/nldn';
			dest_dir = '/home/dgolden/vlf/case_studies/nldn/daily';
        otherwise
               error('Unknown host (%s)', hostname(1:end-1));
end


fclose all;

%% Process
d = dir(fullfile(source_dir, '*.asc'));

for kk = 1:length(d)
	fid = fopen(fullfile(source_dir, d(kk).name));

	t_start = now;
	disp(sprintf('Reading %s', d(kk).name));
	
	C = textscan(fid, '%f/%f/%f %f:%f:%f %f %f %f %f %s');
	disp(sprintf('Read %d lines in %0.0f seconds', length(C{1}), (now - t_start)*86400));
	fclose(fid);
	
	%% Convert to output struct
	nlines = length(C{1});
	
	nldn_full.date = datenum([C{3}+2000 C{1} C{2} C{4} C{5} C{6}]);
	nldn_full.nstrokes = C{7};
	nldn_full.lat = C{8};
	nldn_full.lon = C{9};
	nldn_full.peakcur = C{10};
	nldn_full.g = strcmp('G', C{11});
	
	[yy, mm, dd, HH, MM, SS] = datevec([max(nldn_full.date), min(nldn_full.date)]);
	if mm(1) ~= mm(2)
		error('Input file contains data from more than one month');
	end
	
	file_start_date = datenum([yy(1) mm(1) 1 0 0 0]);
	file_end_date = datenum([yy(1) mm(1)+1 1 0 0 0]);
	file_dates = file_start_date:file_end_date;
	
	for kk = 1:(length(file_dates) - 1)
		idx = nldn_full.date >= file_dates(kk) & nldn_full.date < file_dates(kk+1);
		
		nldn.date = nldn_full.date(idx);
		nldn.nstrokes = nldn_full.nstrokes(idx);
		nldn.lat = nldn_full.lat(idx);
		nldn.lon = nldn_full.lon(idx);
		nldn.peakcur = nldn_full.peakcur(idx);
		nldn.g = nldn_full.g(idx);
		
		output_filename = ['nldn' datestr(file_dates(kk), 'yyyymmdd'), '.mat'];
		save(fullfile(dest_dir, output_filename), '-struct', 'nldn');
		disp(sprintf('Saved %s (t = %0.0f sec)', output_filename, (now - t_start)*86400));
	end
end
