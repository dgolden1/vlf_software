function emstat_bayesian_predictors
% How can the presence of a given emission type predict the future presence
% of another emission type? Simple application of conditional probability, and
% borrows a bunch of code from emstat_crosscorr

% By Daniel Golden (dgolden1 at stanford dot edu) September 2008
% $Id$

%% Setup
% PALMER_LONGITUDE = -64.05;
% PALMER_MLT = PALMER_LONGITUDE/360;
PALMER_MLT = -(4+1/60)/24;

START_DATENUM = datenum([2003 01 01 0 0 0]);
END_DATENUM = datenum([2003 11 01 0 0 0]);

days = START_DATENUM:1:(END_DATENUM-1);
ndays = length(days);

XLIMS = [0.5 3.5];
YLIMS = [0 75];

%% Load emissions
load('/home/dgolden/vlf/case_studies/chorus_2003/2003_chorus_list.mat', 'events');
events = combine_cross_day_events(events);
events = convert_from_utc_to_palmerlt(events);
events = split_cross_day_events(events);

n = length(events);

%% Parse emissions into different types
[chorus_events, hiss_events, chorus_with_hiss_events] = event_parser(events);

dawn_int_start = datenum([0 0 0 03 0 0]);
dawn_int_end = datenum([0 0 0 09 0 0]);
dusk_int_start = datenum([0 0 0 14 0 0]);
dusk_int_end = datenum([0 0 0 23 0 0]);

chorus_days = find_event_days(chorus_events, days, dawn_int_start, dawn_int_end);
hiss_days = find_event_days(hiss_events, days, dusk_int_start, dusk_int_end);
chorus_with_hiss_days = find_event_days(chorus_with_hiss_events, days, dawn_int_start, dawn_int_end);

prob_chorus = sum(chorus_days)/length(chorus_days);
prob_hiss = sum(hiss_days)/length(hiss_days);
prob_chorus_with_hiss = sum(chorus_with_hiss_days)/length(chorus_with_hiss_days);

%% Make some cross-correlation vectors

delays = -5:5;
for kk = 1:length(delays)
	idx_end = abs(delays(kk))+1:ndays; % tail end
	idx_start = 1:ndays - abs(delays(kk)); % beginning part
	nvals = length(idx_start);
	if delays(kk) < 0
		idx_A = idx_end;
		idx_B = idx_start;
	else
		idx_A = idx_start;
		idx_B = idx_end;
	end
	
	% For negative delays, first emission comes first
	% For positive delays, second emission comes first
	pC_C(kk) = sum(chorus_days(idx_A) & chorus_days(idx_B))/nvals;
	pC_H(kk) = sum(chorus_days(idx_A) & hiss_days(idx_B))/nvals;
	pC_CH(kk) = sum(chorus_days(idx_A) & chorus_with_hiss_days(idx_B))/nvals;
	pH_H(kk) = sum(hiss_days(idx_A) & hiss_days(idx_B))/nvals;
	pH_CH(kk) = sum(hiss_days(idx_A) & chorus_with_hiss_days(idx_B))/nvals;
	pCH_CH(kk) = sum(chorus_with_hiss_days(idx_A) & chorus_with_hiss_days(idx_B))/nvals;
end

% %% Does an emission predict itself on the following day?
% disp(sprintf('Probability of chorus: %d%%', round(prob_chorus*100)));
% AB = sum(chorus_days(1:end-1) & chorus_days(2:end))/(ndays-1);
% B = sum(chorus_days(2:end))/(ndays-1);
% AcB = AB/B;
% disp(sprintf('Probability of chorus given chorus has occurred the previous day: %d%%', round(AcB*100)));
% 
% disp(sprintf('Probability of hiss: %d%%', round(prob_hiss*100)));
% AB = sum(hiss_days(1:end-1) & hiss_days(2:end))/(ndays-1);
% B = sum(hiss_days(2:end))/(ndays-1);
% AcB = AB/B;
% disp(sprintf('Probability of hiss given hiss has occurred the previous day: %d%%', round(AcB*100)));
% 
% disp(sprintf('Probability of chorus with hiss: %d%%', round(prob_chorus_with_hiss*100)));
% AB = sum(chorus_with_hiss_days(1:end-1) & chorus_with_hiss_days(2:end))/(ndays-1);
% B = sum(chorus_with_hiss_days(2:end))/(ndays-1);
% AcB = AB/B;
% disp(sprintf('Probability of chorus with hiss given chorus with hiss has occurred the previous day: %d%%', round(AcB*100)));

%% Does an emission predict a different type of emission?
%% Given that chorus has occurred...
figure;
pC = prob_chorus;

% ... probability that chorus will occur
subplot(3, 1, 1);
hold on;

pC_given_C = [pC_C(delays == 1) pC_C(delays == 2) pC_C(delays == 3)]/pC;

plot(XLIMS, prob_chorus*100*[1 1], 'r--');
bar(pC_given_C*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+1 day)', '(+2 day)', '(+3 day)'});
title('Probability that {\it chorus } follows {\it chorus }');

