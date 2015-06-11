%hide_region.m

HH = findobj(gcf,'tag','specify_coord');
specify_coord = get(HH,'Value');

if(specify_coord)
    HH = findobj(gcf,'tag','text103');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','region');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text_special1');
    set(HH,'visible','off');    
    HH = findobj(gcf,'tag','text82');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text175');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','region_selector');
    set(HH,'visible','off');  
else
    
    HH = findobj(gcf,'tag','text103');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','region');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text_special1');
    set(HH,'visible','on');     
    HH = findobj(gcf,'tag','text82');
    set(HH,'visible','on'); 
    HH = findobj(gcf,'tag','region_selector');
    set(HH,'visible','on'); 
    HH = findobj(gcf,'tag','text175');
    set(HH,'visible','on');  
end
