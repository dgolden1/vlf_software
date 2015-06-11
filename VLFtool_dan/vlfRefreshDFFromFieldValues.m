function vlfRefreshDFFromFieldValues
% DF = vlfRefreshDFFromFieldValues
% Grabs values for the DF struct from vlfGui field values
% 
% By Daniel Golden (dgolden1 at stanford dot edu) May 3 2007

% $Id$

global DF

h = findobj('Tag', 'sourcePath');
DF.sourcePath = get(h, 'String');
if( DF.sourcePath(end) ~= DF.dirChar )
	DF.sourcePath = [DF.sourcePath DF.dirChar];
end;

h = findobj('Tag', 'destinPath');
DF.destinPath = get(h, 'String');
if( DF.destinPath(end) ~= DF.dirChar )
	DF.destinPath = [DF.destinPath DF.dirChar];
end;

h = findobj('Tag', 'maxPlots');
DF.maxPlots = str2num(get(h, 'String'));
h = findobj('Tag', 'wildcard');
DF.wildcard = get(h, 'String');
h = findobj('Tag', 'startSec');
DF.startSec = str2num(get(h, 'String'));
h = findobj('Tag', 'endSec');
DF.endSec = str2num(get(h, 'String'));

h = findobj('Tag', 'savePlots');
DF.savePlot = get(h, 'Value');
h = findobj('Tag', 'saveType');
type = get(h, 'Value');
if( type == 1 )
	DF.saveType  = 'jpg';
else
	DF.saveType  = 'eps';
end;

row1 = get(findobj('Tag', 'row1'), 'Value');
row2 = get(findobj('Tag', 'row2'), 'Value');
if ( row2 )
	DF.numRows = 2;
else
	DF.numRows = 1;
end;

h = findobj('Tag', 'calcPSD');
DF.calcPSD = get(h, 'Value' );

h = findobj('Tag', 'colorScale');
DF.colorScale = get(h, 'Value');
if( DF.colorScale == 2 )
	DF.colorScale = -1;
end;

h = findobj('Tag', 'useCal');
type = get(h, 'Value');
if( type == 1 | type == 2 )
	DF.useCal = 1;
else
	DF.useCal = 0;
end;
if( type == 1 )
	DF.units = 'density';
else
	DF.units = 'power';
end;
