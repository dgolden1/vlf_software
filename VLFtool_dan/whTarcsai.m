function whTarcsai
% Function sets up the gui for using the Tarcsai programs to process the
% data sets created through whGetPoints
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 4 2007

% $Id$

%% Run the Tarcsai GUI instead
% Temporary
if ~exist('whTarcsaiGUI.m', 'file')
	if exist([pwd filesep 'tarcsai'], 'dir')
		addpath([pwd filesep 'tarcsai']);
	else
		error('''tarcsai'' directory not found in current directory (%s)', [pwd filesep]);
	end
end
whTarcsaiGUI;
return;

%% Old Tarcsai GUI code
global model_list
global DF

% ensures any future plots drawn by this set of scripts will be added on
% top of the spectrogram
set(DF.fig,'DoubleBuffer','on');
set(findobj('Tag','spec_axis'),'DrawMode','fast','NextPlot','add');

if (isempty(findobj('Tag','tarcsaifig')))

    % sets up the figure with the Tarcsai analysis tools
    fig = figure;
    set( fig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
        'Units', 'pixels', 'Tag', 'tarcsaifig', 'CloseRequestFcn' ,'whDoneTarcsai',...
        'Name', 'Tarcsai');
    figpos = [ 550 420 400 350 ];
    set(fig, 'position', figpos );

    set(fig, 'Units', 'normal');

    bot = 0.1;
    left = 0.1;
    right = 0.1;
    top = 1- bot - .05;

    width = 0.1;
    hspace = 0.1;
    height = 0.075;
    buf = .05;

    b_pos = [ left bot+.45 2*width height];

    % Select Whistler button.  
    h_done = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'pushbutton', 'String', 'Select Whistler', 'Callback', 'whTarcsaiSelectWhistler');

    m_pos = [ left+b_pos(3)+.02 b_pos(2) 1.5*width height];

    % model list.  
    model_list{1} = 'DE-1';
    model_list{2} = 'DE-2';
    model_list{3} = 'DE-3';
    model_list{4} = 'DE-4';
    model_list{5} = 'CL';
    model_list{6} = 'R-1';
    model_list{7} = 'R-4';
    model_list{8} = 'HY';

    m = uicontrol( gcf, 'Units', 'normal', 'Position', m_pos, ...
        'Style', 'popupmenu', 'String', model_list,'Tag','tarcsai_modellist');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    b_pos = [ left b_pos(2)-b_pos(4) 2*width height ];

    % Process Whistler button
    h_delete = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'pushbutton',  'String', 'Select Whistlers', ...
        'Callback', 'whTarcsaiSelectWhistlers');
    
    b_pos = [ left b_pos(2)-b_pos(4) 2*width height ];

    % Process Whistler button
    h_delete = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'pushbutton',  'String', 'Select Folder', ...
        'Callback', 'whProcessWhistlers');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    b_pos = [ left b_pos(2)-b_pos(4) 2*width height ];

    % Done button
    h_delete = uicontrol( gcf, 'Units', 'normal', 'Position', b_pos, ...
        'Style', 'pushbutton',  'String', 'Done', ...
        'Callback', 'whDoneTarcsai');

    w_pos = [ left b_pos(2)-b_pos(4) 3*width height ];

    % display whistler data
    w = uicontrol( gcf, 'Units', 'normal', 'Position', w_pos, ...
        'Style', 'pushbutton',  'String', 'Show Data Points', ...
        'Callback', 'whTarDisWhistler');

    wc_pos = [ left w_pos(2)-w_pos(4) 3*width height ];

    % clear whistler data
    wc = uicontrol( gcf, 'Units', 'normal', 'Position', wc_pos, ...
        'Style', 'pushbutton',  'String', 'Clear Data Points', ...
        'Callback', 'whTarClearWhistler');

    c_pos = [ left wc_pos(2)-wc_pos(4) 3*width height ];

    % clear button
    c = uicontrol( gcf, 'Units', 'normal', 'Position', c_pos, ...
        'Style', 'pushbutton',  'String', 'Clear Estimate', ...
        'Callback', 'whTarClearOverlay');

    sh_pos = [ left c_pos(2)-c_pos(4) 3*width height ];

    % show button
    sh = uicontrol( gcf, 'Units', 'normal', 'Position', sh_pos, ...
        'Style', 'pushbutton',  'String', 'Show Estimate', ...
        'Callback', 'whTarShowOverlay');


    text_width = 1.8*width;
    t_pos = [left top text_width height];


    % Text which labels the station at which the whistler was detected
    t_f = uicontrol( gcf, 'Units', 'normal', 'Position', t_pos, ...
        'Style', 'text', 'String', 'Station', 'FontSize', 12,...
        'BackgroundColor',get(fig,'Color'));

    tv_pos = [left+t_pos(3) top text_width height];

    % Displays the station at which the whistler was detected
    tv_f = uicontrol( gcf, 'Units', 'normal', 'Position', tv_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'tarcsai_stationfield', 'FontSize', 12,...
        'BackgroundColor',get(fig,'Color'));

    f_pos = [left top-tv_pos(4) text_width height];

    % Text which labels the date display
    f_f = uicontrol( gcf, 'Units', 'normal', 'Position', f_pos, ...
        'Style', 'text', 'String', 'Date', 'FontSize', 12,...
        'BackgroundColor',get(fig,'Color'));

    fv_pos = [left+f_pos(3) top-f_pos(4) text_width height];

    % Displays the date of the plot in which the whistler took place
    fv_f = uicontrol( gcf, 'Units', 'normal', 'Position', fv_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'tarcsai_datefield', 'FontSize', 10,...
        'BackgroundColor',get(fig,'Color'));

    i_pos = [left fv_pos(2)-fv_pos(4) text_width height];

    % Text which labels the time display
    i_f = uicontrol( gcf, 'Units', 'normal', 'Position', i_pos, ...
        'Style', 'text', 'String', 'Time', 'FontSize', 12,...
        'BackgroundColor',get(fig,'Color'));

    iv_pos = [left+i_pos(3) i_pos(2) text_width height];

    % Displays the time of the plot in which the whistler took place
    iv_f = uicontrol( gcf, 'Units', 'normal', 'Position', iv_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'tarcsai_timefield', 'FontSize', 12,...
        'BackgroundColor',get(fig,'Color'));

    textwidth = 1.3*width;

    % The following uicontrol calls all set up the fields to display the output
    % values of the Tarcsai scripts

    s_pos = [tv_pos(1)+tv_pos(3)+buf t_pos(2) textwidth height];


    s_f = uicontrol( gcf, 'Units', 'normal', 'Position', s_pos, ...
        'Style', 'text', 'String', 'Density:',...
        'BackgroundColor',get(fig,'Color'),'FontSize',12);

    sd_pos = [s_pos(1) s_pos(2)-s_pos(4) textwidth height];


    sd_f = uicontrol( gcf, 'Units', 'normal', 'Position', sd_pos, ...
        'Style', 'text', 'String', 'Dci:',...
        'BackgroundColor',get(fig,'Color'),'FontSize',12);


    d_pos = [s_pos(1) sd_pos(2)-sd_pos(4) textwidth height];

    d_f = uicontrol( gcf, 'Units', 'normal', 'Position', d_pos, ...
        'Style', 'text', 'String', 'Do:',...
        'BackgroundColor',get(fig,'Color'),'FontSize',12);

    f_pos = [s_pos(1) d_pos(2)-d_pos(4) textwidth height];

    f_f = uicontrol( gcf, 'Units', 'normal', 'Position', f_pos, ...
        'Style', 'text', 'String', 'fHeq:',...
        'BackgroundColor',get(fig,'Color'),'FontSize',12);


    t_pos = [s_pos(1) f_pos(2)-f_pos(4) textwidth height];


    t_f = uicontrol( gcf, 'Units', 'normal', 'Position', t_pos, ...
        'Style', 'text', 'String', 'T:',...
        'BackgroundColor',get(fig,'Color'),'FontSize',12);


    l_pos = [s_pos(1) t_pos(2)-t_pos(4) textwidth height];

    l_f = uicontrol( gcf, 'Units', 'normal', 'Position', l_pos, ...
        'Style', 'text', 'String', 'L:',...
        'BackgroundColor',get(fig,'Color'),'FontSize',12);

    n_pos = [s_pos(1) l_pos(2)-l_pos(4) textwidth height];

    n_f = uicontrol( gcf, 'Units', 'normal', 'Position', n_pos, ...
        'Style', 'text', 'String', 'neq:',...
        'BackgroundColor',get(fig,'Color'),'FontSize',12);

    textwidth = 2*width;
    fontsize = 8;

    s_pos = [s_pos(1)+s_pos(3)+buf s_pos(2) textwidth height];


    s_f = uicontrol( gcf, 'Units', 'normal', 'Position', s_pos, ...
        'Style', 'text', 'String', '', 'Tag', 'tarcsai_modelfield',...
        'BackgroundColor',get(fig,'Color'),'FontSize',fontsize);

    sd_pos = [s_pos(1) s_pos(2)-s_pos(4) textwidth height];


    sd_f = uicontrol( gcf, 'Units', 'normal', 'Position', sd_pos, ...
        'Style', 'text', 'String', '','Tag', 'tarcsai_dcifield',...
        'BackgroundColor',get(fig,'Color'),'FontSize',fontsize);


    d_pos = [s_pos(1) sd_pos(2)-sd_pos(4) textwidth height];

    d_f = uicontrol( gcf, 'Units', 'normal', 'Position', d_pos, ...
        'Style', 'text', 'String', '','Tag', 'tarcsai_dofield',...
        'BackgroundColor',get(fig,'Color'),'FontSize',fontsize);

    f_pos = [s_pos(1) d_pos(2)-d_pos(4) textwidth height];

    f_f = uicontrol( gcf, 'Units', 'normal', 'Position', f_pos, ...
        'Style', 'text', 'String', '','Tag', 'tarcsai_fheqfield',...
        'BackgroundColor',get(fig,'Color'),'FontSize',fontsize);


    t_pos = [s_pos(1) f_pos(2)-f_pos(4) textwidth height];


    t_f = uicontrol( gcf, 'Units', 'normal', 'Position', t_pos, ...
        'Style', 'text', 'String', '','Tag', 'tarcsai_tfield',...
        'BackgroundColor',get(fig,'Color'),'FontSize',fontsize);


    l_pos = [s_pos(1) t_pos(2)-t_pos(4) textwidth height];

    l_f = uicontrol( gcf, 'Units', 'normal', 'Position', l_pos, ...
        'Style', 'text', 'String', '','Tag', 'tarcsai_lfield',...
        'BackgroundColor',get(fig,'Color'),'FontSize',fontsize);

    n_pos = [s_pos(1) l_pos(2)-l_pos(4) textwidth height];

    n_f = uicontrol( gcf, 'Units', 'normal', 'Position', n_pos, ...
        'Style', 'text', 'String', '','Tag', 'tarcsai_neqfield',...
        'BackgroundColor',get(fig,'Color'),'FontSize',fontsize);
else
    figure(findobj('Tag','tarcsaifig'));
end
