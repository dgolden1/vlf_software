function whDeletePoint
% Deletes the last time-freq pair selected.  If no point is active, nothing
% is done.

global DATA_SET
global POINT_HANDLES
global DF

% Delete the last point if one exists
if( isstruct(DATA_SET) && DATA_SET.index > 0 )
    
    % delete the last dot placed on the image if the image still exists
    if (ishandle(DF.fig))
        delete(POINT_HANDLES(DATA_SET.index));
    end
    DATA_SET.index = DATA_SET.index - 1;
    POINT_HANDLES = POINT_HANDLES(1:DATA_SET.index);
	DATA_SET.time = DATA_SET.time(1:DATA_SET.index);
    DATA_SET.freq = DATA_SET.freq(1:DATA_SET.index);
    DATA_SET.intensity = DATA_SET.intensity(1:DATA_SET.index);
    % add intensity later
    
    % update the time frequency values displayed in the window
    if (DATA_SET.index ~= 0)
        tv = findobj('Tag','timev');
        set(tv, 'String', DATA_SET.time(DATA_SET.index));

        fv = findobj('Tag','freqv');
        set(fv, 'String', DATA_SET.freq(DATA_SET.index));
        
        iv = findobj('Tag','intensityv');
        set(iv, 'String', DATA_SET.intensity(DATA_SET.index));
        
        pv = findobj('Tag','numpointsv');
        set(pv, 'String', num2str(DATA_SET.index));
    else
        tv = findobj('Tag','timev');
        set(tv, 'String', '');

        fv = findobj('Tag','freqv');
        set(fv, 'String', '');
        
        iv = findobj('Tag','intensityv');
        set(iv, 'String', '');
        
        pv = findobj('Tag','numpointsv');
        set(pv, 'String', '');
    end
else    
    warn('No more points to delete');
end;

