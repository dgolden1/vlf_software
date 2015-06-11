%calculate_conj

guiTag = gcf;
HHprogress = findobj(guiTag,'tag','progress');
compTime = calculateConj(guiTag,0,1);
if(compTime>0)
    set(HHprogress,'string',['Done! (' num2str(compTime) ' seconds).']);
end



