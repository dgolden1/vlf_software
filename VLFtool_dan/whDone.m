function whDone
% closes the window and clears the variables.  first prompts the user to
% save any unsaved data points
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 4 2007

% $Id$

global DF
global DATA_SET
global POINT_HANDLES
global SFERIC_HANDLE

if ( isstruct( DATA_SET ) && DATA_SET.index > 0)
	% prompt the user to save their unsaved data
	response_str = questdlg('Do you want to save this whistler data?');
	if strcmp(response_str, 'Cancel')
		return;
	end

	if strcmp(response_str, 'Yes')
	    whSavePoints;
	end
	
    % need to make sure these next two lines do not execute until user
    % chooses to save or not save current points
    h = findobj('Tag','tempsave');
    waitfor(h);    
    if (ishandle(POINT_HANDLES))
        for k=1:DATA_SET.index
            delete(POINT_HANDLES(k)); 
        end
    end
    POINT_HANDLES = [];
end

% delete the sferic if it exists
if (ishandle(SFERIC_HANDLE))
	delete(SFERIC_HANDLE);
end

% MAKE SURE THIS IS OK
% not sure this is what I want to do
clear global DATA_SET

delete(findobj('Tag', 'getpointsgui')); % delete the window controlling the get points function

set(findobj('Tag','spec_axis'),'XColor','BLACK','YColor','BLACK');

if (ishandle(DF.fig))
	set(DF.fig, 'Pointer', 'arrow');

	% run whGetClicks whenever there is a mouse click on the spectrogram
	h = findobj('Tag', 'spec_image'); % image of spectrogram
	set(h, 'ButtonDownFcn', '');
end
