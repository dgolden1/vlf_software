
dx = 0.05;
xx = [0:dx:6];
yy = [-3.1:dx:3.1];

[x, y] = meshgrid( xx, yy );

R = sqrt( x.^2 + y.^2 );
lat = atan2( y, x );

L = R ./ cos( lat ).^2;
for( k = 1:size(L, 1) )
	for( m = 1:size(L, 2) )
		if( L(k,m) > 10 )
				L(k,m) = -1;

		end;
	end;
end;

LL = [1:dx/10:8];

