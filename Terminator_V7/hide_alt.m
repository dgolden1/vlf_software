%hide_alt.m

HH = findobj(gcf,'tag','civil_sun');
civil_sun = get(HH,'Value');



if(civil_sun)
    HH = findobj(gcf,'tag','alt'); 
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text62');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text100');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text98');
    set(HH,'visible','off');
else
    HH = findobj(gcf,'tag','alt'); 
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text62');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text100');%hide
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text98');
    set(HH,'visible','on');
end
