L = 4;

neo = 100;

a_rmax = 2.0-0.43*L;
a_neo = 6.0 - 3.0*log10( neo ) +0.28*( log10( neo ) )^2;
a = a_rmax + a_neo;

lat = deg2rad( 0:75 );

for( k = 1:length(lat ) )

	r = L .* ( cos( lat(k) ) )^2;
	n(k) = neo * ( L / r )^a;
end;


clf;
plot( rad2deg(lat), n );
