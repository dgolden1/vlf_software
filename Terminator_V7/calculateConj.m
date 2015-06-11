function compTime = calculateConj(guiTag,lon_ave,ptOnlyFlag)
t = cputime;
compTime = -1;
%Progress and error report:
HHprogress = findobj(guiTag,'tag','progress');


%Date and time
HH = findobj(guiTag,'tag','year');
year = str2num(get(HH,'string'));
if(isempty(year)|~isnumeric(year)|round(year)~=year|~isreal(year)|year<1901|year>2099)
    set(HHprogress,'string','ERROR: year must be an integer between 1901 and 2099')
    return
end

HH = findobj(guiTag,'tag','month');
month = str2num(get(HH,'string'));
if(isempty(month)|~isnumeric(month)|round(month)~=month|month<1|month>12|~isreal(month))
    set(HHprogress,'string','ERROR: month must be integer between 1 and 12')
    return
end

HH = findobj(guiTag,'tag','day');
day = str2num(get(HH,'string'));
if(isempty(day)|~isnumeric(day)|round(day)~=day|~isreal(day))
    set(HHprogress,'string','ERROR: day must be an integer');
    return
end

HH = findobj(guiTag,'tag','hour');
hour = str2num(get(HH,'string'));
if(isempty(hour)|~isnumeric(hour)|round(hour)~=hour|~isreal(hour))
    set(HHprogress,'string','ERROR: hour must be an integer');
    return
end

HH = findobj(guiTag,'tag','minute');
minute = str2num(get(HH,'string'));
if(isempty(minute)|~isnumeric(minute)|round(minute)~=minute|~isreal(minute))
    set(HHprogress,'string','ERROR: minute must be an integer');
    return
end

HH = findobj(guiTag,'tag','second');
second = str2num(get(HH,'string'));
if(isempty(second)|~isnumeric(second)|~isreal(second))
    set(HHprogress,'string','ERROR: second must be a number');
    return
end

%plotting options
HH = findobj(guiTag,'tag','figureNo');
figureNo = str2num(get(HH,'string'));
if(isempty(figureNo)|~isnumeric(figureNo)|round(figureNo)~=figureNo|figureNo<1|~isreal(figureNo))
    set(HHprogress,'string','ERROR: figure number must be a positive integer')
    return
end

HH = findobj(guiTag,'tag','label_L');
label_L = get(HH,'Value');


HH = findobj(guiTag,'tag','circle_box');
circle_box = get(HH,'Value');

%Conjugate points:
HH = findobj(guiTag,'tag','plot_conj');
plot_conj = get(HH,'value');

HH = findobj(guiTag,'tag','spec_lat3');
spec_lat3 = str2num(get(HH,'string'));
if(plot_conj&(isempty(spec_lat3)|~isnumeric(spec_lat3)|spec_lat3<-90|spec_lat3>90|~isreal(spec_lat3)))
    set(HHprogress,'string','ERROR: coordinate 3 latitude must be in [-90,90]')
    return
end

HH = findobj(guiTag,'tag','spec_lon3');
spec_lon3 = str2num(get(HH,'string'));
if(plot_conj&(isempty(spec_lon3)|~isnumeric(spec_lon3)|spec_lon3<-180|spec_lon3>360|~isreal(spec_lon3)))
    set(HHprogress,'string','ERROR: coordinate 3 longitude must be in [-180,360]')
    return
end

HH = findobj(guiTag,'tag','alt_conj');
alt_conj = str2num(get(HH,'string'));   %[km]
if(plot_conj&(isempty(alt_conj)|~isnumeric(alt_conj)|alt_conj<0|~isreal(alt_conj)))
    set(HHprogress,'string','ERROR: Conjugate point altitude must be nonnegative number')
    return
end

HHlatf0 = findobj(guiTag,'tag','latf0');
HHlonf0 = findobj(guiTag,'tag','lonf0');
HHLshell = findobj(guiTag,'tag','Lshell');

if(~ptOnlyFlag)
    HH = findobj(guiTag,'tag','edge_box');
    edge_box = str2num(get(HH,'string'));
    if(plot_conj&(isempty(edge_box)|~isnumeric(edge_box)|edge_box<=0|~isreal(spec_lat3)))
        set(HHprogress,'string','ERROR: Edge of box of conjugate region must be a positive length')
        return
    end
end

HH = findobj(guiTag,'tag','delta_pt');
delta_pt = str2num(get(HH,'string'));
if(plot_conj&(isempty(delta_pt)|~isnumeric(delta_pt)|delta_pt<.05|delta_pt>3|~isreal(delta_pt)))
    set(HHprogress,'string','ERROR: delta for the points must be between .05 and 3.')
    return
end

HH = findobj(guiTag,'tag','delta_line');
delta_line = str2num(get(HH,'string'));
if(plot_conj&(isempty(delta_line)|~isnumeric(delta_line)|delta_line<.05|delta_line>3|~isreal(delta_line)))
    set(HHprogress,'string','ERROR: delta for the lines must be between .05 and 3.')
    return
