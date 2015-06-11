%hide_conj.m

HH = findobj(gcf,'tag','plot_conj');
plot_conj = get(HH,'Value');

HH = findobj(gcf,'tag','advanced_accuracy');
advanced_accuracy = get(HH,'Value');

if(~plot_conj)
    HH = findobj(gcf,'tag','text140');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text141');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text142');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text147');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text148');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text149');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text152');
    set(HH,'visible','off');  
    HH = findobj(gcf,'tag','text155');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','latf0');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','lonf0');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','circle_box');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text200');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text156');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text162');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','Lshell');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text157');
    set(HH,'visible','off');  
    HH = findobj(gcf,'tag','text151');
    set(HH,'visible','off');
    HH = findobj(gcf,'tag','text158');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text160');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text161');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','delta_pt');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','delta_line');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','spec_lat3');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','spec_lon3');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','alt_conj');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','edge_box');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','pushbutton28');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','pushbutton26');
    set(HH,'visible','off');   
else
    HH = findobj(gcf,'tag','text140');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text141');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text142');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text147');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text148');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text149');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text152');
    set(HH,'visible','on');  
    HH = findobj(gcf,'tag','text155');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','latf0');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','lonf0');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','circle_box');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text200');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text156');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text162');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','Lshell');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text157');
    set(HH,'visible','on');  
    HH = findobj(gcf,'tag','text151');
    set(HH,'visible','on');
    
    if(advanced_accuracy)
        HH = findobj(gcf,'tag','text158'); %%
        set(HH,'visible','on');   
        HH = findobj(gcf,'tag','text160');%%
        set(HH,'visible','on');   
        HH = findobj(gcf,'tag','text161');%%
        set(HH,'visible','on'); 
        HH = findobj(gcf,'tag','delta_pt');%%
        set(HH,'visible','on');   
        HH = findobj(gcf,'tag','delta_line');%%
        set(HH,'visible','on');   
    end
    HH = findobj(gcf,'tag','pushbutton28');
    set(HH,'visible','on'); 
    HH = findobj(gcf,'tag','pushbutton26');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','spec_lat3');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','spec_lon3');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','alt_conj');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','edge_box');
    set(HH,'visible','on'); 
    
end
