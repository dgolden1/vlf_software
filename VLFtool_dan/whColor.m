function whColor
% sets up a gui interface to allow the user to manipulate the colormap of
% the spectrogram currently in view.  The user can choose to display the
% spectrogram in color or black and white, he can invert the color spectrum,
% and he can change the lower and upper bounds of the colormap

% $Id$

global DF

fig = findobj('Tag', 'colormanip' );
if ( isempty( fig ) )
    fig=figure;
    set (fig, 'PaperPositionMode', 'auto',...
        'Units', 'pixels', 'Tag', 'colormanip', 'Name', 'Change Colormap');
    figpos = [ 500 500 300 200 ];
    set(fig, 'position', figpos);
    set(fig,'Units','normal');

bot = 0.05;
left = 0.1;
right = 0.1;
top = 1- bot - 0.1;

width = 0.1;
hspace = 0.1;
height = 0.1;
buf = .05;

% radio buttons for selecting which colormap to use (color or black and
% white)
h_pos = [left bot 6*width 4*height];
h = uibuttongroup('visible','off', 'Units', 'normal','Position', h_pos, 'Tag', 'colorgroup');
u0 = uicontrol('Style','radiobutton', 'Units','normal','String','Color', 'Tag', 'colorradio',...
    'position',[left bot+4*height 6*width 4*height],'parent',h);
u1 = uicontrol('Style','radiobutton','Units','normal','String','B and W', 'Tag', 'bwradio',...
    'position',[left bot+height 6*width 4*height],'parent',h);
set(h,'SelectionChangeFcn','whColormapChange');

% ensures the initially selected radio button corresponds to the current
% colormap of the figure
if (get(DF.fig,'colormap') == colormap('jet'))
    set(h,'SelectedObject',u0);
else
    set(h,'SelectedObject',u1);
end

set(h,'Visible','on');

% inverse color button
inv_pos = [left bot+h_pos(4)+buf 2.5*width 2.5*height];

inv_but =uicontrol('Style', 'pushbutton', 'Tag', 'invcolor','String', 'Invert Color',...
    'Callback', 'whColorInvert', 'units','normal','position', inv_pos);

% colormap max text label and edit field
cminl_pos = [left+inv_pos(3)+buf inv_pos(2) 1.2*width 1.2*height];

cmin_label =uicontrol('Style', 'text', 'String', 'CMin',...
    'units','normal','position', cminl_pos);

y = get(findobj('Tag','colorbari'),'YLim');

cmin_pos = [cminl_pos(3)+cminl_pos(1) cminl_pos(2) 1.5*width 1.2*height];

cmin_edit =uicontrol('Style', 'edit', 'Tag', 'cminedit','String', y(1),...
    'units','normal','position', cmin_pos, 'backgroundcolor','w','KeyPressFcn', 'whColorCheckEnterKey');

% colormap min text label and edit field
cmaxl_pos = [left+inv_pos(3)+buf cminl_pos(2)+cminl_pos(4)+buf 1.2*width 1.2*height];

cmax_label =uicontrol('Style', 'text', 'String', 'CMax',...
    'units','normal','position', cmaxl_pos);

cmax_pos = [cmaxl_pos(3)+cmaxl_pos(1) cmaxl_pos(2) 1.5*width 1.2*height];

cmax_edit =uicontrol('Style', 'edit', 'Tag', 'cmaxedit','String', y(2),...
    'units','normal','position', cmax_pos, 'backgroundcolor','w','KeyPressFcn', 'whColorCheckEnterKey');
else
    
   figure (fig);
end

