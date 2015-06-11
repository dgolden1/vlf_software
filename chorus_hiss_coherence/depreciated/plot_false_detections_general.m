function plot_false_detections_general
% Determine false positives and negatives in a more general way than
% plot_false_detections.m

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

% close all;

%% Load databases
db_test = load('/media/amundsen/user_data/dgolden/temp/burstiness/auto_chorus_hiss_03_20/auto_chorus_hiss_db_2001_03_20.mat');
db_truth = load('/home/dgolden/vlf/case_studies/chorus_hiss_detection/auto_chorus_hiss_db_2001.mat');

%% Get correct detections, false positives and false negatives
syn_datenums = (floor(min([db_test.events.start_datenum])) + 5/1440):1/96:ceil(max([db_test.events.start_datenum]));

% Delete truth events outside the time range of the test events
db_truth.events([db_truth.events.start_datenum] < syn_datenums(1) | ...
  [db_truth.events.start_datenum] > syn_datenums(end)) = [];

% Loop over test events.  Any test event that is at least req_frac_overlap
% covered by a truth event is a correct detection.  Any test event that
% does not meet this criteria is a false positive.  Any truth event that is
% not at least req_frac_overlap covered by a test event is a false
% negative.

% Under this scheme, if a truth event is covered by two test events
% (neither of which covers it by req_frac_overlap), it will still be marked
% as a false negative.  This is a bug.

% Also, if an overlapping test and truth event may have the test event
% marked as a correct detection and the truth event marked as a false
% negative, or may have the test event marked as a false positive and the
% truth event NOT marked as a false negative, depending on how asymmetric
% the overlap is.  This is a feature.

req_frac_overlap = 0.5;

b_corr_detect = false(size(db_test.events));
b_false_negative = true(size(db_truth.events));
for kk = 1:length(syn_datenums)
  this_test_emissions_idx = find(abs([db_test.events.start_datenum] - syn_datenums(kk)) < 1/1440);
  this_truth_emissions_idx = find(abs([db_truth.events.start_datenum] - syn_datenums(kk)) < 1/1440);
  for jj = 1:length(this_test_emissions_idx)
    for ll = 1:length(this_truth_emissions_idx)
      f_test_lc = db_test.events(this_test_emissions_idx(jj)).f_lc;
      f_test_uc = db_test.events(this_test_emissions_idx(jj)).f_uc;
      f_truth_lc = db_truth.events(this_truth_emissions_idx(ll)).f_lc;
      f_truth_uc = db_truth.events(this_truth_emissions_idx(ll)).f_uc;
      
      % If this emission from the test database has more than 75% of its
      % area contained in this emission from the truth database, then this
      % emission in the test database is a correct detection
      if f_test_uc > f_truth_lc && f_test_lc < f_truth_uc && ... % There is some overlap
          min([f_test_uc, f_truth_uc]) - max([f_test_lc, f_truth_lc]) >= req_frac_overlap*(f_test_uc - f_test_lc)
        b_corr_detect(this_test_emissions_idx(jj)) = true;
      end
      
      % If this emission from the truth database is more than 75% covered
      % by this emission from the test database, then this emission in the
      % truth database is not a false negative
      if f_test_uc > f_truth_lc && f_test_lc < f_truth_uc && ... % There is some overlap
          min([f_test_uc, f_truth_uc]) - max([f_test_lc, f_truth_lc]) >= req_frac_overlap*(f_truth_uc - f_truth_lc)
        b_false_negative(this_truth_emissions_idx(ll)) = false;
      end
    end
  end
end

events_corr_detect = db_test.events(b_corr_detect);
events_false_positive = db_test.events(~b_corr_detect);
events_false_negative = db_truth.events(b_false_negative);

n_corr_detect = sum(b_corr_detect);
n_false_positive = sum(~b_corr_detect);
n_false_negative = sum(b_false_negative);

fprintf('Correct detections: %d\n', n_corr_detect);
fprintf('False positives: %d\n', n_false_positive);
fprintf('False negatives: %d\n', n_false_negative);
fprintf('Fraction of emissions found: %0.2f\n', n_corr_detect/(n_corr_detect + n_false_negative));
fprintf('Fraction of found emissions that were correct: %0.2f\n', n_corr_detect/(n_corr_detect + n_false_positive));

return;

