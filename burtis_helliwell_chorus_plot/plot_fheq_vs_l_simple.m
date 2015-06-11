function plot_fheq_vs_l_simple
% Function to plot a simple "expected chorus region" in fHeq vs. l,
% assuming a generation region between 0.1 and 0.5 fHeq

%% Setup
L_NPTS = 1e2;
f_max = 10; % kHz
f_max_palmer = 6; % max frequency seen at Palmer, kHz
f_min_palmer = 0.3; % min frequency seen at Palmer, kHz

%% Formulae
r_o = 6370e3;
L = linspace(2, 8, L_NPTS);
r_eq = r_o*L;
fHeq = 8.736e5*(r_o./r_eq).^3;
fHeq = fHeq / 1e3; % Convert from Hz to kHz

figure;
hold on;
grid on;


% %% Plot Palmer chorus frequency
% hold on;
% plot(L([1 end]), [0 0], 'k-', 'LineWidth', 2);
% plot(L([1 end]), [6 6], 'k-', 'LineWidth', 2);
% fill(L([1 end end 1]), [0 0 6 6], [1 0.5 0.5]);

%% Plot chorus region
% fill_color = [1 0.5 0.5];
% index_low = 0.1*fHeq < f_max;
% index_high = 0.5*fHeq < f_max;
% fill([L(index_low) fliplr(L(index_high))], [0.1*fHeq(index_low) fliplr(0.5*fHeq(index_high))], fill_color)

%% Plot Palmer chorus frequency
% plot(L([1 end]), [0 0], 'k-', 'LineWidth', 2);
% plot(L([1 end]), [6 6], 'k-', 'LineWidth', 2);
fill_color = [1 0.45 0];

index_low = 0.1*fHeq >= f_min_palmer & 0.1*fHeq <= f_max_palmer;
index_high = 0.5*fHeq >= f_min_palmer & 0.5*fHeq <= f_max_palmer;

x_01 = [interp1(0.1*fHeq, L, f_max_palmer), L(index_low), interp1(0.1*fHeq, L, f_min_palmer)];
x_05 = [interp1(0.5*fHeq, L, f_max_palmer), L(index_high), interp1(0.5*fHeq, L, f_min_palmer)];
y_01 = [f_max_palmer, 0.1*fHeq(index_low), f_min_palmer];
y_05 = [f_max_palmer, 0.5*fHeq(index_high), f_min_palmer];

f = fill([x_01 fliplr(x_05)], [y_01 fliplr(y_05)], fill_color, 'LineWidth', 2);


%% Other stuff
plot(L, 0.1*fHeq, 'k--', 'LineWidth', 4);
plot(L, 0.5*fHeq, 'k--', 'LineWidth', 4);

%% Labels
ylim([0 f_max]);
xlabel('L shell');
ylabel('Frequency (Hz)');

increase_font(gcf, 16);
