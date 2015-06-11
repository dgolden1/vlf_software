function whOverlay
% function creates the main gui interface for controlling the overlay
% analysis functions.  overlays are given by function t = Do/f^(1/2)

global DF

% all future plots will be placed on top of the spectrogram
set(DF.fig,'DoubleBuffer','on');
h = findobj('Tag','spec_axis');
set(h,'DrawMode','fast','NextPlot','add'); % axis

if (isempty(findobj('Tag','whoverlaygui')))
    fig = figure;
    set( fig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
        'Units', 'pixels', 'Tag', 'whoverlaygui',...
        'CloseRequestFcn' ,'whDoneOverlay','Name', 'Overlay Analysis');
    figpos = [ 50 420 400 350 ];
    set(fig, 'position', figpos );

    set(fig, 'Units', 'normal');

    bot = 0.1;
    left = 0.1;
    right = 0.1;
    top = 1- bot - 0.1;

    width = 0.1;
    hspace = 0.1;
    height = 0.1;
    buf = .05;

    b_pos = [ left bot 2*width 2*height];

    % Button quits the overlay interface
    h_done = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'pushbutton', 'String', 'Done', 'Callback', 'whDoneOverlay');

    b_pos = [ left+2*width+buf bot 2.5*width 2*height ];

    % Button clears any existing overlays on the spectrogram
    h_delete = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'pushbutton',  'String', 'Clear Overlay', ...
        'Callback', 'whClearOverlayAll');

    r_pos = [ b_pos(1)+b_pos(3)+buf bot 2*width 2*height];

    % Button clears any existing overlays and graphs new overlays according to
    % the parameters in the edit fields
    h_save = uicontrol( gcf, 'Units', 'normal', 'Position', r_pos, ...
        'Style', 'pushbutton',  'String', 'Show Overlay', ...
        'Callback', 'whShowOverlay');

    text_width = 2.3*width;
    t_pos = [left top text_width height];

    % Below are the text labels and fields for entering the range of Do values
    % for the curves the user wants overlayed on the spectrogram

    t_f = uicontrol( gcf, 'Units', 'normal', 'Position', t_pos, ...
        'Style', 'text', 'String', 'Do Min', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    tv_pos = [left+t_pos(3) top text_width height];


    tv_f = uicontrol( gcf, 'Units', 'normal', 'Position', tv_pos, ...
        'Style', 'edit', 'String', '20', 'Tag', 'overlay_d0minfield', 'FontSize', 18,...
        'BackgroundColor','w');

    f_pos = [left top-tv_pos(4) text_width height];


    f_f = uicontrol( gcf, 'Units', 'normal', 'Position', f_pos, ...
        'Style', 'text', 'String', 'Do Max', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    fv_pos = [left+f_pos(3) top-f_pos(4) text_width height];


    fv_f = uicontrol( gcf, 'Units', 'normal', 'Position', fv_pos, ...
        'Style', 'edit', 'String', '100', 'Tag', 'overlay_d0maxfield', 'FontSize', 18,...
        'BackgroundColor','w');

    i_pos = [left fv_pos(2)-fv_pos(4) text_width height];


    i_f = uicontrol( gcf, 'Units', 'normal', 'Position', i_pos, ...
        'Style', 'text', 'String', 'Step', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    iv_pos = [left+i_pos(3) i_pos(2) text_width height];


    iv_f = uicontrol( gcf, 'Units', 'normal', 'Position', iv_pos, ...
        'Style', 'edit', 'String', '10', 'Tag', 'overlay_stepfield', 'FontSize', 18,...
        'BackgroundColor','w');

    n_pos = [left i_pos(2)-i_pos(4) text_width height];


    n_f = uicontrol( gcf, 'Units', 'normal', 'Position', n_pos, ...
        'Style', 'text', 'String', 'Start Time', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    nv_pos = [left+n_pos(3) n_pos(2) text_width height];


    nv_f = uicontrol( gcf, 'Units', 'normal', 'Position', nv_pos, ...
        'Style', 'edit', 'String', '0', 'Tag', 'overlay_startfield', 'FontSize', 18,...
        'BackgroundColor','w','KeyPressFcn', 'whOverlayCheckEnterKey');


    % the slider control
    s_pos = [nv_pos(1) n_pos(2)-n_pos(4)/2 text_width height/2];

    % sets the max and min values to round numbers near the beginning and end
    % of the plot.  Originally did it without the round, but this led to a
    % negative time for the min value.
    x = get(h,'XLim');
    maxv = round(x(2));
    minv = round(x(1));

    s_f = uicontrol( gcf, 'Units', 'normal', 'Position', s_pos, ...
        'Style', 'slider', 'String', 'Start Time', 'Tag','overlay_startslider',...
        'Max', maxv, 'Min', minv, 'SliderStep', [.01 .025], 'Callback','whSlider');


    % END
else
    
    % Brings figure to the front if it already exists
    figure(findobj('Tag','whoverlaygui'));
    
end

