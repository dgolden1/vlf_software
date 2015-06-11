function whCaptureOverlaySferic
% executes in the Get Points interface when the user clicks the capture
% sferic button.
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 3 2007

% $Id$

global DATA_SET
global SFERIC_HANDLE
global DF
global START_HANDLE

if (~isempty(START_HANDLE) & ishandle(START_HANDLE))

    % initializes the DATA_SET global if not yet created
    if ( ~isstruct( DATA_SET ))
        DATA_SET.index = 0;
    end;

    % delete the preexisting sferic marker
    if (ishandle(SFERIC_HANDLE))
        delete(SFERIC_HANDLE);
    end

    s = findobj('Tag','spec_axis'); % find the axis

    % obtain the overlay sferic time from the edit field
    DATA_SET.sferic = str2num(get(findobj('Tag','overlay_startfield'), 'String'));

    % need points to make a straight vertical line at the sferic time
    y = get(s,'ylim');
    y = [y(1):((y(2)-y(1))/100):y(2)]; 

    SFERIC_HANDLE = plot(s, DATA_SET.sferic*ones(1,length(y)),y,'-','linewidth',2,'Color','w');

    sv = findobj('Tag','sferic_time');
    set(sv, 'String', num2str(DATA_SET.sferic, '%0.2f'));

    h = findobj('Tag', 'spec_image'); % image of spectrogram
    
    whDoneOverlay;

end
