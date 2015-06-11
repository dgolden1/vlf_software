em_type = 'hissonly';
% em_type = 'chorusonly';
% em_type = 'choruswithhiss';


%%
load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');
events = convert_from_utc_to_palmerlt(events);
[chorus_events, hiss_events, chorus_with_hiss_events] = event_parser(events);

switch em_type
	case 'hissonly'
		these_events = hiss_events;
	case 'chorusonly'
		these_events = chorus_events;
	case 'choruswithhiss'
		these_events = chorus_with_hiss_events;
	otherwise
		error('Weird emission type');		
end

%%
figure(1);
num_hours_idx = 1:(24*3);
rho = zeros(size(num_hours_idx));
for kk = 1:length(num_hours_idx)
	rho(kk) = emstat_hist_idx_ampl_scatter(em_type, these_events, 'dst', num_hours_idx(kk));
end

%%
figure;
plot(num_hours_idx, rho, 'LineWidth', 2);
grid on;
xlabel('num hours idx');
ylabel('rho');
title(em_type);
increase_font(gcf, 16);
