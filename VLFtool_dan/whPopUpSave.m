function whPopUpSave

% NOT USED IN FINAL CODE

global DF
global DATA_SET

% First check to make sure there are points to save
if ( ~isstruct( DATA_SET ) || DATA_SET.index == 0 )
	error('No points to save');
else

    % new window pops up to allow the user to choose to save or not save
    % data points
    fig = figure;
    set( fig, 'MenuBar', 'none', 'PaperPositionMode', 'auto', ...
        'Units', 'pixels', 'Tag', 'tempsave');
    figpos = [ 350 320 200 150 ];
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
    
    savename = [DF.bbrec.site,'_',datestr(DF.bbrec.startDate,30),'_wh'];

    b_pos = [ left bot width*7 height*2 ];

    % text field to allow the user to specify what he wants the saved file
    % to be called
    save_as = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'edit', 'String', savename, 'Tag', 'saveas',...
        'HorizontalAlignment','right','FontSize',8,'BackgroundColor','w');

    p_pos = [ left+b_pos(3) bot width*2 b_pos(4)-.05 ];

    save_text = uicontrol( gcf, 'Units', 'normal', 'Position', p_pos, ...
        'Style', 'text', 'String', '.mat','HorizontalAlignment','left',...
        'FontSize',12, 'BackgroundColor',get(fig,'Color'));

    s_pos = [ left bot+.4 4*width 4*height ];

    % button to allow user to finalize saving process
    save_text = uicontrol( gcf, 'Units', 'normal', 'Position', s_pos, ...
        'Style', 'pushbutton', 'String', 'Save', 'Callback', 'whSaveAs');
    
    d_pos = [ left+buf+s_pos(3) bot+.4 4*width 4*height ];

    % cancels the saving process
    save_text = uicontrol( gcf, 'Units', 'normal', 'Position', d_pos, ...
        'Style', 'pushbutton', 'String', 'Do not Save',...
        'Callback', 'whDontSave');
end;
