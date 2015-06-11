function compTime = calculateArc(guiTag,plotFlag)
compTime = -1;
clear latChange;
clear lonChange;
t = cputime;
%Progress and error report:
HHprogress = findobj(guiTag,'tag','progress');
%guiTag

HH = findobj(guiTag,'tag','figureNo');
figureNo = str2num(get(HH,'string'));
if(isempty(figureNo)|~isnumeric(figureNo)|round(figureNo)~=figureNo|figureNo<1|~isreal(figureNo))
    set(HHprogress,'string','ERROR: figure number must be a positive integer')
    return
end

monthString = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

%Altitude
HH = findobj(guiTag,'tag','civil_sun');
civil_sun = get(HH,'Value');

HH = findobj(guiTag,'tag','alt');
alt = str2num(get(HH,'string'))*1000;   %[m]
if(~civil_sun&(isempty(alt)|~isnumeric(alt)|alt<0|~isreal(alt)))
    set(HHprogress,'string','ERROR: altitude must be nonnegative number')
    return
end


HH = findobj(guiTag,'tag','show_coord_label');
show_coord_label = get(HH,'Value');

%Date and time

HH = findobj(guiTag,'tag','year');
year = str2num(get(HH,'string'));
if(isempty(year)|~isnumeric(year)|round(year)~=year|~isreal(year))
    set(HHprogress,'string','ERROR: year must be an integer')
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
    set(HHprogress,'string','ERROR: day must be an integer')
    return
end

HH = findobj(guiTag,'tag','hour');
hour = str2num(get(HH,'string'));
if(isempty(hour)|~isnumeric(hour)|round(hour)~=hour|~isreal(hour))
    set(HHprogress,'string','ERROR: hour must be an integer')
    return
end

HH = findobj(guiTag,'tag','minute');
minute = str2num(get(HH,'string'));
if(isempty(minute)|~isnumeric(minute)|round(minute)~=minute|~isreal(minute))
    set(HHprogress,'string','ERROR: minute must be an integer')
    return
end

HH = findobj(guiTag,'tag','second');
second = str2num(get(HH,'string'));
if(isempty(second)|~isnumeric(second)|~isreal(second))
    set(HHprogress,'string','ERROR: second must be a number')
    return
end


%--- Great-arc and point calculations ---
%Specific Locations:
HHlat1 = findobj(guiTag,'tag','spec_lat1');
spec_lat1 = str2num(get(HHlat1,'string'));
if(isempty(spec_lat1)|~isnumeric(spec_lat1)|spec_lat1<-90|spec_lat1>90|~isreal(spec_lat1))
    set(HHprogress,'string','ERROR: coordinate 1 latitude must be in [-90,90]')
    return
end

HHlon1 = findobj(guiTag,'tag','spec_lon1');
spec_lon1 = str2num(get(HHlon1,'string'));
if(isempty(spec_lon1)|~isnumeric(spec_lon1)|spec_lon1<-180|spec_lon1>360|~isreal(spec_lon1))
    set(HHprogress,'string','ERROR: coordinate 1 longitude must be in [-180,360]')
    return
end

HHlat2 = findobj(guiTag,'tag','spec_lat2');
spec_lat2 = str2num(get(HHlat2,'string'));
if(isempty(spec_lat2)|~isnumeric(spec_lat2)|spec_lat2<-90|spec_lat2>90|~isreal(spec_lat2))
    set(HHprogress,'string','ERROR: coordinate 2 latitude must be in [-90,90]')
    return
end

HHlon2 = findobj(guiTag,'tag','spec_lon2');
spec_lon2 = str2num(get(HHlon2,'string'));
if(isempty(spec_lon2)|~isnumeric(spec_lon2)|spec_lon2<-180|spec_lon2>360|~isreal(spec_lon2))
    set(HHprogress,'string','ERROR: coordinate 2 longitude must be in [-180,360]')
    return
end

HHdist = findobj(guiTag,'tag','dist_in_km');

HHdist1 = findobj(guiTag,'tag','dist1');
HHdist2 = findobj(guiTag,'tag','dist2');

