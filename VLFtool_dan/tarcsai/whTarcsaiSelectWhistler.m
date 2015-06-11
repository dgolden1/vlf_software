function varargout = whTarcsaiSelectWhistler
% bMadeImage = whTarcsaiSelectWhistler
% 
% bMadeImage is true if this function plotted data; false otherwise
% 
% function called when the user selects a data set.  Prints the answers to
% the gui
% By Adam Richards
% Modified by Daniel Golden (dgolden1 at stanford dot edu) Apr 2007

% $Id$

% time vector fed into the TARCSAI function is calculated in two ways.
% 1) if there is no sferic defined in the whistler file, the first time in
% the array of times defining the whistler is subtracted from all given
% times.  .8 is then added.  Thus, the sferic is arbitrarily defined to
% have happened .8 seconds before the nose point of the whistler.  The
% final sferic time given by the TARCSAI program will then be relative to
% .6 seconds before the first time in the whistler time array.
% 2) if there is a sferic defined, the value of the sferic is subtracted
% from all of the time values.  The predicted sferic value offerd by the
% TARCSAI program will then be time relative to the user defined sferic
% time.

%% Globals
global DF
global D_HANDLES
global START_HANDLE
clear global WHISTLER
global WHISTLER


%% Dialog to select file
source = get(findobj('Tag','destination'),'String');
if (isempty(source))
    source = DF.destinPath;
end
if (source(end) ~= filesep)
    source(end+1) = filesep;
end

% Code which allows the user to select the data file containing the
% whistler he wants to analyze
[wh_filename, wh_pathname] = uigetfile('*_wh*.mat', 'Select Whistler',...
    source, 'MultiSelect', 'Off');

% Quit if user pressed 'Cancel'
if ~ischar(wh_filename)
    if nargout >= 1
        varargout{1} = false; % bMadeImage = false
    end
    return;
end

% Delete any previous whistler traces that we may have had
whTarcsaiClearDataPoints;

