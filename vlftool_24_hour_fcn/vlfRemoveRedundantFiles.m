function d = vlfRemoveRedundantFiles(d)
% Function that removes all of the 003 files if 002 (N/S) and 003 (E/W)
% files are selected

% $Id$

pos_002s = cellfun(@(x) ~isempty(x), strfind(d, '_002'));
pos_003s = cellfun(@(x) ~isempty(x), strfind(d, '_003'));

%% If this is a different file format, don't do anything
if sum(pos_002s) == 0 || sum(pos_003s) == 0
	return;
end

%% Remove 003 files
d = d(pos_002s);

%% Discard files that don't have an 002 and 003 file
% name_002s = d(pos_002s);
% name_003s = d(pos_003s);
% 
% num_002s = length(name_002s);
% if num_002s == 0
% 	return;
% end
% 
% % Confirm that each 002 file has an associated 003 file, and discard the
% % ones that don't
% mask = true(size(name_002s));
% for kk = 1:length(name_002s)
% 	target_003 = strrep(name_002s{kk}, '002.mat', '003.mat');
% 	if all(cellfun(@(x) isempty(x), strfind(name_003s, target_003)))
% 		mask(kk) = false;
% 	end
% end
% 
% d = name_002s(mask);
