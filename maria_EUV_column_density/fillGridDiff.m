
Lpp = 4.5;
MLT = 06;
Kp = 2.5;

nne = gcpm2( LL, MLT, Kp );
%nne = ca92_Lpp( LL, Lpp, MLT );
%nne = sheeleyCA( LL, Lpp, MLT );

He = 1.0;
%P = 155;
%He = 10.^(-1.541 - 0.176.*LL + 8.557e-3*P -1.458e-5*P^2);
nne = nne .* He;

for( k = 1:size(L, 1) )
    for( m = 1:size(L, 2) )
		if ( R(k,m) > 1 & R(k,m) < 1.2 )
			ne(k,m) = 10^5;
		elseif( R(k,m) >= 1.2 & L(k,m) > 1 )
			ii = nearest( LL, L(k,m) );
			ne(k,m) = diffusiveEquil(LL(ii), abs(lat(k,m)), nne(ii), 1 );
			%ne(k, m) = nne( ii ); 
		else
			ne(k, m) = 0;
		end;
    end;
end;


ni = ne;

