function dst_aligned_emission_epoch
% Function that finds all substorms when we have emissions, lines up
% minimum DST, and does a superposed epoch analysis on emissions

%% Setup
addpath(fullfile(pwd, '..'));

START_DATE = datenum([2003 01 01 0 0 0]);
END_DATE = datenum([2003 11 01 0 0 0]);

SPEC_AMP_SIZE = [197, 763];

SPEC_DB_MIN = -20; % Minimum dB on spectrograms (spec_amps)

EPOCH_WIN_START = -2;
EPOCH_WIN_END = 5;
EPOCH_WIN_LEN = EPOCH_WIN_END - EPOCH_WIN_START;

b_plot_dsts = true;


time = (0:(SPEC_AMP_SIZE(2)*EPOCH_WIN_LEN - 1))/SPEC_AMP_SIZE(2) + EPOCH_WIN_START;
freq = fliplr(linspace(0.3, 10, SPEC_AMP_SIZE(1))).';

[Time, Freq] = meshgrid(time, freq);


%% Find substorms
[ss_min_dst ss_min_date] = get_substorms(START_DATE, END_DATE, EPOCH_WIN_START, EPOCH_WIN_END, b_plot_dsts);

%% Find emissions for three days following DST minimum
% load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');
load('/home/dgolden/vlf/case_studies/chorus_hiss_detection/auto_chorus_hiss_db_2003.mat', 'events');
[chorus_events, hiss_events, chorus_with_hiss_events] = event_parser(events);

% Three-day spectrogram
spec3 = zeros(SPEC_AMP_SIZE(1), SPEC_AMP_SIZE(2)*EPOCH_WIN_LEN);

emission_times = [];

for kk = 1:length(ss_min_dst)
	this_date = ss_min_date(kk);
% 	disp(sprintf('***Epoch at %s', datestr(this_date)));
	
% 	these_events_all = [chorus_events; chorus_with_hiss_events];
	these_events_all = [hiss_events];
	these_events = these_events_all([these_events_all.start_datenum] >= this_date + EPOCH_WIN_START & ...
		[these_events_all.end_datenum] < this_date + EPOCH_WIN_END);
	for jj = 1:length(these_events)
% 		disp(sprintf('Event at %s', datestr(these_events(jj).start_datenum)));
		
		[event_time, event_freq, event_intensity] = grab_emission_intensity(these_events(jj));

		% Get event time as days after epoch
		event_time_offset = these_events(jj).start_datenum - this_date;
		event_time = event_time - event_time(1) + event_time_offset;
		
		% Add emission to cumulative spectrogram
		mask = false(size(Time));
		time1_i = find(abs(time - event_time(1)) == min(abs(time - event_time(1))), 1);
		time2_i = time1_i + length(event_time) - 1;
		mask(Time >= time(time1_i) & Time <= time(time2_i) & Freq >= event_freq(end) & Freq <= event_freq(1)) = true;
		
% 		event_intensity = 0;
		spec3(mask) = spec3(mask) + event_intensity(:) - SPEC_DB_MIN;

		
		emission_times(end+1) = these_events(jj).start_datenum - ss_min_date(kk);
		disp(sprintf('Epoch @ %s, emission @ %s, difference is %0.1f days', ...
			datestr(ss_min_date(kk)), datestr(these_events(jj).start_datenum), ...
			these_events(jj).start_datenum - ss_min_date(kk)));
% 		pause;
		% DEBUG
% 		figure(1)
% 		plot(time, superposed_dsts(kk,:), 'LineWidth', 2); ylim([-100 0]); grid on;
% 		figure(2);
% 		imagesc(time, freq, spec3 + SPEC_DB_MIN); axis xy;
% 		xlabel('Time (days since epoch)');
% 		ylabel('Frequency (kHz)');
% 		drawnow;
	end
end

spec3 = spec3/length(ss_min_dst) + SPEC_DB_MIN;

% load spec3;

%% Plot cumulative spectrogram
figure;
imagesc(time, freq, spec3); axis xy;
ylim([0.3 5]);

xlabel('Time (days since epoch)');
ylabel('Frequency (kHz)');

c = colorbar;
set(get(c, 'ylabel'), 'string', 'average dB-fT/Hz^{1/2}');

increase_font(gcf, 16);

%% 2D Plot
% chorus_2d = log(sum(10.^(spec3/20) .* repmat(sqrt(freq*1e3), 1, length(time)))));
df = mean(abs(diff(freq)));
chorus_2d = sum(10.^(spec3/20))*sqrt(df);
chorus_2d = smooth(chorus_2d, 20);

figure;
plot(time, chorus_2d, 'LineWidth', 2);
grid on;
xlabel('Time (days since epoch)');
ylabel('Average amplitude (fT)');
increase_font(gcf, 16);

% load epoch_coverage.mat
% 
% epoch_coverage_int = interp1(epoch_time, epoch_coverage, time, 'linear', 'extrap');
% epoch_coverage_int = (epoch_coverage_int - mean(epoch_coverage_int))/(2*std(epoch_coverage_int));
% epoch_coverage_int = epoch_coverage_int*0.03 + 1;
% % epoch_coverage_int = epoch_coverage/max(epoch_coverage);
% 
% figure;
% plot(time, chorus_2d.'./epoch_coverage_int, 'LineWidth', 2);
% grid on;
% xlabel('Time (days since epoch)');
% ylabel('Average amplitude, normalized by coverage');
% increase_font(gcf, 16);