print_percent_on_bars(pC_given_C, prob_chorus);

% ... probability that hiss will occur
subplot(3, 1, 2);
hold on;

pH_given_C = [pC_H(delays == 0) pC_H(delays == -1) pC_H(delays == -2)]/pC;

plot(XLIMS, prob_hiss*100*[1 1], 'r--');
bar(pH_given_C*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+0 day)', '(+1 day)', '(+2 day)'});
title('Probability that {\it hiss } follows {\it chorus }');

print_percent_on_bars(pH_given_C, prob_hiss);

% ... probability that chorus with hiss will occur
subplot(3, 1, 3);
hold on;

pCH_given_C = [pC_CH(delays == -1) pC_CH(delays == -2) pC_CH(delays == -3)]/pC;

plot(XLIMS, prob_chorus_with_hiss*100*[1 1], 'r--');
bar(pCH_given_C*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+1 day)', '(+2 day)', '(+3 day)'});
title('Probability that {\it chorus with hiss } follows {\it chorus }');

print_percent_on_bars(pCH_given_C, prob_chorus_with_hiss);

increase_font(gcf, 16);

%% Given that hiss has occurred...
figure;
pH = prob_hiss;

% ... probability that chorus will occur
subplot(3, 1, 1);
hold on;

pC_given_H = [pC_H(delays == 1) pC_H(delays == 2)  pC_H(delays == 3)]/pH;

plot(XLIMS, prob_chorus*100*[1 1], 'r--');
bar(pC_given_H*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+1 day)', '(+2 day)', '(+3 day)'});
title('Probability that {\it chorus } follows {\it hiss }');

print_percent_on_bars(pC_given_H, prob_chorus);

% ... probability that hiss will occur
subplot(3, 1, 2);
hold on;

pH_given_H = [pH_H(delays == 1) pH_H(delays == 2)  pH_H(delays == 3)]/pH;

plot(XLIMS, prob_hiss*100*[1 1], 'r--');
bar(pH_given_H*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+1 day)', '(+2 day)', '(+3 day)'});
title('Probability that {\it hiss } follows {\it hiss }');

print_percent_on_bars(pH_given_H, prob_hiss);

% ... probability that chorus with hiss will occur
subplot(3, 1, 3);
hold on;

pCH_given_H = [pH_CH(delays == -1) pH_CH(delays == -2) pH_CH(delays == -3)]/pH;

plot(XLIMS, prob_chorus_with_hiss*100*[1 1], 'r--');
bar(pCH_given_H*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+1 day)', '(+2 day)', '(+3 day)'});
title('Probability that {\it chorus with hiss } follows {\it hiss }');

print_percent_on_bars(pCH_given_H, prob_chorus_with_hiss);

increase_font(gcf, 16);

%% Given that chorus with hiss has occurred...
figure;
pCH = prob_chorus_with_hiss;

% ... probability that chorus will occur
subplot(3, 1, 1);
hold on;

pC_given_CH = [pC_CH(delays == 1) pC_CH(delays == 2) pC_CH(delays == 3)]/pCH;

plot(XLIMS, prob_chorus*100*[1 1], 'r--');
bar(pC_given_CH*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+1 day)', '(+2 day)', '(+3 day)'});
title('Probability that {\it chorus } follows {\it chorus with hiss }');

print_percent_on_bars(pC_given_CH, prob_chorus);

% ... probability that hiss will occur
subplot(3, 1, 2);
hold on;

pH_given_CH = [pH_CH(delays == 1) pH_CH(delays == 2) pH_CH(delays == 3)]/pH;

plot(XLIMS, prob_hiss*100*[1 1], 'r--');
bar(pH_given_CH*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+0 day)', '(+1 day)', '(+2 day)'});
title('Probability that {\it hiss } follows {\it chorus with hiss }');

print_percent_on_bars(pH_given_CH, prob_hiss);

% ... probability that chorus with hiss will occur
subplot(3, 1, 3);
hold on;

pCH_given_CH = [pCH_CH(delays == 1) pCH_CH(delays == 2) pCH_CH(delays == 3)]/pCH;

plot(XLIMS, prob_chorus_with_hiss*100*[1 1], 'r--');
bar(pCH_given_CH*100);
xlim(XLIMS); ylim(YLIMS);
ylabel('Percent chance');
grid on;
set(gca, 'xtick', [1 2 3], 'xTickLabel', {'(+1 day)', '(+2 day)', '(+3 day)'});
title('Probability that {\it chorus with hiss } follows {\it chorus with hiss }');

print_percent_on_bars(pCH_given_CH, prob_chorus_with_hiss);

increase_font(gcf, 16);

%% Function: print_percent_on_bars
function print_percent_on_bars(prob_vector, prob_baseline)
% Print percentage increase/decrease on top of bars
for kk = 1:length(prob_vector)
	percent_text = sprintf('%+d%%', round(100*(prob_vector(kk) - prob_baseline)/prob_baseline));
	text(kk, prob_vector(kk)*100, percent_text, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline')
end
