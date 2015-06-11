function sp_plot_nnet_output
% Plot the output of the neural network in some fancy way


function plot_hist_by_tod
% Histogram of occurrence by time of day
load nnet_output_2001.mat

edges = (0:24)/24;
nc = histc(fpart(chorus_datenums), edges); nc = nc(1:end-1);
nh = histc(fpart(hiss_datenums), edges); nh = nh(1:end-1);
n_total = histc(fpart(input_datenums), edges); n_total = n_total(1:end-1);

n_chorus_norm = nc./n_total;
n_hiss_norm = nh./n_total;

figure;
bar(edges(1:end-1) + diff(edges)/2, [n_chorus_norm; n_hiss_norm].', 1);
datetick2('x');
xlabel('UTC');
ylabel('Normalized Occurrence');
title('South Pole Chorus and Hiss Emissions 2001');
legend('Chorus', 'Hiss');
grid on;
figure_grow(gcf, 1.5, 1);
increase_font;

