function whTarcsaiClearDataPoints
% Clears all Tarcsai data points, including the whistler file, the whistler
% selected points, and the Tarcsai estimates

% By Daniel Golden (dgolden1 at stanford dot edu) August 2007

% $Id:whTarcsaiClearDataPoints.m 522 2007-09-24 21:29:08Z dgolden $

global WHISTLER
global WHISTLER_HANDLES
global WHISTLER_SFERIC_HANDLE
global D_HANDLES
global START_HANDLE

% Clear the Tarcsai estimate
if (ishandle(D_HANDLES))
    delete(D_HANDLES);
end

if (ishandle(START_HANDLE))
    delete(START_HANDLE);
end

% Clear the original points
if all(ishandle(WHISTLER_HANDLES))
    for thisHandle = WHISTLER_HANDLES
       delete(thisHandle); 
    end
end
if (ishandle(WHISTLER_SFERIC_HANDLE))
    delete(WHISTLER_SFERIC_HANDLE);
end

WHISTLER_HANDLES = [];
WHISTLER_SFERIC_HANDLE = [];
D_HANDLES = [];
START_HANDLE = [];
WHISTLER = [];
% clear WHISTLER_HANDLES WHISTLER_SFERIC_HANDLE D_HANDLES START_HANDLE WHISTLER
