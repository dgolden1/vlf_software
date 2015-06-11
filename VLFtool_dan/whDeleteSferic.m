function whDeleteSferic
% deletes the currently existing sferic
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 3 2007

% $Id$

global SFERIC_HANDLE
global DATA_SET

% makes sure there is a sferic to delete
if (ishandle(SFERIC_HANDLE))
    delete(SFERIC_HANDLE);
end

if ( ~isstruct(DATA_SET))
    DATA_SET.index = 0;
end

DATA_SET.sferic = -1;
sv = findobj('Tag','sferic_time');

% Only displays the -1 in the gui if the sferic has been previously
% defined
if (strcmp(get(sv,'String'), '') == 0)
    set(sv, 'String', num2str(DATA_SET.sferic));
end