HHelev1 = findobj(guiTag,'tag','elev1');
HHaz1 = findobj(guiTag,'tag','az1');

HHelev2 = findobj(guiTag,'tag','elev2');
HHaz2 = findobj(guiTag,'tag','az2');

HHsunrise1 = findobj(guiTag,'tag','sunrise1');
HHsunset1 = findobj(guiTag,'tag','sunset1');

HHsunrise2 = findobj(guiTag,'tag','sunrise2');
HHsunset2 = findobj(guiTag,'tag','sunset2');

HHsun1 = findobj(guiTag,'tag','sun1');
HHsun2 = findobj(guiTag,'tag','sun2');

HHlengthDay1 = findobj(guiTag,'tag','lengthDay1');
HHlengthDay2 = findobj(guiTag,'tag','lengthDay2');

HHarcPos1 = findobj(guiTag,'tag','arcPos1');
HHarcPos2 = findobj(guiTag,'tag','arcPos2');


%Plot great arc
if(plotFlag)
figure(figureNo);
end
%set(HHprogress,'string',['Great-arc calculations']);
geoid = almanac('earth','sphere','kilometers');
arccolor = 'm';
[lat,lon] = track2(spec_lat1,spec_lon1,spec_lat2,spec_lon2,geoid,'degrees',1000);
if(plotFlag)
    plotm(lat,lon,arccolor,'linewidth',1.25)
if(show_coord_label)
    plotm(spec_lat1,spec_lon1,[arccolor '+'])
    plotm(spec_lat2,spec_lon2,[arccolor '+'])
    coord = coordinates;
    name1 = findName(spec_lat1,spec_lon1,coord);   %see if this place is in the database
    name2 = findName(spec_lat2,spec_lon2,coord);
    if length(name1)>0
        name1 = [' (' name1 ')'];
    end
    if length(name2)>0
        name2 = [' (' name2 ')'];
    end
    textm(spec_lat1,spec_lon1,[' 1' name1],'color',arccolor)
    textm(spec_lat2,spec_lon2,[' 2' name2],'color',arccolor)
end
end

%--- great arc and coord1/2 calculations: ---
dist_in_km = distance(spec_lat1,spec_lon1,spec_lat2,spec_lon2,geoid);
set(HHdist,'string',[num2str(dist_in_km) ' [km]']);

%Find day-night terminator along great arc -- I'm proud of this code --
lat1 = spec_lat1; lon1 = spec_lon1;
lat2 = spec_lat2; lon2 = spec_lon2;
for i = 1:2 %at most two terminator crossings
    try
        res_km = inf;
        iterations = 0;
        while(res_km>.001)
            numPts = 100;
            [LAT,LON] = track2(lat1,lon1,lat2,lon2,geoid,'degrees',numPts);
            [sun_dark,elev,az] = sunshine(LAT,LON,alt,civil_sun,year,month,day,hour,minute,second);
            sun_dark(find(sun_dark<1)) = 0; %forget twilight
            changeIndices = find(diff(sun_dark)~=0);
            firstChangeIndex = changeIndices(1);
            latChange(i) = LAT(firstChangeIndex);
            lonChange(i) = LON(firstChangeIndex);
            lat1 = LAT(max(firstChangeIndex-1,1));
            lon1 = LON(max(firstChangeIndex-1,1));
            lat2 = LAT(min(firstChangeIndex+1,length(LAT)));
            lon2 = LON(min(firstChangeIndex+1,length(LON)));
            res_km = distance(lat1,lon1,lat2,lon2,geoid);
            iterations = iterations+1;
            if(iterations>100)  %avoid infinite while loop in unforseen case
                disp('not converging')
                error('not converging')
            end
        end
    catch
        latChange(i) = NaN;
        lonChange(i) = NaN;
    end
    iterations(i) = iterations;
    lat1 = lat2; lon1 = lon2;
    lat2 = spec_lat2;   lon2 = spec_lon2;
end

iterations;

