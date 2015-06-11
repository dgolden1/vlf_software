function whTarcsaiSelectWhistlers
% Serves identical puspose as whSelectWhistler.  However, it can convert
% multiple wh files into tarcsai files.  Also, it does not graph the
% calculated values on the spectrogram.  
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 7 2007

% $Id$

global DF

source = get(findobj('Tag','destination'),'String');
if (isempty(source))
    source = DF.destinPath;
end
if (source(end) ~= filesep)
    source(end+1) = filesep;
end

% Code which allows the user to select the data files containing the
% whistlers he wants to analyze
[filename, pathname] = uigetfile('*_wh*.mat', 'Select Whistler',...
    source, 'MultiSelect', 'On');

if ischar(filename) % Only selected one file
	temp = filename;
	filename = cell(1);
	filename{1} = temp;
end

if ~iscell(filename), return; end

numiterations = length(filename);

for n = 1:numiterations
	load(fullfile(pathname, filename{n}));
	
	disp(sprintf('\nRunning tarcsai analysis on %s', filename{n}));

	% If the user didn't specify a sferic time, set it to the first whistler
	% time value minus 0.8 seconds
	if wh.sferic == -1, wh.sferic = wh.time(1) - 0.8; end

	timev = wh.time - wh.sferic; % Time vector with sferic time as origin
	freqv = wh.freq;
	sferic_time = wh.sferic;

	model = []; % Use default model
	
	try
		run_tarcsai_analysis(wh, sferic_time, timev, freqv, model, filename{n}, pathname);
	catch
		er = lasterror;
		warning(er.identifier, sprintf('[%s]\n%s', filename{n}, er.message)); %#ok<SPWRN>
		continue;
	end
end
