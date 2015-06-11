function [L,latf,lonf,m] = trace(Rstart,lat,lon,ds,geo_sm_flag,Rf,T)

%traces from point (Rstart,lat,lon) to (Rf,latf,lonf)
%T = [year, month, day, hour, minute, second];
%Rstart, Rf in terms of earth radii

%For conjugate points: 
% geo_sm_flag should be 1
%ds should be (.05 - 3)*sign(lat)

%For L-shell points:
%geo_sm_flag should be 0
%ds should be -(.05-3)*sign(lat)

%Example for DEMETER satellie footprint over Europe
%[L,latf,lonf,m] = trace(1+700/6370,45,10,-0.1*sign(45),1,1,[2005, 8, 1, 1, 1, 1])

CurrDir = cd;
cd('/home/dgolden/vlf/vlf_software/dgolden/l_shell_mapping/trace/Debug') %change this to the name of directory where you put trace toolbox files

num_tasks = length(Rstart);


fid = fopen('parameters','w');
for i = 1:num_tasks
    fwrite(fid,Rstart(i),'float');
    fwrite(fid,lat(i),'float');
    fwrite(fid,lon(i),'float');
    fwrite(fid,ds(i),'float');
    fwrite(fid,geo_sm_flag(i),'float');
    fwrite(fid,Rf(i),'float');
end
fclose(fid);

T_day_format = tFormat(T); %T_day_format = [year, day, hour, minute, second];


[w,s] = unix(['./trace.exe ' num2str(T_day_format(1)) ' ' num2str(T_day_format(2)) ' ' num2str(T_day_format(3)) ' ' ...
        num2str(T_day_format(4)) ' ' num2str(floor(T_day_format(5))) ' ' num2str(num_tasks)]);
dos_output = s;
fid = fopen('trace','r');
for i = 1:num_tasks
rterminate(i) = fread(fid,1,'float=>double');
latf(i) = fread(fid,1,'float=>double');
lonf(i) = fread(fid,1,'float=>double');
L(i) = fread(fid,1,'float=>double');
m(i) = fread(fid,1,'int=>double');
gst(i) = fread(fid,1,'float=>double')*180/pi;
sdec(i) = fread(fid,1,'float=>double')*180/pi;
end
fclose(fid);

if(0)
sdec(1)
gst(1)

disp('results:')
rterminate(1)
latf(1)
lonf(1)
end

cd(CurrDir)
