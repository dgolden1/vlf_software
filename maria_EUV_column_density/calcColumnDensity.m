
figure(1)
clf;

h_ax(1) = subplot(2,2,1);
imagesc( xx, yy, log10(ni) );
axis equal;
axis image;
axis xy;
hold on;

h_c = colorbar;
axes(h_c);
ylabel('He^+ Number Density, cm^{-3}');


h_ax(2) = subplot(2,2,2);
plot( LL, log10(He.*nne) );
hold on;


x_pos = [ 3 4 4.85 ];
x_pos = [  4 5 5.65 ];
h_ax(3) = subplot(2,1,2);
hold on;

col1 = 'ywcywcywcywc';
col2 = 'bkrbkrbkrbkrbkr';
for( k = 1:length(x_pos) );

	axes(h_ax(1));
	plot( x_pos(k)*[1 1], ylim, [col2(k) '-']);
	axes(h_ax(2));
	plot( x_pos(k)*[1 1], ylim, [col2(k) '-']);
	ii = nearest( xx, x_pos(k) );
	column = ni(:, ii);
	column = column ./ max( column );
	
	columnL = L(:,ii);

	jj = find( columnL > 0 );
	columnL = columnL(jj);
	column = column(jj);

	[y jj] = min(columnL);
	columnL = columnL - y;
	columnL(1:jj) = -columnL(1:jj);
	axes(h_ax(3));
	%plot( yy, column, [col2(k) 'x-'] );
	plot( columnL, column, [col2(k) 'x-'] );


end;

plot( xlim, 0.707 .* [1 1], 'k--');
xlabel('L - L_{eq}');
ylabel('Ni / Ni_{eq}');
	

