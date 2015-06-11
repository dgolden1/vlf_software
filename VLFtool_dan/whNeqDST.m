function whNeqDST

global DF

d = findobj('Tag','destination');

if (isempty(d))
    destin = DF.destinPath;
else
    destin = get(d,'String');
end

if (destin(end) ~= filesep)
    destin = [destin filesep];
else
    destin = destin;
end

[filename, pathname] = uigetfile('*.txt', 'Select File',...
    destin, 'MultiSelect', 'Off');

whNeqPlotFcn(fullfile(pathname, filename));
