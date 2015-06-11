figure(1);
makeGrid;
fillGridDiff;
Lo = 2.5;
makePlotPP;

Lo = [ 3.0 3.5 4.0 4.3]; % List of l-shells
lamda_o = [ 7 8.250 9.25 10] .*pi/180;
%Lo = [ 3.0];
%lamda_o = [ 7 ] .*pi/180;
llamda = linspace( -pi/2, pi/2 );

col = 'rgyrkbrkbrkbr';
for( k = 1:length( lamda_o ) )

	[a_t, b_t] = dipoleTangent( Lo(k), lamda_o(k) );

	line_y = yy;
	line_x = ( line_y - b_t ) ./ a_t;

	for( m = 1:length( line_y ) )
		ii = nearest( xx, line_x( m ) );
		columnL(m) = L(m, ii);
		columnNi(m) = ni(m,ii);
		%columnL(m) = R(m,ii);
	end;

	ii = find( columnL > 0 );
	columnL = columnL(ii);
	columnNi = columnNi(ii);

	[ii, jj] = min( columnL );
	columnL = columnL - ii;
	columnL(1:jj) = -columnL(1:jj);

	[columnL, jj] = sort( columnL );	
	columnNi = columnNi(jj);

	axes( h_ax(1) );

	% PLOT TANGENT
	plot( line_x, line_y, [col(k) '-'] );

	% PLOT FIELD LINE 
    rr = Lo(k).*cos(llamda).^2;
    B_x = rr.*cos(llamda);
    B_z = rr.*sin(llamda);
    plot(B_x, B_z, [col(k) '-']);


	xlim([0 6]);
	ylim([-3 3]);

	% Plot field line on 1-D density profile
	axes( h_ax(2) );
	plot( Lo(k)*[1 1], ylim, [col(k) '-'] );
	xlim([0 6]);

	axes( h_ax(3) );
	
	columnNi = columnNi / trapz( columnL, columnNi);
	plot( columnL, columnNi, [col(k+3) '-'] );
	hold on;
	
	yyyy = max(columnNi);
	yy3dB = yyyy*0.707;	

	mmm = find( columnNi > yy3dB );
	%plot( columnL(mmm(1))*[1 1], ylim, 'k--');
	%plot( columnL(mmm(end))*[1 1], ylim, 'k--');
	columnL(mmm(end))-columnL(mmm(1))

	figure(2);
	%clf;
	hold on;
	dL = [-2:0.1:2];
	for( kk = 1:length(dL ) )
		ii  = find( columnL < dL(kk) );
		zz(kk) = trapz( columnL(ii), columnNi(ii) );
	end;
	plot( dL, zz, col(k+3) );
	figure(1);


end;


