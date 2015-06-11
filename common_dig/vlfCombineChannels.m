function vlfCombineChannels(file1, file2)
% Function to take two broadband files, representing two vlf channels (or
% one file with interleaved data), combine the channels' amplitudes (sqrt
% of the sum of the squares), and resave the data

% By Daniel Golden (dgolden1 at stanford dot edu) July 2008
% $Id$

%% Setup
error('I never got this crappy function to work. --Dan');

error(nargchk(1, 2, nargin));
MAX_FILE_SIZE_BYTES = 100e6;

%% Determine whether it's one interleaved file or two non-interleaved files
if exist('file2', 'var')
	bIsInterleaved = false;
else
	bIsInterleaved = true;
end

%% File size check
d = dir(file1);
if d.bytes > MAX_FILE_SIZE_BYTES
	error('%s is too big (%0.0f MB). Max file size is %0.0f MB.', file1, d.bytes/1e6, MAX_FILE_SIZE_BYTES/1e6);
end
if ~bIsInterleaved
	d = dir(file2);
	if d.bytes > MAX_FILE_SIZE_BYTES
		error('%s is too big (%0.0f MB). Max file size is %0.0f MB.', file2, d.bytes/1e6, MAX_FILE_SIZE_BYTES/1e6);
	end
end

%% Interleaved
if bIsInterleaved
	S = load(file1);
	
	% Combine
	data1 = S.data(1:2:end);
	data2 = S.data(2:2:end);
	S.data = int16(sqrt(data1.^2 + data2.^2));
	clear('data1', 'data2');
	
	% Save
	[pathstr, name, ext] = fileparts(file1);
	save_filename = fullfile(pathstr, [name '_comb' ext]);
	save(save_filename, '-struct', 'S', '-version', '-v4');

%% Non-interleaved
else
	S1 = load(file1);
	S2 = load(file2);
	
	% Combine
	data1 = S1.data;
	data2 = S2.data;
	S1.data = int16(sqrt(data1.^2 + data2.^2));
	clear('data1', 'data2');
	
	% Save
	[pathstr, name, ext] = fileparts(file1);
	bChanNoReplaced = false;
	
	chan_no_strings = {'001', '002', '003'};
	for kk = 1:length(chan_no_strings)
		chan_no = chan_no_strings{kk};
		if ~isempty(strfind(name, chan_no))
			name = strrep(name, chan_no, 'comb');
			bChanNoReplaced = true;
		end
	end
	if ~bChanNoReplaced
		error('Channel number should be one of %s, %s or %s', chan_no_strings{1}, chan_no_strings{2}, chan_no_strings{3});
	end
	save_filename = fullfile(pathstr, [name ext]);
	save(save_filename, '-struct', 'S1', '-v4');
	
end
