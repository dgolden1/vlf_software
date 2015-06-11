function whTarcsaiPlotSingle(filename, target_time, file_start_time, file_end_time)
% whTarcsaiPlotSingle(filename)
% Plot a piece of a single file. Used when running Tarcsai analysis, to
% bring up a plot of the whistler that's being analyzed

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

global DF

%% Choose start and end times of plot
% We'll assume that target_time is the time of the sferic, so pick two
% seconds before and 5 seconds after to plot
start_time = target_time - 2/86400;
if start_time < file_start_time, start_time = file_start_time; end
end_time = target_time + 5/86400;
if end_time > file_end_time, end_time = file_end_time; end

% Set the start and end times of the GUI to reflect what we're about to plot
h = findobj('Tag', 'startSec');
set(h, 'String', num2str(floor((start_time - file_start_time)*86400)));
h = findobj('Tag', 'endSec');
set(h, 'String', num2str(floor((end_time - file_start_time)*86400)));


%% Set up the DF field for plotting a la vlfSelectFiles.m
[pathstr, name, ext] = fileparts(filename);
DF.pathname{1} = pathstr;
DF.filename{1} = [name ext];
DF.numPlots = 1;
DF.maxPlots = 1;

%% Plot it
fighandle = vlfNewFigure( 'bbfig1' );
vlfMakePage;
