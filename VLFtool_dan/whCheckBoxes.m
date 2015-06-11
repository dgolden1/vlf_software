function whCheckBoxes
% function executes whenever one of the check boxes is clicked in the
% overlay analysis gui.  Makes all checked curves visible and all unchecked
% curves invisible.

global D_HANDLES;

for k=1:length(D_HANDLES)
    if (get(findobj('Tag',num2str(k)),'Value') == 0)
        set(D_HANDLES(k),'visible','off');
    else
        set(D_HANDLES(k),'visible','on');
    end
end
