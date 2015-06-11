function whShowOverlay
% Function clears any existing overlays and then graphs overlays according
% to current parameters
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 4 2007
% Commented out the bit with the dialog box with the checkboxes, because I don't see the
% point of it

% $Id$

% This function also sets up the window which allows the user to make
% visible or invisible any of the curves.  A yet unresolved problem is that
% if the user does not close the check box window but updates the D0 Min, D0
% Max, or Step fields and clicks the Show Overlay button, the check boxes
% do not update.  It does work fine as long as the user first closes the
% check box window and then presses the Show Overlay button.

global D_HANDLES
global START_HANDLE
global DF

whClearOverlay;

% sets up a new figure for the check boxes as long there isn't one already
% in existence.  These check boxes allow the user to make any of the curves
% invisible.  they are labeled by their D0 value.
% if (isempty(findobj('Tag','overlaycheck')))
%     fig = figure;
%     set( fig, 'MenuBar', 'figure', 'PaperPositionMode', 'auto', ...
%         'Units', 'pixels', 'Tag', 'overlaycheck',...
%         'CloseRequestFcn','whCloseOverlayCheck','Name', 'D0 curves');
%     figpos = [ 750 520 200 350 ];
%     set(fig, 'position', figpos );
% end

s = findobj('Tag','spec_axis'); % find the axis
h = findobj('Tag', 'spec_image'); % image of spectrogram

% get do values
domin = str2num(get(findobj('Tag','overlay_d0minfield'),'string'));
domax = str2num(get(findobj('Tag','overlay_d0maxfield'),'string'));
step = str2num(get(findobj('Tag','overlay_stepfield'),'string'));
to = str2num(get(findobj('Tag','overlay_startfield'),'string'));

d = [domin:step:domax];

% convert frequency values to Hz for the units to work in the time
% equation
freq = get(h,'ydata')*1000;

% draws a vertical line at time t0
START_HANDLE = plot(s,to*ones(1,length(freq)),freq/1000,'-','linewidth',2,'Color','w');

freq(find(freq==0)) = .00000001;

% width = .5;
% if (length(d)>0)
%     height = .8/length(d);
% else
%     height = .3;
% end
% buf = .01;

% r_pos = [0 1 0 height];

% graph all of the curves
for k=1:length(d)
%     r_pos = [ .1 r_pos(2)-r_pos(4)-buf width height];
%     
%     % if statement ensures multiple presses to the Show Overlay button does
%     % not produce multiple copies of the check box
%     if (isempty(findobj('Tag',num2str(k))))
%         r = uicontrol( findobj('Tag','overlaycheck'), 'Units', 'normal',...
%             'Position', r_pos, 'Style', 'checkbox',  'String', num2str(d(k)),...
%             'Tag', num2str(k), 'Callback', 'whCheckBoxes',...
%             'Max',1,'Min',0,'Value',1);
%     end
    
    t = d(k)./(freq.^(1/2));
    D_HANDLES(k) = plot(s,t+to,freq/1000,'-','linewidth',2,'Color','w');
    
%     % Only shows the curve if the check box is checked
%     if (get(findobj('Tag',num2str(k)),'Value') == 0)
%         set(D_HANDLES(k),'Visible','off');
%     end
end

% Update the slider
set(findobj('Tag','overlay_startslider'),'Value',to);
