function whSavePoints
% saves a given data set of points into a mat file.  resets the global
% variable DATA_SET and clears any existing markers on the spectrogram.
% Finally, updates the gui display of time, freq, intensity, #points,
% sferic

global DATA_SET
global DF
global POINT_HANDLES
global SFERIC_HANDLE

% First check to make sure there are points to save
if ( ~isstruct( DATA_SET ) || DATA_SET.index == 0 )
	error('No data points to save');
else
    whdate = datestr(DF.bbrec.startFileDate + DATA_SET.time(1)/86400, 30);
%     whdate = datestr(DF.bbrec.startFileDate,30);
    whdate(9) = '_';
%     sec = str2double(whdate(end-1:end)) + round(DATA_SET.time(1));
%     whdate(end-1:end) = num2str(sec, '%02d');
    savename = [DF.bbrec.site,'_',whdate,'_wh'];
    
    destin = get(findobj('Tag','destination'),'String');
    if (destin(end) ~= filesep)
        destin = [destin filesep];
    end
    
    files = dir([destin savename '*.mat']);
    
    if (isempty(files))
        savename = [savename '_01'];
    else
        num = num2str(str2num(files(end).name(end-5:end-4)) + 1) ;
        if (length(num) == 1) num = ['0' num]; end
        savename = [savename '_' num];
    end
    
    % save the DATA_SET in a .mat file
    wh = DATA_SET;
    wh.startFileDate = DF.bbrec.startFileDate;
    rmfield(wh, 'index');

    filename = [savename,'.mat'];


    save( [destin filename], 'wh');
    disp( ['wrote ' destin filename] );

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

    
end;
