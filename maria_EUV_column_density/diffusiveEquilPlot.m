clf;
hold on;

%%%%%%%%%
% INPUTS
%%%%%%%%%

LL = [2 4 6];
col = 'rbgkcm';

for( k = 1:length( LL ) )

	L = LL(k);
	Ro = 6378;
	R1 = Ro+1000;
	lamda_o = acos(sqrt( R1 / (L*Ro) ) );

	lamda = [0:1*pi/180:lamda_o];
	neq = 10;

	ne = diffusiveEquil(L, lamda, neq, 1 );

	R = L .* cos(lamda).^2;
	n = neq*(Ro*L)^4.*R.^-4;

	subplot(2,1,1);
	hold on;
	plot( lamda*180/pi, ne, [col(k)] );
	ylim([0 100])
	%plot( lamda*180/pi, n, [col(k) '--'] );
	plot( lamda_o .* [1 1].*180/pi, ylim, [col(k) '--'] );
	xlabel('\lambda');
	ylabel('ne');

	subplot(2,1,2);
	hold on;
	plot( R, ne, [col(k)] );
	ylim([0 100])
	xlabel('r');
	ylabel('ne');
	

end;



