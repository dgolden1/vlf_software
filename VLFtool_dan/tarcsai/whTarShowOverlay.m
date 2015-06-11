function whTarShowOverlay
% executes when the user clicks the Show Estimate button in the Tarcsai
% analysis interface.  Makes the curve visible

global D_HANDLES
global START_HANDLE

if (ishandle(D_HANDLES))
    set(D_HANDLES,'Visible','on');
end

if (ishandle(START_HANDLE))
    set(START_HANDLE,'Visible','on');
end
