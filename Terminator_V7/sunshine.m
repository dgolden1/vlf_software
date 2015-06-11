function [sun, h, az] = sunshine(lat,lon,alt,civil_sun,year,month,day,hour,minute,second)

%At an alititude alt [m], latitude lat [deg], and longitude lon [deg], at the specified time in UT, calculates
%the eleveation h [deg] and azimuth az [deg] of the sun as seen from the ground, and determines
%whether or not the sun shines at altitude h (ignores refraction).
%az is measured east from north (so 0 < az < 360).  Note that -90 < h < 90
%sun is 1 if that point sees the sun, 0 otherwise.  

if(1)
    [h,az] =  sunAngle(lat,lon,year,month,day,hour,minute,second);
else
    [h,az] =  sunAngle2(lat,lon,year,month,day,hour,minute,second);
end

az(find(az<0)) = az(find(az<0))+360;
sun = zeros(size(h));
if(civil_sun)
    %civil sunset:  50 arcminutes below the plane = average apparent radius of
    %   sun (16 arcminutes) to average atmospheric refraction (34 arcminutes).  

    sun(find(h>-50/60)) = 1;    %daylight
    %civil twilight: extends until sun is 6 degrees below horizon
    sun(find(h>-6&h<=-50/60)) = .5; %civil twilight
else %use altitude
    %radius of the earth:
    R = 6371010;    %[m]
    sun(find(h*pi/180 > -acos(R/(R+alt)))) = 1;
end
