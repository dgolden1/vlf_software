function whMakePlots
% creates the window with buttons allowing the user to make plots

if (isempty(findobj('Tag','makeplotsfig')))

    % sets up the figure with the Tarcsai analysis tools
    fig = figure;
    set( fig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
        'Units', 'pixels', 'Tag', 'makeplotsfig', ...
        'Name', 'Plots');
    figpos = [ 550 420 400 350 ];
    set(fig, 'position', figpos );

    set(fig, 'Units', 'normal');
else
    figure(findobj('Tag','makeplotsfig'));
end

bot = 0.1;
left = 0.1;
right = 0.1;
top = 1- bot - .05;

width = 0.1;
hspace = 0.1;
height = 0.1;
buf = .05;

b_pos = [ left top width height ];

w_pos = [ left b_pos(2)-b_pos(4) 3*width height ];

% Make Neq File
w = uicontrol( gcf, 'Units', 'normal', 'Position', w_pos, ...
    'Style', 'pushbutton',  'String', 'Make Neq File', ...
    'Callback', 'whMakeNeqFile');

wc_pos = [ left w_pos(2)-w_pos(4) 3*width height ];

% Make Neq Plot
wc = uicontrol( gcf, 'Units', 'normal', 'Position', wc_pos, ...
    'Style', 'pushbutton',  'String', 'Make Neq Plot', ...
    'Callback', 'whMakeNeqPlot');

wc_pos = [ left wc_pos(2)-wc_pos(4) 3*width height ];

% Select Tarcsai Files Plot
wc = uicontrol( gcf, 'Units', 'normal', 'Position', wc_pos, ...
    'Style', 'pushbutton',  'String', 'Select Files', ...
    'Callback', 'whTarcsaiPlot');

c_pos = [ left wc_pos(2)-wc_pos(4) 3*width height ];

% Make DST Plot
c = uicontrol( gcf, 'Units', 'normal', 'Position', c_pos, ...
    'Style', 'pushbutton',  'String', 'Make DST Plot', ...
    'Callback', 'whMakeDSTPlot');

sh_pos = [ left c_pos(2)-c_pos(4) 3*width height ];

% Neq and DST
sh = uicontrol( gcf, 'Units', 'normal', 'Position', sh_pos, ...
    'Style', 'pushbutton',  'String', 'Neq and DST', ...
    'Callback', 'whNeqDST');
