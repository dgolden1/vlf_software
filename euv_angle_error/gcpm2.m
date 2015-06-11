function [n_ps, L, g, h, trans_pt] = gcpm(L, MLT, Kp)
% MLT = [1:24]

b1 = 0.0027*cos((MLT)*pi/12) - 0.448;
b2 = 0.0373*cos((MLT)*pi/12) + 5.747;
b3 = 0.8352*cos((MLT)*pi/12) - 3.809;
b4 = -8.415*cos((MLT)*pi/12) + 41.53;


bulgeMLT = 47/(Kp+3.9)+11.3;
x = abs(bulgeMLT - MLT)*pi/12;

a8 = (b1*Kp + b2)*(1+exp(-1.5*x^2 + 0.08*x - 0.7));
a9 = b3*Kp + b4;

g = (-0.79.*L+5.3);

exp1 = 2*(a9-1);
exp2 = -a9/(a9-1);
h = ( 1 + (L./a8).^exp1 ).^(exp2);

% Log10 density
n_ps = 10.^(g.*h)-1;

phi_tp = 0.145*Kp^2 - 2.63*Kp + 21.86;
geo_trough(1:3) = 0.18;
geo_trough(4) = 0.18+.56/2;

for( k = 5:floor(phi_tp) )
	geo_trough(k) = geo_trough(k-1)+0.56;
end;
for( k = ceil(phi_tp):24 )
	geo_trough(k) = geo_trough(k-1)-0.83;
end;
%geo_trough
n_trough = geo_trough(MLT).*(L./6.6).^-4.5;

trans_pt = find( n_trough > n_ps );
trans_pt = trans_pt(1);

n_ps(trans_pt:end) = n_trough(trans_pt:end);

%bulgeMLT
%phi_tp

return;
