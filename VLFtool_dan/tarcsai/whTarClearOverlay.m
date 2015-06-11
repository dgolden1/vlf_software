function whTarClearOverlay
% executes when the user clicks the Clear Overlay button in the Tarcsai
% analysis interface.  Makes the curve invisible.

global D_HANDLES
global START_HANDLE

if (ishandle(D_HANDLES))
    set(D_HANDLES,'Visible','off');
end

if (ishandle(START_HANDLE))
    set(START_HANDLE,'Visible','off');
end
