function plot_false_detections
% Get a statistical feel for the nature of false positives and false
% negatives in the 2001 data

% By Daniel Golden (dgolden1 at stanford dot edu) March 2010
% $Id$

% close all;

%% Load databases
auto = load('/media/scott/user_data/dgolden/burstiness/2001/auto_chorus_hiss_db_2001.mat');
man = load('/home/dgolden/vlf/case_studies/chorus_hiss_detection/auto_chorus_hiss_db_2001.mat');

%% Get correct detections, false positives and false negatives

% Any synoptic epoch in the manually-corrected database that does not have
% a manual correction is a correct detection
b_corr_detect = ~strcmp({man.events.notes}, 'manual');
events_corr_detect = man.events(b_corr_detect);

% Any event in the auto database that does not have a corresponding event
% with the same time and cutoffs in the correct detection list is a false
% positive.
% This includes events which have had their cutoffs widened manually.
b_false_positive = false(size(auto.events));
% cd_start_datenum = [man.events(b_corr_detect).start_datenum];
% cd_f_lc = [man.events(b_corr_detect).f_lc];
% cd_f_uc = [man.events(b_corr_detect).f_uc];
cd_start_datenum = [events_corr_detect.start_datenum];
cd_f_lc = [events_corr_detect.f_lc];
cd_f_uc = [events_corr_detect.f_uc];
for kk = 1:length(b_false_positive)
  % If there's no known correct detection with the same start time, and
  % upper and lower cutoff as this event in the auto database, then this
  % event is a false positive
  if ~any(cd_start_datenum == auto.events(kk).start_datenum & ...
         cd_f_lc == auto.events(kk).f_lc & ...
       cd_f_uc == auto.events(kk).f_uc);
    b_false_positive(kk) = true;
  end
end
events_false_positive = auto.events(b_false_positive);

% Any synoptic epoch in the manually-corrected database that has a manual
% addition is a false negative
b_false_negative = strcmp({man.events.notes}, 'manual');
events_false_negative = man.events(b_false_negative);


%% Plot histogram of false negatives/positives by date
dates = floor(min([man.events.start_datenum])):ceil(max([man.events.start_datenum]));
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
linkaxes(s, 'x'); clear s;
datetick2('x');
increase_font;



%% Plot histogram of manual and auto amplitudes
figure;

s(1) = subplot(2, 1, 1);
hist([auto.events.amplitude], 14:2:60);
grid on;
auto_mean = mean([auto.events.amplitude]);
auto_std = std([auto.events.amplitude]);
title(sprintf('Auto output \\mu = %0.1f, \\sigma = %0.2f', auto_mean, auto_std));

s(2) = subplot(2, 1, 2);
hist([man.events.amplitude], 14:2:60);
grid on;
man_mean = mean([man.events.amplitude]);
man_std = std([man.events.amplitude]);
title(sprintf('Manually corrected \\mu = %0.1f, \\sigma = %0.2f', man_mean, man_std));

xlabel('Emission amplitude (dB-fT)');
linkaxes(s); clear s;
xlim([15 60]);
ylim([0 300]);
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
linkaxes(s); clear s;
xlim([15 60]);
ylim([0 250]);
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
linkaxes(s); clear s;
% xlim([15 60]);
ylim([0 450]);
figure_grow(gcf, 1, 1.5);
increase_font;



disp('');
