function Tout = tFormat(T)

%T = [year, month, day, hour, minute, second];
%Tout = [year, day, hour, minute, second]

if(isLeap(T(1)))
    month = [31,29,31,30,31,30,31,31,30,31,30,31];
else
    month = [31,28,31,30,31,30,31,31,30,31,30,31];
end

dayc = 0;
for i=1:T(2)
    dayc = dayc + month(i);
end
dayc = dayc - month(i);
dayc = dayc + T(3);

Tout(1) = T(1);
Tout(2) = dayc;
Tout(3) = T(4);
Tout(4) = T(5);
Tout(5) = T(6);

