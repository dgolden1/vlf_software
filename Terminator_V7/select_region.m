%select_region


HH = findobj(gcf,'tag','region_selector');
region_cell = get(HH,'string');
region_index = get(HH,'Value');
region_selected = region_cell{region_index};

HH = findobj(gcf,'tag','region');
set(HH,'string',region_selected);
