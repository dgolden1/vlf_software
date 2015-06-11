function whGetPoints
% 7/11/06 4:48 P.M.
% try to get data points from a whistler plot
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 3 2007

% $Id$

global DF
global DATA_SET

% 7/12/06 9:44 A.M.
% It seems the previous method is failing b/c ButtonDownFcn
% only picks up clicks on the axis when no other object is 
% on top of it.  The example in rpiExtractNe appears to use
% subplot to solve this problem.  Here is my attempt to copy.

% 11:39 A.M.
% solved the above problem by merely detecting clicks on the image and then
% determining the click's location relative to the axis

h = findobj('Tag', 'spec_image'); % image of spectrogram

% run whGetClicks whenever there is a mouse click on the spectrogram
set(h, 'ButtonDownFcn', 'whGetClicks');
set(findobj('Tag','spec_axis'),'XColor','RED','YColor','RED');

% 7/13/06 9:42 A.M.
% code taken from rpiExtractNe to allow plotting of point markers on top of
% the spectrogram
% BEGIN
set(DF.fig,'DoubleBuffer','on');
set(findobj('Tag','spec_axis'),'DrawMode','fast','NextPlot','add');
% END

%%Change cursor to crosshair.
set(DF.fig, 'Pointer', 'crosshair');

% 7/12/06 11:52 A.M.
% Set up pop-up window with additional tools
% BEGIN
if (isempty(findobj('Tag','getpointsgui')))
    fig = figure;
    set( fig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
        'Units', 'pixels', 'Tag', 'getpointsgui', 'CloseRequestFcn' ,'whDone',...
        'Name', 'Whistler Analysis');
    figpos = [ 250 420 400 350 ];
    set(fig, 'position', figpos );

    set(fig, 'Units', 'normal');

    bot = 0.05;
    left = 0.1;
    right = 0.1;
    top = 1- bot - 0.1;

    width = 0.1;
    hspace = 0.1;
    height = 0.1;
    buf = .05;

    b_pos = [ left bot 2*width height];

    % Done button.  Once user is completely done collecting data points, he
    % should click this button.  If he has not saved currently collected data
    % points, he will be prompted to save them.
    h_done = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'pushbutton', 'String', 'Done', 'Callback', 'whDone');

    % Text label, edit text field, and browse button to allow the user to set
    % the destination folder for all saved files
    des_pos = [ left bot+b_pos(4)+.05 2*width height*.8];

    des = uicontrol( gcf, 'Units', 'normal', 'Position', des_pos, ...
        'Style', 'text', 'String', 'Destination', 'FontSize', 12);

    dest_pos = [ des_pos(1)+des_pos(3) des_pos(2) 4*width height*.8];

    dest = uicontrol( gcf, 'Units', 'normal', 'Position', dest_pos, ...
        'Style', 'edit', 'String', DF.destinPath, 'FontSize', 8,...
        'Tag', 'destination', 'HorizontalAlignment', 'left', 'BackgroundColor', 'w');

    br_pos = [ dest_pos(1)+dest_pos(3)+.02 dest_pos(2) 2*width height*.8];

	% Browse button
    br = uicontrol( gcf, 'Units', 'normal', 'Position', br_pos, ...
        'Style', 'pushbutton', 'String', 'Browse', 'Callback','whGetPointsDestinBrowse');

    % DECIDED SOURCE DIRECTORY UNNECESSARY
    % BEGIN
    % Text label, edit text field, and browse button to allow the user to set
    % the source folder for looking for files
    %so_pos = [ left des_pos(2)+des_pos(4)+.01 2*width height*.8];

    %so = uicontrol( gcf, 'Units', 'normal', 'Position', so_pos, ...
    %	'Style', 'text', 'String', 'Source', 'FontSize', 12);

    %sot_pos = [ so_pos(1)+so_pos(3) so_pos(2) 4*width height*.8];

    %sot = uicontrol( gcf, 'Units', 'normal', 'Position', sot_pos, ...
    %	'Style', 'edit', 'String', DF.sourcePath, 'FontSize', 8,...
    %    'Tag', 'source', 'HorizontalAlignment', 'left', 'BackgroundColor', 'w');

    %br_pos = [ sot_pos(1)+sot_pos(3)+.02 sot_pos(2) 2*width height*.8];

    %br = uicontrol( gcf, 'Units', 'normal', 'Position', br_pos, ...
    %	'Style', 'pushbutton', 'String', 'Browse', 'Callback','whGetPointsSourceBrowse');

    %END

    b_pos = [ left+2*width+buf bot 2.5*width height ];

    % Delete Last Point button.  Deletes the last time-frequency pair in the
    % current collection of data points.
    h_delete = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'pushbutton',  'String', 'Delete Last Point', ...
        'Callback', 'whDeletePoint');

    r_pos = [ b_pos(1)+b_pos(3)+buf bot 2*width height];

    % Save Points button.  Saves all of the points currently highlighted on the
    % spectrogram to a .mat file and resets the time-freq vectors in the global
    % variable DATA_SET
    h_save = uicontrol( gcf, 'Units', 'normal', 'Position', r_pos, ...
        'Style', 'pushbutton',  'String', 'Save Points', ...
        'Callback', 'whSavePoints');

    text_width = 2.3*width;
    t_pos = [left top text_width height];

    % Text which labels the time display
    t_f = uicontrol( gcf, 'Units', 'normal', 'Position', t_pos, ...
        'Style', 'text', 'String', 'Time', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    tv_pos = [left+t_pos(3) top text_width height];

    % Displays the time value of the last point clicked
    tv_f = uicontrol( gcf, 'Units', 'normal', 'Position', tv_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'timev', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    f_pos = [left top-tv_pos(4) text_width height];

    % Text which labels the frequency display
    f_f = uicontrol( gcf, 'Units', 'normal', 'Position', f_pos, ...
        'Style', 'text', 'String', 'Freq', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    fv_pos = [left+f_pos(3) top-f_pos(4) text_width height];

    % Displays the frequency value of the last point clicked
    fv_f = uicontrol( gcf, 'Units', 'normal', 'Position', fv_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'freqv', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    i_pos = [left fv_pos(2)-fv_pos(4) text_width height];

    % Text which labels the intensity display
    i_f = uicontrol( gcf, 'Units', 'normal', 'Position', i_pos, ...
        'Style', 'text', 'String', 'Intensity', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    iv_pos = [left+i_pos(3) i_pos(2) text_width height];

    % Displays the intensity value of the last point clicked
    iv_f = uicontrol( gcf, 'Units', 'normal', 'Position', iv_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'intensityv', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    n_pos = [left i_pos(2)-i_pos(4) text_width height];

    % Text which labels the number of points display
    n_f = uicontrol( gcf, 'Units', 'normal', 'Position', n_pos, ...
        'Style', 'text', 'String', '# Points', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    nv_pos = [left+n_pos(3) n_pos(2) text_width height];

    % Displays the number of points clicked
    nv_f = uicontrol( gcf, 'Units', 'normal', 'Position', nv_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'numpointsv', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    s_pos = [left n_pos(2)-n_pos(4) text_width height];

    % Text which labels the sferic display
    s_f = uicontrol( gcf, 'Units', 'normal', 'Position', s_pos, ...
        'Style', 'text', 'String', 'Sferic', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    sv_pos = [left+s_pos(3) s_pos(2) text_width height];

    % Displays the time value of sferic
    sv_f = uicontrol( gcf, 'Units', 'normal', 'Position', sv_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'sferic_time', 'FontSize', 18,...
        'BackgroundColor',get(fig,'Color'));

    % END

    s_pos = [r_pos(1) top 2*width height];

    % Select Sferic button
    s_f = uicontrol( gcf, 'Units', 'normal', 'Position', s_pos, ...
        'Style', 'pushbutton', 'String', 'Select Sferic', 'Tag', 'sferic',...
        'Callback','whGetSferic','BackgroundColor',get(fig,'Color'));

    so_pos = [s_pos(1)-width s_pos(2)-height-.01 2*width height];

    % Use Overlay to get sferic button
    so_f = uicontrol( gcf, 'Units', 'normal', 'Position', so_pos, ...
        'Style', 'pushbutton', 'String', 'Use Overlay', 'Tag', 'sferico',...
        'Callback','whOverlayGUI','BackgroundColor',get(fig,'Color'));

    so_pos = [s_pos(1)+width so_pos(2) 2*width height];

    % Capture Sferic button (using overlay)
    so_f = uicontrol( gcf, 'Units', 'normal', 'Position', so_pos, ...
        'Style', 'pushbutton', 'String', 'Capture Sferic', 'Tag', 'csferic',...
        'Callback','whCaptureOverlaySferic','BackgroundColor',get(fig,'Color'));

    sd_pos = [s_pos(1) so_pos(2)-s_pos(4)-.01 2*width height];

    % Delete Sferic button
    sd_f = uicontrol( gcf, 'Units', 'normal', 'Position', sd_pos, ...
        'Style', 'pushbutton', 'String', 'Delete Sferic', 'Tag', 'dsferic',...
        'Callback','whDeleteSferic','BackgroundColor',get(fig,'Color'));

    t_pos = [s_pos(1) sd_pos(2)-sd_pos(4)-.01 2*width height];

    % Open Tarcsai analysis button
    t_f = uicontrol( gcf, 'Units', 'normal', 'Position', t_pos, ...
        'Style', 'pushbutton', 'String', 'TARCSAI',...
        'Callback','whTarcsai','BackgroundColor',get(fig,'Color'));
    
else
    figure(findobj('Tag', 'getpointsgui'));
end