dist_in_km11 = distance(spec_lat1,spec_lon1,latChange(1),lonChange(1),geoid);
dist_in_km12 = distance(spec_lat1,spec_lon1,latChange(2),lonChange(2),geoid);
dist_in_km21 = distance(spec_lat2,spec_lon2,latChange(1),lonChange(1),geoid);
dist_in_km22 = distance(spec_lat2,spec_lon2,latChange(2),lonChange(2),geoid);

%%%%%%%%%%%%%%%%%%%% ADDITION: display position(s) of day/night terminator %%%%%%%%%%%%%%%%%%%%5
if(isnan(dist_in_km11))
    dist1 = 'No day/night terminator along arc';
    set(HHarcPos1,'string',' ');
    set(HHarcPos2,'string',' ');
elseif(isnan(dist_in_km12))
    dist1 = [num2str(dist_in_km11) ' [km]'];
    if(plotFlag)
            set(HHarcPos1,'string',[num2str(latChange(1)) ' [deg N], ' num2str(lonChange(1)) ' [deg E]' ...
            '']);   %, (see dot on map)
    else
        set(HHarcPos1,'string',[num2str(latChange(1)) ' [deg N], ' num2str(lonChange(1)) ' [deg E]' ...
                '']);
    end
    set(HHarcPos2,'string',' ');
else
    if(plotFlag)
            set(HHarcPos1,'string',[num2str(latChange(1)) ' [deg N], ' num2str(lonChange(1)) ' [deg E]' ...
            '']);   %used to be "see dot on map"
    dist1 = [num2str(dist_in_km11) ' [km] and ' num2str(dist_in_km12) ' [km]'];
    set(HHarcPos2,'string',[num2str(latChange(2)) ' [deg N], ' num2str(lonChange(2)) ' [deg E]' ...
            '']);   %used to be "see + on map"
else
    set(HHarcPos1,'string',[num2str(latChange(1)) ' [deg N], ' num2str(lonChange(1)) ' [deg E]' ...
            '']);
    dist1 = [num2str(dist_in_km11) ' [km] and ' num2str(dist_in_km12) ' [km]'];
    set(HHarcPos2,'string',[num2str(latChange(2)) ' [deg N], ' num2str(lonChange(2)) ' [deg E]' ...
            '']);
end
end

if(isnan(dist_in_km21))
    dist2 = 'No day/night terminator along arc';
elseif(isnan(dist_in_km22))
    dist2 = [num2str(dist_in_km21) ' [km]'];
else
    dist2 = [num2str(dist_in_km21) ' [km] and ' num2str(dist_in_km22) ' [km]'];
end

set(HHdist1,'string',dist1);
set(HHdist2,'string',dist2);

if(plotFlag)
    plotm(latChange(1),lonChange(1),[arccolor '*'],'linewidth',2)
plotm(latChange(2),lonChange(2),[arccolor '+'],'linewidth',2)
end

%Calculate sun position at positions 1 and 2
lat = [spec_lat1,spec_lat2];
lon = [spec_lon1,spec_lon2];
clear sun_dark
clear elev
clear az
for i = 1:2
    [sun_dark(i),elev(i),az(i)] = sunshine(lat(i),lon(i),alt,civil_sun,year,month,day,hour,minute,second);    
    if(sun_dark(i)==0)
        conditions{i} = 'night';
    elseif(sun_dark(i)==.5)
        conditions{i} = 'twilight';
    else
        conditions{i} = 'day';
    end
end
set(HHelev1,'string',num2str(elev(1)));
set(HHaz1,'string',num2str(az(1)));
set(HHelev2,'string',num2str(elev(2)));
set(HHaz2,'string',num2str(az(2)));
set(HHsun1,'string',['(' conditions{1} ')']);
set(HHsun2,'string',['(' conditions{2} ')']);

%Find sunrise/sunset times:
[hour1r,minute1r,second1r] = sunrise(spec_lat1,spec_lon1,alt,civil_sun,year,month,day);
[hour1s,minute1s,second1s] = sunset(spec_lat1,spec_lon1,alt,civil_sun,year,month,day);
[hour2r,minute2r,second2r] = sunrise(spec_lat2,spec_lon2,alt,civil_sun,year,month,day);
[hour2s,minute2s,second2s] = sunset(spec_lat2,spec_lon2,alt,civil_sun,year,month,day);

