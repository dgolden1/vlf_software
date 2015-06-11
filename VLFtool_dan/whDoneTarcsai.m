function whDoneTarcsai
% closes the Tarcsai interface window

whTarcsaiClearDataPoints;

delete(findobj('Tag', 'tarcsaifig'));

% If the Get Points gui is open, brings it to the foreground
if (~isempty(findobj('Tag','getpointsgui')))
    figure(findobj('Tag','getpointsgui'));
end
