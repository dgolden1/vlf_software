%hide_advanced_accuracy

HH = findobj(gcf,'tag','advanced_accuracy');
advanced_accuracy = get(HH,'Value');

if(~advanced_accuracy)
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
    HH = findobj(gcf,'tag','text169');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text167');
    set(HH,'visible','off');  
    HH = findobj(gcf,'tag','delta_L');
    set(HH,'visible','off');  
    HH = findobj(gcf,'tag','text170');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','text174');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','num_pt_steps');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','num_line_steps');
    set(HH,'visible','off');   
    HH = findobj(gcf,'tag','num_L_steps');
    set(HH,'visible','off');   
else
    
    HH = findobj(gcf,'tag','text158');
    set(HH,'visible','on');
    HH = findobj(gcf,'tag','text160');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text161');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','delta_pt');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','delta_line');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text169');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text167');
    set(HH,'visible','on');  
    HH = findobj(gcf,'tag','delta_L');
    set(HH,'visible','on');  
    HH = findobj(gcf,'tag','text170');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','text174');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','num_pt_steps');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','num_line_steps');
    set(HH,'visible','on');   
    HH = findobj(gcf,'tag','num_L_steps');
    set(HH,'visible','on');  
    hide_conj;
    
end
