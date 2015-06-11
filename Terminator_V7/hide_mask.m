%hide_mask.m




HH = findobj(gcf,'tag','no_day_night');
no_day_night = get(HH,'Value');

if(no_day_night)
    HH = findobj(gcf,'tag','numPixels');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text65');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text74');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','plot_topo');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text75');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text63');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','delta');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text_no_day_night');
    set(HH,'visible','on');
%     HH = findobj(gcf,'tag','frame16');
%     set(HH,'visible','off');
%     HH = findobj(gcf,'tag','text73');
%     set(HH,'visible','off');
    
    
else
    HH = findobj(gcf,'tag','numPixels');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text65');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text74');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','plot_topo');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text75');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text63');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','delta');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text_no_day_night');
    set(HH,'visible','off');
%     HH = findobj(gcf,'tag','frame16');
%     set(HH,'visible','on');
%     HH = findobj(gcf,'tag','text73');
%     set(HH,'visible','on');
    hide_pixel;
end
