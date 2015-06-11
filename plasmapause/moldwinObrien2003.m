function Lpp = moldwinObrien2003(MLT, Kp)

phi = 2*pi.*(MLT./24);

% Kp (max 2-36 hrs)
Q = Kp;
a_1 = -0.39;
a_MLT = -0.34;
a_phi = 16.6*2*pi/24;

b_1 = 5.6;
b_MLT = 0.12;
b_phi = 3*2*pi/24;

Lpp = a_1.*( 1+a_MLT.*cos(phi-a_phi) ).*Q + b_1*( 1+b_MLT.*cos(phi-b_phi) );

