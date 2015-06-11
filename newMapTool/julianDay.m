function JD =  julianDay(T);

year = T(1);
month = T(2);
day = T(3);
hour = T(4);
minute = T(5);
second = T(6);

if(month <= 2)
    month = month + 12;
    year = year - 1;
end

A = floor(year/100);
B = 2-A+floor(A/4);
JD = floor(365.25*(year + 4716)) + floor(30.6004*(month + 1)) + day + B - 1524.5;
JD = JD + (hour + minute/60+second/3600)/24;
