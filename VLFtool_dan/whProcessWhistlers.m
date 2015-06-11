function whProcessWhistlers
% Allows the user to select a directory.  Finds all the wh files in the
% selected directory and converts them to tarcsai files

global DF

d = findobj('Tag','destination');

if (isempty(d))
    destin = uigetdir(DF.destinPath);
else
    destin = uigetdir(get(d,'String'));
end

if (destin(end) ~= filesep)
    destin = [destin filesep];
else
    destin = destin;
end

files = dir([destin '*_wh_*.mat']);

for n=1:length(files)
    load([destin files(n).name]);
    
    if (wh.sferic == -1)
        timev = wh.time - wh.time(1) + .8;
        freqv = wh.freq;
        sferic_time = wh.time(1) - .8;
    else
        timev = wh.time - wh.sferic;
        freqv = wh.freq;
        sferic_time = wh.sferic;
    end

    result = tarcsai(timev',freqv'); % run the tarcsai analysis
    result.UT = wh.UT;
    result.station = wh.station;
    result.time = wh.time;
    result.freq = wh.freq;
    result.index = wh.index;
    result.intensity = wh.intensity;
    result.sferic = sferic_time;
    result.T = sferic_time + result.T;
    
    filename = [files(n).name(1:end-10),'_tarcsai_',files(n).name(end-5:end-4),'.mat'];
    
    save( [destin filename], 'result');
	disp( ['wrote ' destin filename] );
end
