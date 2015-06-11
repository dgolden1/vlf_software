function event_struct = find_events_southpole
% Find events in south pole data
% 
% This separate function is necessary because
% a) Only low frequency chorus and super-broadband auroral hiss are present
%  at the south pole, the latter of which can't be easily detected using my
%  current peak detector and
% b) The south pole data is ridiculously noisy

% By Daniel Golden (dgolden1 at stanford dot edu) April 2011
% $Id$

test_find_chorus_events;

function test_find_chorus_events
%% Function: test_find_chorus_events
% Get the power in the chorus band for all files in a given day to see how
% it looks with and without chorus

fs = 1e5;
m_window = 2^nextpow2(fs*0.0064); % Window is at least 6.4 ms long
m_nfft = m_window*2;
m_noverlap = m_window/2;

f_lc = 400;
f_uc = 3000;

source_dir = '/media/shackleton/user_data/dgolden/output/southpole_cleaned/2001/03_02';
d = dir(fullfile(source_dir, '*.mat'));

datenums = nan(size(d));
chorus_ampl = nan(size(d));
for kk = 1:length(d)
  this_filename = fullfile(source_dir, d(kk).name);
  data = matGetVariable(this_filename, 'data');
  [~, f, t, spec] = spectrogram_dan(data - mean(data), m_window, m_noverlap, m_nfft, fs);
  s_mediogram = 10*log10(median(spec, 2));

  chorus_ampl(kk) = get_true_emission_amplitude(f, s_mediogram, nearest_dan(f, f_lc), nearest_dan(f, f_uc));
  datenums(kk) = get_bb_fname_datenum(this_filename, false);
end

figure;
plot(datenums, chorus_ampl, 'linewidth', 2);
grid on;
datetick2('x')
title(sprintf('South Pole %s', datestr(floor(datenums(1)), 'yyyy-mm-dd')));
xlabel('Time');
ylabel('Chorus Band Power (dB uncal)');
figure_grow(gcf, 1.5, 1);
increase_font;

1;

function event_struct = find_chorus_events(f, s_mediogram)
%% Function: find_chorus_events
% High-latitude chorus typically appears below 5 kHz, so we'll set an
% absolute threshold the signal amplitude in a given bandwidth

event_struct = struct('f_lc', {}, 'f_uc', {}, 'ec', {});

%% Determine whether there is any chorus
min_chorus_power = 28; % dB uncal - this is dB (power), not dB/Hz (PSD)

f_lc = 400;
f_uc = 4000;
chorus_power = get_true_emission_amplitude(f, s_mediogram, nearest_dan(f, f_lc), nearest_dan(f, f_uc));

% Quit if the amplitude in the chorus bin is not above our threshold
if chorus_power < min_chorus_power
  return
end

%% Determine the extent of the chorus
idx_lbound = nearest_dan(f, f_lc);
idx_ubound = nearest_dan(f, f_uc);
[~, peak_idx] = max(s_mediogram(idx_f_lc:idx_f_uc)); idx_peak = idx_peak + idx_f_lc - 1;

min_emission_peak_db_local = 15; % When the mediogram gets this many dB below the peak, that's the end of the event
[idx_lc, idx_uc] = find_peak_extents(peak_idx, s_mediogram, idx_lbound, idx_ubound, min_emission_peak_db_local);

event_struct.f_lc = f(idx_lc);
event_struct.f_uc = f(idx_uc);
event_struct.ec = get_event_characteristics(data, fs, f, idx_lc, idx_uc, ...
                                            s_mediogram, s_medio_diff, s_periodogram, ...
                                            t_spec, spec, start_datenum);

% persistent Hd last_fs
% 
% Fstop1 = 300;     % First Stopband Frequency
% Fpass1 = 400;     % First Passband Frequency
% Fpass2 = 2800;    % Second Passband Frequency
% Fstop2 = 3200;    % Second Stopband Frequency
% Astop1 = 60;      % First Stopband Attenuation (dB)
% Apass  = 1;       % Passband Ripple (dB)
% Astop2 = 60;      % Second Stopband Attenuation (dB)
% Fs     = 100000;  % Sampling Frequency
% 
% if isempty(Hd) || fs ~= last_fs
%   h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, ...
%                        Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);
% 
%   Hd = design(h, 'cheby2', 'MatchExactly', 'stopband', 'SOSScaleNorm', 'Linf');
%   last_fs = fs;
% end
% 
% data_filt = filter(Hd, data);
% 
% t = (0:length(data)-1).'/fs;
% fc = 1675; % Hz
% data_baseband = data_filt.*exp(-j*2*pi*fc*t); % Mix to baseband
% 
% % Square and decimate to sample to power every 0.1 sec
% dec_factor = floor(fs/10);
% data_power = decimate(abs(data_baseband).^2, dec_factor);
% 
% % bw = Fstop2 - Fstop1;
% % dec_factor = floor(fs/bw);
% % data = decimate(data, dec_factor);
% % fs_dec = fs/dec_factor;

function em_ampl = find_auroral_hiss_events(f, s_mediogram)
%% Function: find_auroral_hiss_events
% Auroral hiss is a giant broadband emission that can extend past the
% antialiasing filter
% In theory, we could just get the total signal power above 5 kHz or so,
% but there's often, but not always, a whole mess of station noise between
% 18-25 kHz, mainly May-Sept.  So we'll get the whole signal amplitude in a
% range, but ignoring that frequency range

event_struct = struct('f_lc', {}, 'f_uc', {}, 'ec', {});

f_lc = 5e5; % Hz
f_uc = 40e3; % Hz

f_lc_exclude = 18e5;
f_uc_exclude = 26e5;

%% Block out noisy parts of the spectrum
s_mediogram(f >= f_lc_exclude & f <= f_uc_exclude) = -inf;

%% Get the broadband power
em_ampl = get_true_emission_amplitude(f, s_mediogram, nearest_dan(f, f_lc), nearest_dan(f, f_uc));
