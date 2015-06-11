function [freq, hiss_psd] = get_hiss_spectrum
% get_hiss_spectrum
% 
% Get the combined (average) spectrum of evening hiss events

% By Daniel Golden (dgolden1 at stanford dot edu), October 2008
% $Id$

%% Setup
addpath(fullfile(pwd, '..'));
addpath(fullfile(danmatlabroot, 'vlf', 'vlftool_24_hour_fcn'));

% FFT parameters
NSEC = 5;
NFFT = 1024;
WINDOW = 512;
FSAMP = 100e3;
FMAX = 10e3;

%% Load events
load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');

[chorus_events, hiss_events, chorus_with_hiss_events] = event_parser(events); %#ok<NODEF>
events = hiss_events;
% events = convert_from_utc_to_palmerlt(hiss_events);

events = remove_outside_em_int(events, 'hiss_only');

%% Load files
freq_cumsum = zeros(1, NFFT+1);
freq = linspace(0, FMAX, NFFT+1);
num_spectra = 0;
for kk = 1:length(events)
	t_start = now;
	[pathstr, files] = get_alexandria_files('palmer', events(kk).start_datenum, events(kk).end_datenum);
	for jj = 1:length(files)
		bb = vlfExtractBB( pathstr, files{jj}, 5, 5+NSEC);
		assert(bb.sampleFrequency == 100e3);
		
		% Resample to 20 kHz sampling rate
		data = resample(bb.data(1,:), FMAX*2, FSAMP);
		
		% Remove sferics
		data(abs(data - mean(data)) > std(data)) = mean(data);
		
		Data = fft(data, NFFT*2);
		Data = Data(1:NFFT+1);
		
		Data(freq < events(kk).f_lc | freq > events(kk).f_uc) = 0; % Don't add frequencies outside of this emission
		
		freq_cumsum = freq_cumsum + abs(Data).^2;
		num_spectra = num_spectra + 1;
		
% % 		sfigure(1); specgram(data, NFFT, FMAX*2, WINDOW); ylim([events(kk).f_lc*1e3 events(kk).f_uc*1e3]);
% % 		caxis([30 80]);
% % 		colorbar
% % 		sfigure(2); plot(freq, db(freq_cumsum/num_spectra)); xlim([events(kk).f_lc*1e3 events(kk).f_uc*1e3]); grid on;
% 		sfigure(1); plot(freq, smooth(10*log10(abs(freq_cumsum/num_spectra)), 5)); xlim([events(kk).f_lc*1e3 events(kk).f_uc*1e3]); grid on; xlim([0 10e3]); ylim([40 80]);
% 		sfigure(2); plot(freq, smooth(10*log10(abs(Data).^2), 5)); xlim([events(kk).f_lc*1e3 events(kk).f_uc*1e3]); grid on; xlim([0 10e3]); ylim([40 80]);
% 		drawnow;
	end

	t_end = now;
	disp(sprintf('Processed event %d of %d in %0.1f seconds', kk, length(events), (t_end - t_start)*86400));
end
hiss_psd = freq_cumsum/num_spectra;

%% Plot results
figure;
plot(freq, smooth(10*log10(hiss_psd), 10), 'LineWidth', 2);
grid on;
increase_font(gcf, 16);
