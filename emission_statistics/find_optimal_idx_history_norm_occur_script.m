% em_type = 'hiss_only';
% em_type = 'chorus_only';
em_type = 'chorus_with_hiss';


%%
load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');
events = convert_from_utc_to_palmerlt(events);
[chorus_events, hiss_events, chorus_with_hiss_events] = event_parser(events);

switch em_type
	case 'hiss_only'
		these_events = hiss_events;
	case 'chorus_only'
		these_events = chorus_events;
	case 'chorus_with_hiss'
		these_events = chorus_with_hiss_events;
	otherwise
		error('Weird emission type');		
end

%%
sfigure(1);
num_hours_idx = 1:(24*3);
rho = zeros(size(num_hours_idx));
for kk = 1:length(num_hours_idx)
	[junk, junk, junk, junk, rho(kk)] = emstat_hist_idx_norm_occur(em_type, these_events, 'ae', num_hours_idx(kk));
	disp(sprintf('%s (hours = %d): rho = %0.2f', em_type, num_hours_idx(kk), rho(kk)));
end

%%
sfigure;
plot(num_hours_idx, rho, 'LineWidth', 2);
grid on;
xlabel('num hours idx');
ylabel('rho');
title(sprintf('Corr coeff: norm occur rate (%s)', strrep(em_type, '_', '\_')));
increase_font(gcf, 16);
