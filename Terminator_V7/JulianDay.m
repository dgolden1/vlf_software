function JD = JulianDay(year, month, day, hour, minute, second)

%JulianDay1

%Inputs: date, month, year, UT in hours, minutes
%Outputs = Julian Day

if (month<=2)
    month = month + 12;
    year = year - 1;
end

A = floor(year/100);
B = 2-A+floor(A/4);

JD = floor(365.25*(year+4716))+floor(30.6001*(month+1)) + day + B - 1524.5;

JD = JD + (hour+minute/60+second/3600)/24;

%Matches http://aa.usno.navy.mil/data/docs/JulianDate.html

