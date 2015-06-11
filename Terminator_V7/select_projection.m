%select_projection

HH = findobj(gcf,'tag','projection_type');
projection_cell = get(HH,'string');
projection_index = get(HH,'Value');
projection_type = projection_cell{projection_index};

HHprojection = findobj(gcf,'tag','projection_choose');
set(HHprojection,'string',projection_type);

HH = findobj(guiTag,'tag','specify_proj');
set(HH,'Value',1);
