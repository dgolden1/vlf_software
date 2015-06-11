% pp_correlation_plot
% Plots correlation between chorus intensity and plasmapause location

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$


%% Load files
load('/home/dgolden/vlf/vlf_software/dgolden/image_euv/palmer_pp_db.mat');
% load('/home/dgolden/vlf/case_studies/chorus_2001/2001_chorus_list.mat');
load('/home/dgolden/vlf/case_studies/chorus_hiss_detection/auto_chorus_hiss_db_2001.mat');

%% Parse out valid plasmapause data
palmer_pp_db = palmer_pp_db(isfinite([palmer_pp_db.pp_L]));

%% Parse out valid emissions
i = strfind({events.emission_type}, 'chorus');
i = ~cellfun('isempty', i);
events = events(i);


%% Find plasmapause points within 30 minutes of emission
pp_dist = nan(size(events));
pp_date = zeros(size(events));

for kk = 1:length(pp_dist)
	em_duration = events(kk).end_datenum - events(kk).start_datenum;
	middle_datenum = events(kk).start_datenum + em_duration/2;
	
	date_dist = abs([palmer_pp_db.img_datenum] - middle_datenum);
	if min(date_dist) > em_duration/2, continue; end
	
	i = find(date_dist == min(date_dist), 1);
	pp_date(kk) = palmer_pp_db(i).img_datenum;
	pp_dist(kk) = palmer_pp_db(i).pp_L;
end

%% Correlation plot!
figure;
% scatter([events.intensity], pp_dist, 'MarkerSize',  'filled');
h = plot(pp_dist, [events.intensity], 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
grid on;
ylabel('Chorus intensity (uncal dB)');
xlabel('Plasmapause distance (L-shell)');
title('Correlation between chorus intensity and plasmapause distance');
hold on;

% p = polyfit([events.intensity], -log(pp_dist.') + rand(size(pp_dist.'))*0.001, 1);
% p_fun = polyval(p, [events.intensity]);
% plot([events.intensity], exp(-p_fun), 'r--', 'LineWidth', 2);

increase_font(gcf, 14);
