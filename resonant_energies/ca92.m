function [ne, L] = ca92(mlt, kp, L)
% [ne, L] = ca92(mlt, kp)
% Carpenter and Anderson 1992 plasmapause model

% L in Re
% ne in cm^-3

% Originally by Maria Spasojevic
% Modified by Daniel Golden (dgolden1) June 2008
% $Id$

if ~exist('L', 'var') || isempty(L)
  L = linspace(2.25, 8, 1000);
end

Lppi = 5.6 - 0.46*kp; 

ne_ps =  10.^(-0.3145.*L + 3.9043);

ii = find( L >= Lppi );

L2 = L(ii);

ne = ne_ps(1:ii(1)-1);

if ( mlt < 6 )
	ne_pp = ne(end) .* 10.^(-(L2 - Lppi)./0.1);
	ne_tr = (5800+300*mlt).*L.^-4.5 + (1 - exp(-(L-2)./10) );
else
	ne_pp = ne(end) .* 10.^(-(L2 - Lppi)./(0.1+0.011*(mlt-6)));
	ne_tr = (-800+1400*mlt).*L.^-4.5 + (1 - exp(-(L-2)./10) );
end;

ne = [ne ne_pp];

ii = find( ne < ne_tr );

ne( ii ) = ne_tr( ii );


