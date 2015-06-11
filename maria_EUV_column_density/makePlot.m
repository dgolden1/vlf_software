clf;
h_ax(1) = subplot(2,2,1);
imagesc( xx, yy, log10(ni) );
axis image;
axis xy;
hold on;


h_c = colorbar;
axes(h_c);
ylabel('He^+ Number Density, cm^{-3}');


h_ax(2) = subplot(2,2,2);
plot( LL, log10(He.*nne) );
hold on;

h_ax(3) = subplot(2,1,2);
hold on;
xlabel('L - L_{min}');
ylabel('He+ Density, cm3');
xlim([-2 2]);
ylim([0 5]);
%plot(
%plot( xlim, [0.707 0.707], 'k-');
%grid minor;

