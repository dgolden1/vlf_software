function whDoneOverlay
% runs when the user quits the overlay interface.  deletes the overlay gui
% and clears any existing overlays on the spectrogram

global D_HANDLES

delete(findobj('Tag','whoverlaygui'));

whClearOverlayAll;

% if the Get Points gui exists, brings the figure to the forefront
if (~isempty(findobj('Tag','getpointsgui')))
    figure(findobj('Tag','getpointsgui'));
end
