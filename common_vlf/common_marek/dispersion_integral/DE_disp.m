 function [t_array]=DE_disp(f_array,Lshell,Neq,model,Dci)
 global f;
 global n_eq;
 global L;
 global sigma;
 global T;
 global phi1;
 
 ro=6380e3; %radius of the Earth
 
 %User input here
 if (nargin<5)
     Dci=6;
 end
 if (nargin<4)
     model='DE-1';
 end
 
 L=Lshell;
 n_eq=Neq*100^3;
 low_freq=500;
 high_freq=3000;
 num_points=length(f_array);
 
 %end user input
 
 phi1=acos(sqrt((ro+1000e3)./(ro*L))); % 1.065; %Latitude at 1000km altitude in radians 

 switch model
     case 'DE-1' 
         sigma=[.90 .08 .02];
         T=1600;
     case 'DE-2'
         sigma=[.90 .08 .02];
         T=3200;
     case 'DE-3'
         sigma=[.50 .40 .10];
         T=1600
     case 'DE-4'
         sigma=[.50 .40 .10];
         T=800;
     otherwise
         error('Dales niewlasciwy model')
 end
 


 t_array=zeros(1,length(f_array));
 for jj=1:num_points
     f=f_array(jj);
    t_array(jj) = quad(@integrand,0,phi1)/3e8+Dci*1/sqrt(f); 
    
end

