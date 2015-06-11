function whGetPointsDestinBrowse
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 4 2007

% $Id$

h = findobj('Tag','destination'); 

directory = uigetdir(get(h,'String'));
if( directory ~= 0 )
    if (directory(end)~=filesep)
        directory(end+1) = filesep;
    end
	set(h,'String', directory);
end
