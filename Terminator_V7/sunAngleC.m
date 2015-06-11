function [h,az] =  sunAngleC(lat,lon,T)

T_day = tFormat(T);
s = size(lat);
num_pts = s(1)*s(2);
h = zeros(s);
az = zeros(s);

tic
fid = fopen('lats_lons','w');
fwrite(fid,lat,'float');
fwrite(fid,lon,'float');
fclose(fid);

if(1)
    [w,string] = dos(['sunAngle ' num2str(T(1)) ' ' num2str(T(2)) ' ' num2str(T(3)) ' ' ...
            num2str(T(4)) ' ' num2str(T(5)) ' ' num2str(T(6)) ' ' num2str(num_pts)]);
else
    [w,string] = dos(['sunAngle2 ' num2str(T_day(1)) ' ' num2str(T_day(2)) ' ' num2str(T_day(3)) ' ' ...
            num2str(T_day(4)) ' ' num2str(floor(T_day(5))) ' ' num2str(num_pts)]);
end

%dos_output = string

fid = fopen('h_az','r');
h = fread(fid,[s(1),s(2)],'float=>double');
az = fread(fid,[s(1),s(2)],'float=>double');
fclose(fid);
%toc

