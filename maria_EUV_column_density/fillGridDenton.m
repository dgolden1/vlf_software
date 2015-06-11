
Lpp = 4.5;
MLT = 06;
Kp = 2.5;

%nne = sheeleyCA( LL, Lpp, MLT );
nne = gcpm2( LL, MLT, Kp );
ii = find( LL > 6 );
%nne(ii) = nne(ii(1));
%nne = ca92_Lpp( LL, Lpp, MLT );

P = 150;

for( k = 1:size(L, 1) )
    for( m = 1:size(L, 2) )
		if( R(k,m) > 1.5 & L(k,m) > 0 )
			ii = nearest( LL, L(k,m) );
			%ne(k,m) = nne( ii );
			a_rmax = 2.0-0.43*L(k,m);
			a_neo = 6.0 - 3.0*log10( nne(ii) ) +0.28*(log10( nne(ii) ))^2;
			a = a_rmax + a_neo;
			ne(k,m) = nne(ii) * ( L(k,m) / R(k,m) )^a;
			R_he(k,m) = 10.^(-1.541 - 0.176.*R(k,m) + 8.557e-3*P -1.458e-5*P^2);

		else
			ne(k, m) = 0;
			R_he(k,m) = 0;
		end;
    end;
end;

He = 10.^(-1.541 - 0.176.*LL + 8.557e-3*P -1.458e-5*P^2);
ni = R_he.*ne;
%He = 1;
%ni = ne;


