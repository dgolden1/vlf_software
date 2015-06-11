function [L,latf,lonf,m] = trace_L_shell(Rstart,lat,lon,ds,geo_sm_flag,Rf,T)
%
%traces from point (Rstart,lat,lon) to (Rf,latf,lonf)
%T = [year, month, day, hour, minute, second];
%Rstart, Rf in terms of earth radii

%For conjugate points: 
% geo_sm_flag should be 1
%ds should be (.05 - 3)*sign(lat)

%For L-shell points:
%geo_sm_flag should be 0
%ds should be -(.05-3)*sign(lat)

%% Modify this based on your local computer:
trace_prog_folder = fullfile(danmatlabroot, 'vlf', 'l_shell_mapping', 'trace', 'Debug'); 

%% 

float_fmt = 'float32';

num_tasks = length(Rstart);

fid = fopen(fullfile(trace_prog_folder,'parameters'),'w');
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
 
%% if running Unix, may need to modify:
if(isunix)
	curr_dir = pwd; cd(trace_prog_folder);
	[w,s] = unix(['./trace_linux64 ' num2str(T_day_format(1)) ' ' num2str(T_day_format(2)) ' ' num2str(T_day_format(3)) ' ' ...
		num2str(T_day_format(4)) ' ' num2str(floor(T_day_format(5))) ' ' num2str(num_tasks)]);
	cd(curr_dir);

  if w ~= 35
    error('Trace failed: %s', s);
  end

else
	curr_dir = pwd; cd(trace_prog_folder);
	[w,s] = dos(['trace_win32.exe ' num2str(T_day_format(1)) ' ' num2str(T_day_format(2)) ' ' num2str(T_day_format(3)) ' ' ...
		num2str(T_day_format(4)) ' ' num2str(floor(T_day_format(5))) ' ' num2str(num_tasks)]);
	cd(curr_dir);
end

%% Everything else should be system independent
dos_output = s;
this_format = 'float';
fid = fopen(fullfile(trace_prog_folder,'trace'),'r');
% DEBUG
% fid = fopen('/home/dgolden/temp/trace/trace.out','r');
for i = 1:num_tasks
    rterminate(i) = fread(fid,1,this_format);
    latf(i) = fread(fid,1,this_format);
    lonf(i) = fread(fid,1,this_format);
    L(i) = fread(fid,1,this_format);
    if isunix
      m(i) = fread(fid,1,'int64');
    else
      m(i) = fread(fid,1,'int32');
    end
    gst(i) = fread(fid,1,this_format)*180/pi;
    sdec(i) = fread(fid,1,this_format)*180/pi;
end
fclose(fid);

%% tFormat
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

%% isLeap
function out = isLeap(year)

out = 0;
if(mod(year,4)==0)
    out = 1;
end
if(mod(year,100)==0)
    out = 0;
end
if(mod(year,400)==0)
    out = 1;
end
