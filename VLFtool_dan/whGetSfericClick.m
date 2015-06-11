function whGetSfericClick
% detects the click which is meant to mark the time of the sferic in the
% Get Points interface
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 3 2007

% $Id$

global DATA_SET
global SFERIC_HANDLE
global DF

% initializes the DATA_SET global if not yet created
if ( ~isstruct( DATA_SET ))
	DATA_SET.index = 0;
end;

% delete the preexisting sferic marker
if (ishandle(SFERIC_HANDLE))
    delete(SFERIC_HANDLE);
end

s = findobj('Tag','spec_axis'); % find the axis

click = get(s, 'CurrentPoint'); % find where the click occured

DATA_SET.sferic = click(1,1);

% need points to make a straight vertical line at the sferic time
y = get(s,'ylim');
y = [y(1):((y(2)-y(1))/100):y(2)]; 

SFERIC_HANDLE = plot(click(1,1)*ones(1,length(y)),y,'-','linewidth',2,'Color','w');

sv = findobj('Tag','sferic_time');
set(sv, 'String', num2str(DATA_SET.sferic, '%0.2f'));

h = findobj('Tag', 'spec_image'); % image of spectrogram

% run whGetClicks whenever there is a mouse click on the spectrogram
set(h, 'ButtonDownFcn', 'whGetClicks');
set (DF.fig,'Pointer','Crosshair');
