function vlf_process_24_dan(varargin)
% vlf_process_24_dan(file_dir, output_dir, startSec)
% vlf_process_24_dan(filenames, output_dir, startSec)
% 
% Function to process 24-hours of synoptic data to make a summary
% spectrogram

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

%% Setup
error(nargchk(2, 3, nargin));

if iscell(varargin{1})
	full_filenames = varargin{1};
elseif ischar(varargin{1})
	file_dir = varargin{1};
end

output_dir = varargin{2};
if nargin >= 3
	startSec = varargin{3};
else
	startSec = 0;
end

%% Process

if exist('file_dir', 'var')
	d = [dir(fullfile(file_dir, '*.mat')); dir(fullfile(file_dir, '*.MAT'))];
	filenames = unique({d.name});
	full_filenames = cellfun(@(x) fullfile(file_dir, x), filenames, 'uniformoutput', false);
end

endSec = startSec + 5;
bSavePlot = true;
numRows = 2;
f_uc = [40e3 10e3];
f_lc = [300 300];
bContSpec = false;
bProc24 = true;
dbOffset = 0;

vlftoolfcn(full_filenames, startSec, endSec, bSavePlot, output_dir, numRows, f_uc, f_lc, bContSpec, bProc24, dbOffset);
increase_font(gcf, 14);
