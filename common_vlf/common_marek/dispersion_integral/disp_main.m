 
 global f;
 global n_eq;
 global L;
 global sigma1;
 global Temp;
 global phi1;
 global model;
 
 ro=6380e3; %radius of the Earth
 
 %User input here
 model='CL';
 L=5.5;
 n_eq=8*100^3;
 low_freq=1500;
 high_freq=3200;
 num_points=25;
 Dci=6;  %ionospheric dispersion contribution
 
 %end user input
 
 phi1=acos(sqrt((ro+1000e3)/(ro*L))); % 1.065; %Latitude at 1000km altitude in radians 

 switch model
     case 'DE-1' 
         sigma1=[.90 .08 .02];
         Temp=1600;
     case 'DE-2'
         sigma1=[.90 .08 .02];
         Temp=3200;
     case 'DE-3'
         sigma1=[.50 .40 .10];
         Temp=1600
     case 'DE-4'
         sigma1=[.50 .40 .10];
         Temp=800;
     case 'CL'
         Temp=1600;
     otherwise
         error('Dales niewlasciwy model')
 end
 

 f_array=[low_freq:round((high_freq-low_freq)/num_points):high_freq];
 t_array=zeros(1,length(f_array));
 for jj=1:num_points
     f=f_array(jj);
    t_array(jj) = quad(@integrand,0,phi1)/3e8 + Dci/sqrt(f_array(jj)); 
    
end
figure(5)
plot(t_array+34.4,f_array)
t1=[35.7 35.5565 35.49 35.46 35.48 35.55 35.64]'-34.35*ones(1,7)';
f1=1000*[2 2.672 3.344 4.000 4.734 5.468 6.094]';
% 
% t1=[ 35.53 35.49 35.46 35.48 35.55 35.64]';
% f1=1000*[ 2.600 3.344 4.000 4.734 5.468 6.094]';
hold on
plot(t2,f2,'ro')
hold off

%%TWo hop analysis plots from Summer 2004
% subplot(2,1,1)
% plot(t_array,f_array)
%   f2=[1580 1270 1500  1725 1870 1000 1500 2000 1230 1740 1850 1230 1950];
%  s2=[4.23 4.3 4.06  3.9 3.82 4.6 4.2 3.8 4.34 3.92 3.87 4.44 3.93];
%  
%  hold on;
%  plot(s2,f2,'ro')
%  hold off;
%  legend([model ' model'],'One-Hop Echo')
%  title(sprintf('Dispersion Curve for L= %02d Neq = %03d ee/cc',L,n_eq/100^3) )
%  subplot(2,1,2)
% plot(2*t_array,f_array)
%  f1=[1175 1550 1620 1750 1870 1600 1720 1650];
%   s1=[8.817 8.01 8.0 7.76 7.62 8 7.96 8];
%  
%  hold on;
%  plot(s1,f1,'ro')
%  hold off;
%  legend([model ' model'],'Two-Hop Echo')
%  
