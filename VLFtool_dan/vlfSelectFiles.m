function vlfSelectFiles
% Function to initiate a file selection dialogue
% Also calls vlfMakePage to make the spectrogram(s)
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) Apr 2007

% $Id$

global DF;
global ALLDATA;

DF.pathname = [];
DF.filename = [];
% [filename, pathname] = uigetfile(DF.sourcePath, ...
% 	'*.mat', 'MultiSelect', 'On');

[filename, pathname] = uigetfile('*.mat', 'Data Files', DF.sourcePath, ...
  'MultiSelect', 'On');

if( iscell( filename ) )
	for( k = 1:size( filename, 2 ) )
		DF.pathname{k} = pathname;
		DF.filename{k} = filename{k};
	end;
elseif( ischar( filename ) )
	DF.pathname{1} = pathname;
	DF.filename{1} = filename;
elseif( filename == 0 )
	return;
end;

DF.filename = sort( DF.filename );


DF.numPlots = length(DF.filename);
if( DF.maxPlots == -1 )
    DF.maxPlots = DF.numPlots;
end;

if( DF.numPlots > DF.maxPlots )
    DF.maxPlots = DF.numPlots;
end;


if (ALLDATA)
   whFullDataPlots;
else
    fighandle = vlfNewFigure( 'bbfig1' );
	try
		vlfMakePage;
	catch
		% If we generated an error while working with the file in
		% vlfMakePage, close the figure that vlfNewFigure created, because
		% it annoys the hell out of me --Dan.
		if fighandle ~= -1, close(fighandle); end
		rethrow(lasterror);
	end
	
    if( DF.savePlot == 1 )
        vlfSavePlot;
    end;
end



