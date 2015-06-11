function whSlider
% Executes when the user manipulates the slider tool in the Overlay
% analysis gui.  It first updates the Start field in the gui with the
% current value of the slider.  Then, the overlay functions are redrawn
% according to the new Start time value

set(findobj('Tag','overlay_startfield'), 'String',...
    num2str(get(findobj('Tag','overlay_startslider'),'Value')));

whShowOverlay;
