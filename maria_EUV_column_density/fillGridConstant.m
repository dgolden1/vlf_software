
Lpp = 4.5;
MLT = 06;
Kp = 2.5;

%nne = sheeleyCA( LL, Lpp, MLT );
%nne = gcpm2( LL, MLT, Kp );
nne = ca92_Lpp( LL, Lpp, MLT );
%a = load('densityProfile.dat');
%LL_dp = a(:,1);
%nne_dp = a(:,2);
%nne = interp1( LL_dp, nne_dp, LL );


He = 1;

for( k = 1:size(L, 1) )
    for( m = 1:size(L, 2) )
		if( R(k,m) > 1 & L(k,m) > 0 )
			ii = nearest( LL, L(k,m) );
			ne(k, m) = nne( ii ); 
		else
			ne(k, m) = 0;
		end;
    end;
end;

ni = He .* ne;


