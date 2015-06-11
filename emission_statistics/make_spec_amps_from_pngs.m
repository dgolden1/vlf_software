% make_spec_amps_from_pngs
% Script to cycle through all spectrogram PNGs and make amplitude matrices
% for them

% By Daniel Golden (dgolden1 at stanford dot edu) January 2007
% $Id$

%% Setup
global bCal
bCal = true;

%% Choose directories based on host
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
% 	case 'vlf-alexandria'
	case 'quadcoredan.stanford.edu'
		sourcedir = '/home/dgolden/vlf/case_studies/chorus_2003/synoptic_summary_plots';
		destdir = '/home/dgolden/temp/spec_amps';
	case 'polarbear'
		sourcedir = '/home/dgolden1/input/synoptic_summary_plots';
		destdir = '/home/dgolden1/input/synoptic_summary_plots/spec_amps';
	otherwise
		error('Unknown host %s', hostname(1:end-1));
end

%% Parallel
PARALLEL = true;

if ~PARALLEL
	warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
	matlabpool('open', maxNumCompThreads);
end
if ~PARALLEL && poolsize ~= 0
	matlabpool('close');
end

%% Process
files = dir(fullfile(sourcedir, '*.png'));

for kk = 1:length(files)
	time_start = now;
	[pathstr, name, ext] = fileparts(files(kk).name);

	dest_filename = fullfile(destdir, [name '.mat']);
	if exist(dest_filename, 'file'), continue; end

	spec_amp = flipud(get_amp_from_spec(fullfile(sourcedir, files(kk).name)));
	f = linspace(300, 10e3, size(spec_amp, 1));
	t = linspace(0, 1, size(spec_amp, 2)); % These times are approximate!
	if b_cal
		unit_str = 'dB-fT/Hz^{1/2}';
	else
		unit_str = 'uncal';
	end
	save(dest_filename, 'spec_amp', 'f', 't', 'unit_str');
	time_end = now;
	disp(sprintf('Processed %s (file %d of %d) in %0.0f seconds', [name ext], kk, length(files), (time_end - time_start)*86400));
end
