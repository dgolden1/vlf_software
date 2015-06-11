function [nd,h,az,h_corr] = night_day(tVec,lat,lon, alt)

%Returns 0 for night, 1 for day
%alt given in km

[h,az] =  sunAngle(tVec,lat,lon);

R = 6371.010;    %[km]

nd = zeros(size(h));
nd(find(h*pi/180 > -acos(R/(R+alt)))) = 1;

h_corr = h*pi/180+acos(R/(R+alt));  %threshold at h_corr = 0
%h_corr > 0: day
%h_corr < 0: night
