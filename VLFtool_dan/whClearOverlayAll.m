function whClearOverlayAll
% Executed when the user clicks the "Clear Overlay" button in the Overlay
% interface.  This both deletes the plots and the check box window.
% whClearOverlay only deletes the plots

delete(findobj('Tag','overlaycheck'));

whClearOverlay;