load(fullfile(wh_pathname, wh_filename));
if ~exist('wh', 'var')
	error('''wh'' variable does not exist in selected whistler file');
end

%% Set up variables with whistler data
WHISTLER = wh; % make a global copy of the whistler data.  used to allow user to graph the data points.

% If the user didn't specify a sferic time, set it to the first whistler
% time value minus 0.8 seconds
if wh.sferic == -1, wh.sferic = wh.time(1) - 0.8; end

timev = wh.time - wh.sferic; % Time vector with sferic time as origin
freqv = wh.freq;
sferic_time = wh.sferic;


%% Determine whether the spectrogram still exists
whClearOverlay;

s = findobj('Tag','spec_axis'); % find the axis
h = findobj('Tag', 'spec_image'); % image of spectrogram

% % If the spectrogram has been closed, don't try plotting anything
% if isempty(s) || isempty(h)
%     if nargout >= 1
%         varargout{1} = false; % bMadeImage = false
%     end
% 	return;
% end

%% Replot the whistler spectrogram if something ain't right about it
whistler_start = wh.startFileDate + min([wh.sferic wh.time])/86400;
whistler_end = wh.startFileDate + max([wh.sferic wh.time])/86400;

% Re-plot the whistler if the current plot either has the wrong data or
% doesn't exist
bReplotSpec = false;
if isempty(s) || isempty(h) % If the spectrogram doesn't exist...
	bReplotSpec = true;
end

% If these variables weren't created (which are usually created with the
% spectrogram)...
if ~isfield(DF, 'bbrec') || ~(isfield(DF.bbrec, 'startDate') && isfield(DF.bbrec, 'startDate') &&...
		isfield(DF, 'endSec') && isfield(DF, 'startSec'))
	bReplotSpec = true;
else
	% if the spectrogram exists, but is in the wrong range...
	spec_start = DF.bbrec.startDate;
	spec_end = DF.bbrec.startDate + (DF.endSec - DF.startSec)/86400;
	if spec_start > whistler_start || spec_end < whistler_end
		bReplotSpec = true;
	end
end

if bReplotSpec
	sferic_absolute_time = wh.startFileDate + sferic_time/86400;
	
	% Find the file that contains the date of the human-selected sferic
	[bb_filename, file_start_time, file_end_time] = whTarcsaiFindFileWithDate(sferic_absolute_time, DF.sourcePath);
	
	% Plot the portion of that file that contains the whistler
	whTarcsaiPlotSingle(bb_filename, sferic_absolute_time, file_start_time, file_end_time);
	
	% This junk will have changed if we regenerated the plot
	s = findobj('Tag','spec_axis'); % find the axis
	h = findobj('Tag', 'spec_image'); % image of spectrogram
	
% 	errormsg = sprintf(['Plotted whistler spectrogram does not contain whistler time points.\n' ...
% 						'Ensure that the spectrogram has data from %s to %s'], ...
% 						datestr(whistler_start), datestr(whistler_end));
% 	error(errormsg);
end

axes(s);

% convert frequency values to Hz for the units to work in the time
% equation
freq = get(h,'ydata')*1000;
freq(freq==0) = .00000001;


%% Run Tarcsai analysis
disp(sprintf('Running tarcsai analysis on %s', wh_filename));

modelnames = get(findobj('Tag','tarcsai_modellist'), 'String');
model = modelnames{get(findobj('Tag','tarcsai_modellist'), 'Value')};

try
	tarcsai_result = run_tarcsai_analysis(wh, sferic_time, timev, freqv, model, wh_filename, wh_pathname);
catch er
	showDataPoints; % Show the data points, even if the Tarcsai analysis didn't converge
	rethrow(er);
end


%% Display the results in the window
set (findobj('Tag','tarcsai_modelfield'),'String',tarcsai_result.DensityModel);
set (findobj('Tag','tarcsai_dcifield'),'String',num2str(tarcsai_result.Dci));
set (findobj('Tag','tarcsai_dofield'),'String',[num2str(tarcsai_result.D0,3) ' +/- ' num2str(tarcsai_result.sigma_D0,3) ' sec^(1/2)']);
set (findobj('Tag','tarcsai_fheqfield'),'String',[num2str(tarcsai_result.fHeq/1e3,3) ' +/- ' num2str(tarcsai_result.sigma_fHeq/1e3,3) ' kHz']);
% T given is the sferic value estimated above plus the T value
% returned by the Tarcsai script
set (findobj('Tag','tarcsai_tfield'),'String',[num2str(tarcsai_result.sferic_calc,'%0.2f') ' +/- ' num2str(tarcsai_result.sigma_T,'%0.2f') ' sec']);
set (findobj('Tag','tarcsai_lfield'),'String',[num2str(tarcsai_result.L,3),' +/- ',num2str(tarcsai_result.sigma_L,3)]);
set (findobj('Tag','tarcsai_neqfield'),'String',[num2str(tarcsai_result.neq,3),' +/- ',num2str(tarcsai_result.sigma_neq,3),' cm^-3']);

set (findobj('Tag','tarcsai_stationfield'),'String',wh.station);
set (findobj('Tag','tarcsai_datefield'),'String',datestr(wh.UT,'dd-mmm-yyyy'));
set (findobj('Tag','tarcsai_timefield'),'String',datestr(wh.UT,'HH:MM:SS'));


%% Draw the calculated whistler curve and sferic

% In case the current spectrogram was plotted with a different x-axis than the one on which whistler
% points were taken, reconcile the difference
xlimit = xlim;

% draws a vertical line at time t0
START_HANDLE = whTarcsaiMarkSferic(s, tarcsai_result.sferic_calc, 'k');
% START_HANDLE = plot(s,(tarcsai_result.sferic_calc)*ones(1,length(freq)),freq/1000,'-','linewidth',3,'Color','k');

% Equation taken from se_tarcsai
t = tarcsai_result.D0 ./ sqrt(freq) .* (tarcsai_result.fHeq - (tarcsai_result.A).*freq) ./ (tarcsai_result.fHeq - freq) + ...
	tarcsai_result.Dci ./ sqrt(freq) - tarcsai_result.T;

D_HANDLES(1) = plot(s,t+sferic_time,freq/1000,'-','linewidth',3,'Color','k');

% Bring the spectrogram and the tarcsai gui to the foreground
figure(DF.fig);
figure(findobj('Tag','tarcsaifig'));

if nargout >= 1
   varargout{1} = true; % bMadeImage = true 
end

%% Play with calculated curve checkboxes
h_showest = findobj('Tag', 'tarcsai_showest_check');
set(h_showest, 'Enable', 'on', 'Value', 1);


%% Function: showDataPoints
function showDataPoints
% Draw the data points on the spectrogram

% Enable the checkboxes and turn them on
h_showdata = findobj('Tag', 'tarcsai_showdata_check');
set(h_showdata, 'Enable', 'on');

% Display the data points
whTarDisWhistler;

% Set the "Show Data Points" checkbox to be on
set(h_showdata, 'Value', 1);


