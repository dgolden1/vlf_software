function whGetPointsSourceBrowse
% Modified by Daniel Golden (dgolden1@stanford.edu) Feb 2007

h = findobj('Tag','source'); 

directory = uigetdir(get(h,'String'));
if( directory ~= 0 )
    if (directory(end) ~= filesep)
        directory(end+1) = filesep;
    end
	set(h,'String', directory);
end
