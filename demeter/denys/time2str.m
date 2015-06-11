function outputTimeString = time2str(inputSecond,TF,HMS,SEC)
% time2str outputs time string 'HH:MM:SS' for inputSecond as integer number
% Example: input = 36630; output = '10:10:30'
%
% This function is used only for compatibilty with old code.
% It ised only for one specific argument combination:
% 
% time2str(inputSecond,'24','hms','sec')
% 
% It will work only if
% inputSecond is whole second number in an hour
% and the rest parameters are '24','hms','sec'
% 
% Author: Denys Piddyachiy
% Date: 2010-08-13

if ~(strcmp(TF,'24') && strcmp(HMS,'hms') && strcmp(SEC,'sec'))
    error('Function time2str is used just for one special case for compatibility with old code. Wrong parameters were used.')
end

outputTimeString = datestr(datenum(0,0,0,0,0,inputSecond),'HH:MM:SS');
