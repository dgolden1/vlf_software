function whTarDisWhistler
% executes when user clicks the Whistler Data button in the Tarcsai
% analysis interface.  Shows the data points fed into the TARCSAI scripts.
% Allows the user to compare actual data to the estimated results.

% Modified by Daniel Golden (dgolden1 at stanford dot edu) August 2007

% $Id:whTarDisWhistler.m 522 2007-09-24 21:29:08Z dgolden $

global WHISTLER
global WHISTLER_HANDLES
global WHISTLER_SFERIC_HANDLE
global DF

s = findobj('Tag','spec_axis'); % find the axis

% Only draws if a whistler file has been loaded
if (isstruct(WHISTLER) && isempty(WHISTLER_HANDLES))
	% In case the current spectrogram was plotted with a different x-axis than the one
	% on which whistler points were taken, reconcile the difference
% 	start_offset = (WHISTLER.UT - DF.bbrec.startDate)*86400;
	
	for k=1:length(WHISTLER.time)
        WHISTLER_HANDLES(k) = plot(s,WHISTLER.time(k),WHISTLER.freq(k),...
                    'Color','w',...
                    'MarkerFaceColor','w',...
                    'MarkerEdgeColor','k',...
                    'MarkerSize',8,...
                    'Marker', 'o'); 
	end

    % the default value of the sferic is drawn unless the file specifies
    % its own sferic time
    if (WHISTLER.sferic == -1)
        sferic_time = WHISTLER.time(1) - .8;
    else
        sferic_time = WHISTLER.sferic;
    end

    y = get(s,'ylim');
    y = [y(1):((y(2)-y(1))/100):y(2)]; 

	WHISTLER_SFERIC_HANDLE = whTarcsaiMarkSferic(s, sferic_time, 'w');
%     WHISTLER_SFERIC_HANDLE = plot(s,sferic_time*ones(1,length(y)),y,'-','linewidth',3,'Color','w');

% makes traces visible if they've been set to invisible
elseif ishandle(WHISTLER_SFERIC_HANDLE) && all(ishandle(WHISTLER_HANDLES))
    % Assume if the sferic was invisible, so are all the data points
    if strcmpi(get(WHISTLER_SFERIC_HANDLE, 'Visible'), 'off')
        set(WHISTLER_SFERIC_HANDLE, 'Visible', 'on');
        for thisHandle = WHISTLER_HANDLES
           set(thisHandle, 'Visible', 'on'); 
        end
    end
    
else
    error('No whistler file loaded');
end
