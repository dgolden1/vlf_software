%hide_fun


HH = findobj(gcf,'tag','hide_fun1');
hide_fun1 = get(HH,'Value');

if(~hide_fun1)
    HH = findobj(gcf,'tag','show_river');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','atlas_on');
    set(HH,'visible','off');
else
    HH = findobj(gcf,'tag','show_river');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','atlas_on');
    set(HH,'visible','on');
end