%Find length of day
T1r = [year,month,day,hour1r,minute1r,second1r];
T1s = [year,month,day,hour1s,minute1s,second1s];
T2r = [year,month,day,hour2r,minute2r,second2r];
T2s = [year,month,day,hour2s,minute2s,second2s];
lengthDay1 = etime(T1s,T1r);   
if(etime(T1s,T1r)<0)
    lengthDay1 = lengthDay1 + 24*60*60;   %[sec] 
end

lengthDay1h = floor(lengthDay1/3600);
lengthDay1m = floor((lengthDay1-3600*lengthDay1h)/60);
lengthDay1s = lengthDay1-3600*lengthDay1h -60*lengthDay1m;

lengthDay2 = etime(T2s,T2r);
if(etime(T2s,T2r)<0)
    lengthDay2 = lengthDay2 + 24*60*60; %[sec]
end

lengthDay2h = floor(lengthDay2/3600);
lengthDay2m = floor((lengthDay2-3600*lengthDay2h)/60);
lengthDay2s = lengthDay2-3600*lengthDay2h -60*lengthDay2m;

%strings:
timeDay1 = datestr(datenum([0,0,0,lengthDay1h,lengthDay1m,lengthDay1s]),13);
timeDay2 = datestr(datenum([0,0,0,lengthDay2h,lengthDay2m,lengthDay2s]),13);
hoursDay1 = timeDay1(1:2);
minutesDay1 = timeDay1(4:5);
secondsDay1 = timeDay1(7:8);
hoursDay2 = timeDay2(1:2);
minutesDay2 = timeDay2(4:5);
secondsDay2 = timeDay2(7:8);

lat = [spec_lat1,spec_lat2];
lon = [spec_lon1,spec_lon2];
clear sun_dark
clear elev
clear az
for i = 1:2
    [sun_dark(i),elev(i),az(i)] = sunshine(lat(i),lon(i),alt,civil_sun,year,month,day,hour,minute,second);    
    if(sun_dark(i)<1)
        conditions{i} = 'night';
    else
        conditions{i} = 'day';
    end
end

if(isnan(hour1r))
    set(HHsunrise1,'string','No sunrise');
    set(HHlengthDay1,'string',['(Always ' conditions{1} ')']);
else
    set(HHsunrise1,'string',datestr(datenum([0,0,0,hour1r,minute1r,second1r]),13));
    set(HHlengthDay1,'string',['(' hoursDay1 'h, ' minutesDay1 'm, ' secondsDay1 's daylight)']); 
end
if(isnan(hour1s))
    set(HHsunset1,'string','No sunset');
    set(HHlengthDay1,'string',['(Always ' conditions{1} ')']);
else
    set(HHsunset1,'string',datestr(datenum([0,0,0,hour1s,minute1s,second1s]),13));
    set(HHlengthDay1,'string',['(' hoursDay1 'h, ' minutesDay1 'm, ' secondsDay1 's daylight)']); 
end
if(isnan(hour2r))
    set(HHsunrise2,'string','No sunrise');
    set(HHlengthDay2,'string',['(Always ' conditions{2} ')']);
else
    set(HHsunrise2,'string',datestr(datenum([0,0,0,hour2r,minute2r,second2r]),13));
    set(HHlengthDay2,'string',['(' hoursDay2 'h, ' minutesDay2 'm, ' secondsDay2 's daylight)']);     
end
if(isnan(hour2s))
    set(HHsunset2,'string','No sunset');
    set(HHlengthDay2,'string',['(Always ' conditions{2} ')']);
else
    set(HHsunset2,'string',datestr(datenum([0,0,0,hour1s,minute1s,second1s]),13));
    set(HHlengthDay2,'string',['(' hoursDay2 'h, ' minutesDay2 'm, ' secondsDay2 's daylight)']);   
end

compTime = cputime-t;