%% Plot histogram of false negatives/positives by date
dates = floor(min([db_truth.events.start_datenum])):ceil(max([db_truth.events.start_datenum]));
n_false_pos = histc([events_false_positive.start_datenum], dates);
n_false_neg = histc([events_false_negative.start_datenum], dates);
n_correct = histc([events_corr_detect.start_datenum], dates);

figure;

s(1) = subplot(3, 1, 1);
bar(dates + 0.5, n_correct, 1); grid on;
ylabel('Correct');

s(2) = subplot(3, 1, 2);
bar(dates + 0.5, n_false_pos, 1); grid on;
ylabel('False pos');

s(3) = subplot(3, 1, 3);
bar(dates + 0.5, n_false_neg, 1); grid on;
ylabel('False neg');

xlabel('Date');
linkaxes(s, 'x');
clear s;
datetick2('x');
increase_font;

%% Plot histogram of truth and test amplitudes
figure;

s(1) = subplot(2, 1, 1);
hist([db_test.events.amplitude], 14:2:60);
grid on;
auto_mean = mean([db_test.events.amplitude]);
auto_std = std([db_test.events.amplitude]);
title(sprintf('Test \\mu = %0.1f, \\sigma = %0.2f', auto_mean, auto_std));

s(2) = subplot(2, 1, 2);
hist([db_truth.events.amplitude], 14:2:60);
grid on;
man_mean = mean([db_truth.events.amplitude]);
man_std = std([db_truth.events.amplitude]);
title(sprintf('Truth \\mu = %0.1f, \\sigma = %0.2f', man_mean, man_std));

xlabel('Emission amplitude (dB-fT)');
linkaxes(s);
axis auto;
clear s;
increase_font;

%% Plot histograms of correct detections, false positives and false negatives
figure;

% Correct detections
s(1) = subplot(3, 1, 1);
hist([events_corr_detect.amplitude], 14:2:60);
grid on;
cd_mean = mean([events_corr_detect.amplitude]);
cd_std = std([events_corr_detect.amplitude]);
title(sprintf('Correct detections \\mu = %0.1f, \\sigma = %0.2f', cd_mean, cd_std));

% False positives
s(2) = subplot(3, 1, 2);
hist([events_false_positive.amplitude], 14:2:60);
grid on;
fp_mean = mean([events_false_positive.amplitude]);
fp_std = std([events_false_positive.amplitude]);
title(sprintf('False positives \\mu = %0.1f, \\sigma = %0.2f', fp_mean, fp_std));

% False negatives
s(3) = subplot(3, 1, 3);
hist([events_false_negative.amplitude], 14:2:60);
grid on;
fn_mean = mean([events_false_negative.amplitude]);
fn_std = std([events_false_negative.amplitude]);
title(sprintf('False negatives \\mu = %0.1f, \\sigma = %0.2f', fn_mean, fn_std));

xlabel('Emission amplitude (dB-fT)');
linkaxes(s);
axis auto;
clear s;
figure_grow(gcf, 1, 1.5);
increase_font;

%% Ditto for upper cutoff
figure;

% Correct detections
s(1) = subplot(3, 1, 1);
hist([events_corr_detect.f_uc], 200:200:8000);
grid on;
cd_mean = mean([events_corr_detect.f_uc]);
cd_std = std([events_corr_detect.f_uc]);
title(sprintf('Correct detections \\mu = %0.0f, \\sigma = %0.0f', cd_mean, cd_std));

% False positives
s(2) = subplot(3, 1, 2);
hist([events_false_positive.f_uc], 200:200:8000);
grid on;
fp_mean = mean([events_false_positive.f_uc]);
fp_std = std([events_false_positive.f_uc]);
title(sprintf('False positives \\mu = %0.0f, \\sigma = %0.0f', fp_mean, fp_std));

% False negatives
s(3) = subplot(3, 1, 3);
hist([events_false_negative.f_uc], 200:200:8000);
grid on;
fn_mean = mean([events_false_negative.f_uc]);
fn_std = std([events_false_negative.f_uc]);
title(sprintf('False negatives \\mu = %0.0f, \\sigma = %0.0f', fn_mean, fn_std));

xlabel('Emission upper cutoff (Hz)');
linkaxes(s);
axis auto;
clear s;
figure_grow(gcf, 1, 1.5);
increase_font;


1;
