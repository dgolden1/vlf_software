function vlfNewFigure( tag )

global DF;

horizMargin = 5;

figWidth = 10.5 - horizMargin;
if( DF.numRows == 2 )
  figHeight = 6;
else
  figHeight = 4;
end;

myfig = findobj('Tag', tag );
if ( ~isempty( myfig ) )
  
  set(0,'CurrentFigure',myfig);
  DF.fig = myfig;
  if( DF.process24 < 2 )
    clf;
    DF.h_ax = [];
    DF.h_cb = [0 0];
  end;
elseif isfield(DF, 'h_axes') && ~isempty(DF.h_axes) && ishandle(DF.h_axes) % User-specified axes
  if ~DF.bContSpec
    error('When manually specifying an axis with DF.h_axes, DF.bContSpec must be true.');
  end
  
  DF.fig = get(DF.h_axes, 'parent');
  set(0, 'CurrentFigure', DF.fig);
  set(DF.fig, 'CurrentAxes', DF.h_axes);
  
else
  DF.fig = figure('MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
    'Units', 'inches', 'Tag', tag, 'Visible', 'off', 'BackingStore', 'off');
  figpos = [ 2.25 3 figWidth+horizMargin figHeight ];
  % 	if ~DF.bContSpec
  % 	    set(DF.fig, 'position', figpos );
  % 	end
  
  if( DF.hideFigure == 0 )
    set(DF.fig, 'Visible', 'on');
  end;
  
  set(0,'CurrentFigure',myfig);
  DF.h_ax = [];
  DF.h_cb = [0 0];
  
end;

% UNITS OF INCHES
bottom = 0.56;
top = 0.56;
left = 0.735;
right = 0.525;

vspace = 0.200;
cbar = 0.2625;

%   width = (figWidth-left-right-cbar)./DF.maxPlots - .1;
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
