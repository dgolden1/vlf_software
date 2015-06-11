function n_val=n(phi)
global n_eq;
global sigma1;
global Temp;
global model;
global L;
g1=7.3183; %accelaration of gravity at 1000 km altitude
k=1.38e-23; %Boltzman constant


%Dipersion equilibrium models
if model(1:2)=='DE'
    H=k*Temp./(g1.*([.016 .001 .004]./6.02e23));
    numerator=0;
    denomenator=0;
    for ii=1:3
        numerator=numerator+sigma1(ii).*exp(-z(phi)./H(ii));
        denomenator=denomenator+sigma1(ii).*exp(-z(0)./H(ii));
    end
    n_val=n_eq*sqrt(numerator)./sqrt(denomenator);
    return;
end

%Collisionless Model
if model=='CL'
     H=k*Temp./(g1.*(.001./6.02e23));
       numerator=0;
    denomenator=0;
     phi1=acos(sqrt((6380e3+1000e3)/(6380e3*L))); 
  
        numerator=exp(-z(phi)./(2*H))-(1-B(phi)./B(phi1)).^(1/2) .*exp(-z(phi)./(2*H.*(1-B(phi)./B(phi1))));
        denomenator=exp(-z(0)./(2*H))-(1-B(0)./B(phi1)).^(1/2) .*exp(-z(0)./(2*H.*(1-B(0)./B(phi1))));
        
    n_val=n_eq*(numerator)./(denomenator);
    return;
end
