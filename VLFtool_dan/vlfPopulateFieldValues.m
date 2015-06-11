function vlfPopulateFieldValues(DF)
% vlfPopulateFieldValues(DF)
% Populates the vlfGui field values with values from the DF struct
% DF should be complete and not malformed. See vlfDefaults.m for required fields for DF
% 
% By Daniel Golden (dgolden1 at stanford dot edu) May 2 2007

% $Id$

h = findobj('Tag', 'sourcePath');
set(h, 'String', DF.sourcePath );
h = findobj('Tag', 'destinPath');
set(h, 'String', DF.destinPath );

h = findobj('Tag', 'maxPlots');
set(h, 'String', num2str(DF.maxPlots));
h = findobj('Tag', 'wildcard');
set(h, 'String', DF.wildcard );
h = findobj('Tag', 'startSec');
set(h, 'String', num2str(DF.startSec) );
h = findobj('Tag', 'endSec');
set(h, 'String', num2str(DF.endSec) );

h = findobj('Tag', 'savePlots');
set(h, 'Value', DF.savePlot );
h = findobj('Tag', 'saveType');
if( strcmp(DF.saveType, 'jpg') );
	set(h, 'Value', 1);
elseif ( strcmp(DF.saveType, 'eps') )
	set(h, 'Value', 2);
end;

if( DF.numRows == 1 )
	h = findobj('Tag', 'row1');
	set(h, 'Value', 1);
	h = findobj('Tag', 'row2');
	set(h, 'Value', 0);
elseif( DF.numRows == 2 );
	h = findobj('Tag', 'row1');
	set(h, 'Value', 1);
	h = findobj('Tag', 'row2');
	set(h, 'Value', 1);
end;

h = findobj('Tag', 'calcPSD');
set(h, 'Value', DF.calcPSD);

h = findobj('Tag', 'useCal');
if( DF.useCal == 0 )
	set( h, 'Value', 3 );
end;
