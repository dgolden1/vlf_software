function whCloseOverlayCheck
% executes when the user closes the check box window in the Overlay
% analysis interface

delete(findobj('Tag','overlaycheck'));