end

%L-shells
if(~ptOnlyFlag)
    HH = findobj(guiTag,'tag','L_shell');
    L_shell_string = get(HH,'string');
    L_shell_string = deblank(L_shell_string);
    L_shell_string = strrep(L_shell_string,'(',''); 
    L_shell_string = strrep(L_shell_string,')',''); 
    L_shell_string = strrep(L_shell_string,'[',''); 
    L_shell_string = strrep(L_shell_string,']','');
    L_shell_string = lower(L_shell_string);
    for i = 1:20
        L_shell_string = strrep(L_shell_string,'  ',' ');
    end
    for i = 1:20
        L_shell_string = strrep(L_shell_string,' ',',');
    end
    for i = 1:20
        L_shell_string = strrep(L_shell_string,',,',',');
    end %now L_shell_string is comma delineated
    comma_pos = findstr(L_shell_string,',');
    comma_pos = [0,comma_pos,length(L_shell_string)+1];
    clear L
    for i = 1:length(comma_pos)-1
        L{i} = L_shell_string(comma_pos(i)+1:comma_pos(i+1)-1);
    end
    
    if(isempty(L{1}))
        L_shells = [];
    else
        try
            [L_shells,n_s] = Lread(L);
        catch
            set(HHprogress,'string','ERROR: L-shell string not formatted correctly');
            return;
        end
    end
else
    L_shells = [];
    L = [];
end


HH = findobj(guiTag,'tag','alt_L');
alt_L = str2num(get(HH,'string'));   %[km]
if(length(L)>0&(isempty(alt_L)|~isnumeric(alt_L)|alt_L<0|~isreal(alt_L)))
    set(HHprogress,'string','ERROR: L-shell altitude must be nonnegative number')
    return
end

HH = findobj(guiTag,'tag','delta_L');
delta_L = str2num(get(HH,'string'));
if(length(L)>0&(isempty(delta_L)|~isnumeric(delta_L)|delta_L<.05|delta_L>3|~isreal(delta_L)))
    set(HHprogress,'string','ERROR: delta for the L-shells must be between .05 and 3.')
    return
end

HH = findobj(guiTag,'tag','num_pts');
num_pts = str2num(get(HH,'string'));
if(length(L)>0&(isempty(num_pts)|~isnumeric(num_pts)|num_pts~=floor(num_pts)|num_pts<2|num_pts>10000|~isreal(num_pts)))
    set(HHprogress,'string','ERROR: number of points for the L-shells must be an integer between 2 and 10000')
    return
end


%feedback number of steps for conjugate/L-shell calculations
HHnum_pt_steps = findobj(guiTag,'tag','num_pt_steps');
HHnum_line_steps = findobj(guiTag,'tag','num_line_steps');
HHnum_L_steps = findobj(guiTag,'tag','num_L_steps');

%---- conjugate points and L-shells ----
R0 = 6371;

T = [year,month,day,hour,minute,floor(second)];

%First calculate conjugate points:

if(plot_conj&~ptOnlyFlag)
    lat0 = spec_lat3;
    lon0 = spec_lon3;
    %delta_pt = .1;
    delta_ray = delta_line;
    size_of_box = edge_box;  %[km]   width of box
    launch_altitude = alt_conj;    %[km]
    terminate_altitude = alt_conj; %[km]
    num_track_pts = 20;
else    %fast dummy stuff
    lat0 = 45;
    lon0 = 45;
    delta_pt = 2;
    delta_ray = 2;
    size_of_box = 1;
    launch_altitude = 0;    %[km]
    terminate_altitude = 0; %[km]
    num_track_pts = 3;
end
if(ptOnlyFlag)
    lat0 = spec_lat3;
    lon0 = spec_lon3;
    %delta_pt = .1;
    delta_ray = 2;
    size_of_box = 1;  %[km]   width of box
    launch_altitude = alt_conj;    %[km]
    terminate_altitude = alt_conj; %[km]
    num_track_pts = 3;
end
%----
num_conj = 5+4*num_track_pts;
dist = km2deg(size_of_box/2);
[latN,lonN] = reckon(lat0,lon0,dist,0);
[latE,lonE] = reckon(lat0,lon0,dist,90);
[latS,lonS] = reckon(lat0,lon0,dist,180);
[latW,lonW] = reckon(lat0,lon0,dist,270);


if(circle_box == 2)
lat = [lat0,latN,latN,latS,latS];
lon = [lon0,lonW,lonE,lonE,lonW];

else
    lat = [lat0,latN,lat0,latS,lat0];
    lon = [lon0,lon0,lonE,lon0,lonW];
end

if(circle_box ==2)
[latSeg1,lonSeg1] = track2(lat(2),lon(2),lat(3),lon(3),[],'degrees',num_track_pts);
[latSeg2,lonSeg2] = track2(lat(3),lon(3),lat(4),lon(4),[],'degrees',num_track_pts);
[latSeg3,lonSeg3] = track2(lat(4),lon(4),lat(5),lon(5),[],'degrees',num_track_pts);
[latSeg4,lonSeg4] = track2(lat(5),lon(5),lat(2),lon(2),[],'degrees',num_track_pts);

