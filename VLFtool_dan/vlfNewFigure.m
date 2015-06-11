function fighandle = vlfNewFigure( tag )
%function newfighandle = vlfNewFigure( tag )
%
% Creates a new figure for spectrogram plotting or manipulates an existing one.
% Also adds the "Whistler Analysis" menu item to the figure menu
% 
% Output:
%  fighandle -- Handle to the figure created by vlfNewFigure
%
% by Adam Richards (richarad@stanford.edu)
% Modified December 19, 2006 by Daniel Golden (dgolden1@stanford.edu)

% $Id$

global DF;


figWidth = 10.5;
figHeight = 4*DF.numRows;

myfig = findobj('Tag', tag );
if ( isempty( myfig ) )
    DF.fig = figure;
	fighandle = DF.fig;
    set( DF.fig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
        'Units', 'inches', 'Tag', tag);
    figpos = [ 1 1 figWidth figHeight ];
    set(DF.fig, 'position', figpos );
else
    figure(myfig);
	fighandle = myfig;
	DF.fig = myfig;
	if( ~DF.process24 )
    	clf;
	end;
end;


figure(DF.fig);



% Add the "Whistler Analysis" menu item to the spectrogram menu bar
myMenuHandle = uimenu(DF.fig,'Label','Whistler Analysis') ;
% uimenu(myMenuHandle,'Label','Set Points','Callback','whGetPoints') ;
uimenu(myMenuHandle,'Label','Set Points','Callback','whAnalysisGUI') ;
uimenu(myMenuHandle,'Label','Overlay','Callback','whOverlayGUI') ;
uimenu(myMenuHandle,'Label','TARCSAI','Callback','whTarcsai') ;
uimenu(myMenuHandle,'Label','Color Manipulation','Callback','whColor') ;
uimenu(myMenuHandle,'Label','Make Plots','Callback','whMakePlots') ;


% UNITS OF INCHES
bottom = 0.56;
top = 1.00;
left = 0.735;
right = 0.525;

vspace = 0.200;
cbar = 0.2625;

width = (figWidth-left-right-cbar)./DF.maxPlots;
height = (figHeight-bottom-top-vspace*(DF.numRows-1))/DF.numRows;

titleX = 10.5 / 2;
titleY = figHeight - 0.3;

% NORMALIZED UNITS
DF.bottom = bottom./figHeight;
DF.top = top./figHeight;
DF.height = height/figHeight;
DF.vspace = vspace./figHeight;

DF.left = left./figWidth;
DF.right = right./figWidth;
DF.cbar = cbar./figWidth;
DF.width = width./figWidth;

DF.titleX = titleX/figWidth;
DF.titleY = titleY/figHeight;
