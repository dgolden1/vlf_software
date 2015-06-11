function filenames_out = prune_irregular_synoptic_files(filenames)
% Get rid of extra files (sometimes people record more than the usual
% 1-every-15 minute synoptic files at :05, :20, :35 and :50)
% 
% filenames should be a cell array
% 
% Files are rejected if their "minute" number isn't 05, 20, 35 or 50,
% regardless of their "second" number

% By Daniel Golden (dgolden1 at stanford dot edu) December 2008
% $Id$

START_MINUTE = 5;
INTERVAL = 15;

mask = true(1, length(filenames));
for kk = 1:length(filenames)
	bb_datenum = get_bb_fname_datenum(filenames{kk});
	[y, m, d, hh, mm, ss] = datevec(bb_datenum);
	mm = round(mm + ss/60); % Matlab has stupid roundoff errors using datevec
	if mod((mm - START_MINUTE), INTERVAL) ~= 0 % If this file doesn't start on :05, :20, :35 or :50, ditch it
% 		disp(sprintf('Ditching %s', filenames{kk}));
		mask(kk) = false;
	end
end

filenames_out = filenames(mask);

if isempty(filenames_out)
	error('prune:noFilesLeft', 'All files pruned; none left!');
end