else
    [latSeg1,lonSeg1] = scircle1(lat0,lon0,dist,[0,90],[],'degrees',num_track_pts);
    [latSeg2,lonSeg2] = scircle1(lat0,lon0,dist,[90,180],[],'degrees',num_track_pts);
    [latSeg3,lonSeg3] = scircle1(lat0,lon0,dist,[180,270],[],'degrees',num_track_pts);
    [latSeg4,lonSeg4] = scircle1(lat0,lon0,dist,[270,360],[],'degrees',num_track_pts);
end
    

lat = [lat,latSeg1'];
lon = [lon,lonSeg1'];
lat = [lat,latSeg2'];
lon = [lon,lonSeg2'];
lat = [lat,latSeg3'];
lon = [lon,lonSeg3'];
lat = [lat,latSeg4'];
lon = [lon,lonSeg4'];

ds(1:5) = delta_pt*sign(lat(1:5));
ds(6:num_conj) = delta_ray*sign(lat(6:num_conj));
ds(ds==0) = delta_pt;
geo_sm_flag = ones(1,num_conj);
alt_start = launch_altitude*ones(1,num_conj);
alt_terminate = terminate_altitude*ones(1,num_conj);


%----Now L-shell lines:2
terminate_altitude = alt_L; %[km]



for i = 1:length(L_shells)
    start_index = num_conj+1+(i-1)*num_pts;
    lon(start_index:start_index+num_pts-1) = linspace(0,360,num_pts);
    lat(start_index:start_index+num_pts-1) = 0;
    ds(start_index:start_index+num_pts-1) = n_s(i)*delta_L;
    alt_start(start_index:start_index+num_pts-1) = R0*(L_shells(i)-1);
    alt_terminate(start_index:start_index+num_pts-1) = terminate_altitude;
    geo_sm_flag(start_index:start_index+num_pts-1) = 0;
end

Rstart = 1+alt_start/R0;
Rf = 1+alt_terminate/R0;
clear L
[L,latf,lonf,num_steps] = trace(Rstart,lat,lon,ds,geo_sm_flag,Rf, T);

shapes = {'x','s','d','v','o'};
shapes = {'x','.','.','.','.'};
colors = {'r','r','b','g','k'};
point_color = 'r';
conjugate_color = 'r';
L_color = 'r';

if(plot_conj)
    for i = 1:5
        if(sign(latf(i))==sign(lat(i)))
            set(HHprogress,'string','ERROR: conjugate regions did not map.  Try a less extreme latitude.  ');
            return;
        end
    end
end


% --- plotting conjugate regions and L-shells----
if(~ptOnlyFlag)
    if(lon_ave<0)%assum lon_ave is in range (-180,360)
        lon_ave = lon_ave+360;
    end
    if(plot_conj)
        for i = 1:5
            plotm(lat(i),lon(i),[ shapes{i} colors{i}],'linewidth',2);
            plotm(latf(i),lonf(i),[ shapes{i} colors{i}],'linewidth',2);
        end
        
        plotm(latSeg1,lonSeg1,'color',point_color);
        plotm(latSeg2,lonSeg2,'color',point_color);
        plotm(latSeg3,lonSeg3,'color',point_color);
        plotm(latSeg4,lonSeg4,'color',point_color);
        
        plotm(latf(6:6+num_track_pts-1),lonf(6:6+num_track_pts-1),'color',conjugate_color)
        plotm(latf(6+num_track_pts:6+2*num_track_pts-1),lonf(6+num_track_pts:6+2*num_track_pts-1),'color',conjugate_color)
        plotm(latf(6+2*num_track_pts:6+3*num_track_pts-1),lonf(6+2*num_track_pts:6+3*num_track_pts-1),'color',conjugate_color)
        plotm(latf(6+3*num_track_pts:6+4*num_track_pts-1),lonf(6+3*num_track_pts:6+4*num_track_pts-1),'color',conjugate_color)
        
    end
    
    %textm(lat(1),lon(1),'x','fontsize',12,'horizontalalignment','center')
    for i = 1:length(L_shells)
        start_index = num_conj+1+(i-1)*num_pts;
        lon_index = start_index+findClosest(lon_ave,lonf(start_index:start_index+num_pts-1));
        plotm(latf(start_index:start_index+num_pts-1), lonf(start_index:start_index+num_pts-1),L_color);
        if(label_L)
            textm(latf(lon_index),lonf(lon_index),['L = ' num2str(L_shells(i))],'color',L_color,'verticalalignment','bottom');
        end
    end
end   

set(HHlatf0,'string',num2str(latf(1)));
set(HHlonf0,'string',num2str(lonf(1)));
set(HHLshell,'string',num2str(L(1)));

set(HHnum_pt_steps,'string',num_steps(1));
set(HHnum_line_steps,'string',num_steps(5));
set(HHnum_L_steps,'string',num_steps(end));

compTime = cputime-t;
