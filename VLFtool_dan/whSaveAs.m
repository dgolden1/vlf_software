function whSaveAs
% saves a given data set of points into a mat file.  resets the global
% variable DATA_SET and clears any existing markers on the spectrogram.
% Finally, updates the gui display of time, freq, intensity, #points,
% sferic

% NOT USED IN FINAL CODE

global DATA_SET
global DF
global POINT_HANDLES
global SFERIC_HANDLE

% save the DATA_SET in a .mat file
wh = DATA_SET;
rmfield(wh, 'index');

% retrieves the string entered by the user and uses it as the filename
% does not check to ensure a valid file name was entered.  If the user
% enters an invalid user name, the program will likely have problems.
filename = [get(findobj('Tag','saveas'),'String') '.mat'];

if (DF.destinPath(end) ~= filesep)
    destinpath = [DF.destinPath filesep];
else
    destinpath = DF.destinPath;
end

save( [destinpath filename], 'wh');
disp( ['wrote ' destinpath filename] );

delete(findobj('Tag','tempsave')); % delete the pop-up save window

% POINT_HANDLES is only valid if spectrogram figure is still open
if (ishandle(POINT_HANDLES))
    for k=1:DATA_SET.index
       delete(POINT_HANDLES(k)); 
    end
    if (ishandle(SFERIC_HANDLE))
        delete(SFERIC_HANDLE);
    end
end
POINT_HANDLES = [];

% reset the time and frequency vectors
DATA_SET.index = 0;
DATA_SET.freq = [];
DATA_SET.time = [];
DATA_SET.intensity = [];
DATA_SET.sferic = -1;

% update the time frequency displays in the window
tv = findobj('Tag','timev');
set(tv, 'String', '');

fv = findobj('Tag','freqv');
set(fv, 'String', '');

iv = findobj('Tag','intensityv');
set(iv, 'String', '');

pv = findobj('Tag','numpointsv');
set(pv, 'String', '');

sv = findobj('Tag','sferic_time');
set(sv, 'String', '');
