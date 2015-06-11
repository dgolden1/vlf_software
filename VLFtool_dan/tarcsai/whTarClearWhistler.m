function whTarClearWhistler
% Executes when the user clicks the Clear Data button in the Tarcsai
% analysis interface.  This clears the whistler data points and sferic
% from the spectrogram.

global WHISTLER_HANDLES
global WHISTLER_SFERIC_HANDLE

if ishandle(WHISTLER_SFERIC_HANDLE)
    set(WHISTLER_SFERIC_HANDLE, 'Visible', 'off');
    for thisHandle = WHISTLER_HANDLES
        set(thisHandle, 'Visible', 'off');
    end
end
