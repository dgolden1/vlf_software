function [hour, minute, second] = sunrise(lat,lon,alt,civil_sun,year,month,day);

%finds sunrise time
%civil_sun is 1 or 0
%alt is altitude (ignored if civil_sun = 1, used if civil_sun = 0)

%sunrise: sun_dark goes from 0 to 1:

%sunshine and sunshine_civil not desiged to take vector time data, so iteratively converge for
%speed:
hourList = [0:23];
minuteList = [0:59];
secondList = [0:59];
m = 0;
s = 0;

try
    for h = hourList
        [sun_dark(h+1),elev(h+1),az(h+1)] = sunshine(lat,lon,alt,civil_sun,year,month,day,h,m,s);
    end
    sun_dark(find(sun_dark<1)) = 0; %ignore twilight
    if((sun_dark(1)-sun_dark(end))==1) %if at hour 23
        hour = hourList(end);
    else
        hour = hourList(find(diff(sun_dark)==1));
    end
    
    for m = minuteList
        [sun_dark(m+1),elev(m+1),az(m+1)] = sunshine(lat,lon,alt,civil_sun,year,month,day,hour,m,s);
    end
    sun_dark(find(sun_dark<1)) = 0; %ignore twilight
    if(max(max(sun_dark))==0)
        minute = 59;
    else
        minute = minuteList(find(diff(sun_dark)==1));
    end
    
    for s = secondList
        [sun_dark(s+1),elev(s+1),az(s+1)] = sunshine(lat,lon,alt,civil_sun,year,month,day,hour,minute,s);
    end
    sun_dark(find(sun_dark<1)) = 0; %ignore twilight
    if(max(max(sun_dark))==0)  %always dark until very end of minute
        second = 59;
    else  
        second = secondList(find(diff(sun_dark)==1));
    end
    
catch   %no sunrise
    hour = NaN;
    minute = NaN;
    second = NaN;
end
