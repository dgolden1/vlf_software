%hide_pixel.m




HH = findobj(gcf,'tag','plot_topo');
plot_topo = get(HH,'Value');

if(plot_topo)
    HH = findobj(gcf,'tag','numPixels');
     set(HH,'visible','off');
         HH = findobj(gcf,'tag','text65');
              set(HH,'visible','off');
              HH = findobj(gcf,'tag','text74');
              set(HH,'visible','off');
          else
                  HH = findobj(gcf,'tag','numPixels');
     set(HH,'visible','on');
         HH = findobj(gcf,'tag','text65');
              set(HH,'visible','on');
              HH = findobj(gcf,'tag','text74');
              set(HH,'visible','on');
          end
