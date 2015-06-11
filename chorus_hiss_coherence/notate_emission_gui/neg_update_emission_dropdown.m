function neg_update_emission_dropdown(popupmenu_em_list, emission_list)
% neg_update_emission_dropdown(popupmenu_em_list, emission_list)
% Update the emission list popup menu

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

set(popupmenu_em_list, 'Value', 1);

if isempty(emission_list)
	set(popupmenu_em_list, 'string', '*No Emissions*');
	return;
end

for kk = 1:length(emission_list)
	popup_string{kk} = neg_write_emission_caption(emission_list(kk), kk, 'long');
end

set(popupmenu_em_list, 'string', popup_string);

disp('');
