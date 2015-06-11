function whClearOverlay
% clears all existing overlay curves from the spectrogram

global D_HANDLES
global START_HANDLE

if (ishandle(D_HANDLES))
    for k=1:length(D_HANDLES)
       delete(D_HANDLES(k));
	end
	if all(ishandle(START_HANDLE))
	    delete(START_HANDLE);
	end
    
    D_HANDLES = [];
end
