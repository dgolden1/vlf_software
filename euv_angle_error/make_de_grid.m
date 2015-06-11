function [x, y, ne, L] = make_de_grid
% [x, y, ne, L] = make_de_grid
% 
% Function to make a mesh valued with plasma density using a GCPM and diffusive
% equilibrium model

%% Create mesh
dx = 0.05;
x = 0:dx:8;
y = -4:dx:8;

[xx, yy] = meshgrid( x, y );

R = sqrt( xx.^2 + yy.^2 );
lat = atan2( yy, xx );

L = R ./ cos( lat ).^2;
for k = 1:size(L, 1) 
	for m = 1:size(L, 2) 
		if( L(k,m) > 10 )
				L(k,m) = nan;

		end;
	end;
end;

LL = 1:dx/10:8;

%% Apply PP model
MLT = 06;
Kp = 2.5;

nne = gcpm2( LL, MLT, Kp );
%nne = ca92_Lpp( LL, Lpp, MLT );
%nne = sheeleyCA( LL, Lpp, MLT );

He = 1.0;
%P = 155;
%He = 10.^(-1.541 - 0.176.*LL + 8.557e-3*P -1.458e-5*P^2);
nne = nne .* He;

LL_max = max(LL);
LL_min = min(LL);

ne = zeros(size(L));
% for k = 1:size(L, 1)
%     for m = 1:size(L, 2) 
% 		if ( R(k,m) > 1 && R(k,m) < 1.2 )
% 			ne(k,m) = 10^5;
% 		elseif( R(k,m) >= 1.2 && L(k,m) > 1 )
% % 			ii = nearest( LL, L(k,m) );
% 
% 			if L(k,m) > LL_max || L(k,m) < LL_min
% 				nne_int = nan;
% 			else
% 				nne_int = interp1(LL, nne, L(k,m));
% 			end
% 			ne(k,m) = diffusiveEquil(L(k,m), abs(lat(k,m)), nne_int, 1 );
% 			%ne(k, m) = nne( ii ); 
% 		else
% 			ne(k, m) = 0;
% 		end
% 	end
% end

nne_int = interp1(LL, nne, L(:));
for kk = 1:length(nne_int)
	ne(kk) = abs(diffusiveEquil(L(kk), abs(lat(kk)), nne_int(kk), 1));
end

mask1 = R > 1 & R < 1.2;
mask2 = ~mask1 & (R >= 1.2 & L > 1);
ne(mask1) = 1e5; % Ionosphere

mask3 = ~mask1 & ~mask2 | (~isreal(ne) | isnan(ne));
ne(mask3) = 0; % Outside magnetosphere values
disp('');
