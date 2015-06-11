function vlfNewFigureOriginal( tag )

global DF;


figWidth = 10.5;
if( DF.numRows == 2 )
  figHeight = 6;
else
  figHeight = 4;
end;

myfig = findobj('Tag', tag );
if ~isempty(myfig)
  sfigure(myfig);
  clf(myfig);
  DF.fig = myfig;
else
  DF.fig = figure('MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
    'Units', 'inches', 'Tag', tag, 'Visible', 'off', 'BackingStore', 'off');
end

figpos = [ 2.25 3 figWidth figHeight ];
set(DF.fig, 'position', figpos );

if( DF.hideFigure == 0 )
  set(DF.fig, 'Visible', 'on');
end;

set(0,'CurrentFigure',myfig);
DF.h_ax = [];
DF.h_cb = [0 0];


% UNITS OF INCHES
bottom = 0.56;
top = 0.56;
left = 0.735;
right = 0.7;

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
