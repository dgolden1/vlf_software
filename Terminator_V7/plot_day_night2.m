%plot_day_night

% Ensure proper versioning (added by Dan Golden dgolden1@stanford.edu 04/04/2007)
v = ver('map');
if str2num(v.Version) < 2.1
    error(['Oops! This version of plot_day_night2 is only compatible with mapping' ...
        ' toolboxes version 2.1 (R14SP2) or greater']);
end

clear M
tic
t = cputime;
guiTag = gcf;

%Progress and error report:
HHprogress = findobj(guiTag,'tag','progress');

%Altitude
HH = findobj(guiTag,'tag','civil_sun');
civil_sun = get(HH,'Value');

HH = findobj(guiTag,'tag','alt');
alt = str2num(get(HH,'string'))*1000;   %[m]
if(~civil_sun&(isempty(alt)|~isnumeric(alt)|alt<0|~isreal(alt)))
    set(HHprogress,'string','ERROR: altitude must be nonnegative number')
    break
end

%Date and time

HH = findobj(guiTag,'tag','year');
year = str2num(get(HH,'string'));
if(isempty(year)|~isnumeric(year)|round(year)~=year|~isreal(year)|year<1901|year>2099)
    set(HHprogress,'string','ERROR: year must be an integer between 1901 and 2099')
    break
end

HH = findobj(guiTag,'tag','month');
month = str2num(get(HH,'string'));
if(isempty(month)|~isnumeric(month)|round(month)~=month|month<1|month>12|~isreal(month))
    set(HHprogress,'string','ERROR: month must be integer between 1 and 12')
    break
end

HH = findobj(guiTag,'tag','day');
day = str2num(get(HH,'string'));
if(isempty(day)|~isnumeric(day)|round(day)~=day|~isreal(day))
    set(HHprogress,'string','ERROR: day must be an integer');
    break
end

HH = findobj(guiTag,'tag','hour');
hour = str2num(get(HH,'string'));
if(isempty(hour)|~isnumeric(hour)|round(hour)~=hour|~isreal(hour))
    set(HHprogress,'string','ERROR: hour must be an integer');
    break
end

HH = findobj(guiTag,'tag','minute');
minute = str2num(get(HH,'string'));
if(isempty(minute)|~isnumeric(minute)|round(minute)~=minute|~isreal(minute))
    set(HHprogress,'string','ERROR: minute must be an integer');
    break
end

HH = findobj(guiTag,'tag','second');
second = str2num(get(HH,'string'));
if(isempty(second)|~isnumeric(second)|~isreal(second))
    set(HHprogress,'string','ERROR: second must be a number');
    break
end

%Resolution
HH = findobj(guiTag,'tag','numPixels');
numPixels = str2num(get(HH,'string'));
if(isempty(numPixels)|~isnumeric(numPixels)|round(numPixels)~=numPixels|numPixels<1|~isreal(numPixels))
    set(HHprogress,'string','ERROR: number of pixels must be a positive integer')
    break
end


HH = findobj(guiTag,'tag','plot_topo');
plot_topo = get(HH,'Value');

%plotting options
HH = findobj(guiTag,'tag','figureNo');
figureNo = str2num(get(HH,'string'));
if(isempty(figureNo)|~isnumeric(figureNo)|round(figureNo)~=figureNo|figureNo<1|~isreal(figureNo))
    set(HHprogress,'string','ERROR: figure number must be a positive integer')
    break
end

HH = findobj(guiTag,'tag','atlas_on');
atlas_on = get(HH,'Value');

HH = findobj(guiTag,'tag','show_river');
show_river = get(HH,'Value');

HH = findobj(guiTag,'tag','show_coord_label');
show_coord_label = get(HH,'Value');

HH = findobj(guiTag,'tag','show_axis');
show_axis = get(HH,'Value');

HH = findobj(guiTag,'tag','show_state');
show_state = get(HH,'Value');

HH = findobj(guiTag,'tag','show_sun');
show_sun = get(HH,'Value');

HH = findobj(guiTag,'tag','no_day_night');
no_day_night = get(HH,'Value');

HH = findobj(guiTag,'tag','label_L');
label_L = get(HH,'Value');

%map region 
HH = findobj(guiTag,'tag','region');
region = get(HH,'string');
region = deblank(region);   %string trailing spaces

%option 2
HH = findobj(guiTag,'tag','specify_coord');
specify_coord = get(HH,'Value');

HHllat = findobj(guiTag,'tag','lower_lat');
lower_lat = str2num(get(HHllat,'string'));
if(specify_coord&(isempty(lower_lat)|~isnumeric(lower_lat)|lower_lat<-90|lower_lat>90|~isreal(lower_lat)))
    set(HHprogress,'string','ERROR: lower latitude must be in [-90,90]')
    break
end

HHulat = findobj(guiTag,'tag','upper_lat');
upper_lat = str2num(get(HHulat,'string'));
if(specify_coord&(isempty(upper_lat)|~isnumeric(upper_lat)|upper_lat<-90|upper_lat>90|~isreal(upper_lat)))
    set(HHprogress,'string','ERROR: upper latitude must be in [-90,90]')
    break
end

if(specify_coord&(lower_lat>upper_lat))
    set(HHprogress,'string','ERROR: lower latitude must be less than upper latitude')
    break
end

HHllon = findobj(guiTag,'tag','lower_lon');
lower_lon = str2num(get(HHllon,'string'));
if(specify_coord&(isempty(lower_lon)|~isnumeric(lower_lon)|lower_lon<-180|lower_lon>360|~isreal(lower_lon)))
    set(HHprogress,'string','ERROR: lower longitude must be in [-180,360]')
    break
end

HHulon = findobj(guiTag,'tag','upper_lon');
upper_lon = str2num(get(HHulon,'string'));
if(specify_coord&(isempty(upper_lon)|~isnumeric(upper_lon)|upper_lon<-180|upper_lon>360|~isreal(upper_lon)))
    set(HHprogress,'string','ERROR: upper longitude must be in [-180,360]')
    break
end

if(specify_coord&(lower_lon>upper_lon))
    set(HHprogress,'string','ERROR: lower longitude must be less than upper longitude')
    break
end



HH = findobj(guiTag,'tag','feedback_range');
feedback_range = get(HH,'Value');


HH = findobj(guiTag,'tag','feedback_proj');
feedback_proj = get(HH,'Value');


HH = findobj(guiTag,'tag','specify_proj');
specify_proj = get(HH,'Value');

HHprojection = findobj(guiTag,'tag','projection_choose');
projection_type = get(HHprojection,'string');
projection_type = deblank(projection_type);   %string trailing spaces
if(strcmpi('globe',projection_type))
    plot_globe = 1;
else
    plot_globe = 0;
end

%--- Great-arc and point calculations ---
%Specific Locations:
HHlat1 = findobj(guiTag,'tag','spec_lat1');
spec_lat1 = str2num(get(HHlat1,'string'));
if(isempty(spec_lat1)|~isnumeric(spec_lat1)|spec_lat1<-90|spec_lat1>90|~isreal(spec_lat1))
    set(HHprogress,'string','ERROR: coordinate 1 latitude must be in [-90,90]')
    break
end

HHlon1 = findobj(guiTag,'tag','spec_lon1');
spec_lon1 = str2num(get(HHlon1,'string'));
if(isempty(spec_lon1)|~isnumeric(spec_lon1)|spec_lon1<-180|spec_lon1>360|~isreal(spec_lon1))
    set(HHprogress,'string','ERROR: coordinate 1 longitude must be in [-180,360]')
    break
end

HHlat2 = findobj(guiTag,'tag','spec_lat2');
spec_lat2 = str2num(get(HHlat2,'string'));
if(isempty(spec_lat2)|~isnumeric(spec_lat2)|spec_lat2<-90|spec_lat2>90|~isreal(spec_lat2))
    set(HHprogress,'string','ERROR: coordinate 2 latitude must be in [-90,90]')
    break
end

HHlon2 = findobj(guiTag,'tag','spec_lon2');
spec_lon2 = str2num(get(HHlon2,'string'));
if(isempty(spec_lon2)|~isnumeric(spec_lon2)|spec_lon2<-180|spec_lon2>360|~isreal(spec_lon2))
    set(HHprogress,'string','ERROR: coordinate 2 longitude must be in [-180,360]')
    break
end

%Feedback
HHdelta = findobj(guiTag,'tag','delta');

figure(figureNo);
cla reset

%if user specifies lat/long, pick an appropriate projection (near pole/near equator, etc..)
%and load worldhi/world lo, use plotm, and skip next if statement

set(HHprogress,'string','generating country boundaries');

if(specify_proj&plot_globe)
    load worldlo
    h = axesm('globe');
    hh = worldlo('POline');
    plotm(hh(1).lat,hh(1).long,'k');
    plotm(hh(2).lat,hh(2).long,'k');
    latlow = -90;
    lathigh = 90;
    longlow = -180;
    longhigh =180;
elseif(specify_coord)
    latlow = lower_lat;
    lathigh = upper_lat;
    longlow = lower_lon;
    longhigh = upper_lon;
    h = worldmap([latlow,lathigh],[longlow,longhigh],myIf(atlas_on,'line','lineonly'));
    if(show_state)
        plotm(usalo('statebvec'),'color',[.5,.5,.5])
    end
else
    try
        try
            h = usamap(region,myIf(atlas_on,'line','lineonly'));
        catch
            % I CHANGED SOME STUFF HERE -Dan 4/4/2007
            h = worldmap(region);
            land = shaperead('landareas.shp', 'UseGeoCoords', true);
            geoshow([land.Lat], [land.Lon], 'color', 'k');
            if(show_state)
%                 plotm(usalo('statebvec'),'color',[.5,.5,.5])
                usalo = open('conus.mat');
                plotm(usalo.statelat, usalo.statelon,'color',[.5,.5,.5])
            end
        end
    catch
        set(HHprogress,'string','ERROR: invalid region')
        %close(figureNo)
        return;
    end
    mat = getm(h);
    latlow = mat.maplatlimit(1);
    lathigh = mat.maplatlimit(2);
    longlow = mat.maplonlimit(1);
    longhigh = mat.maplonlimit(2);
    if(strcmpi('antarctica',region)|strcmpi('south pole',region))  %special cases
        latlow = -90;
        lathigh = -59;
        longlow = -180;
        longhigh =180;
    end
end

%save axis handle for figureNo:
save(['fig_' num2str(figureNo) '_handle'],'h');

%Conjugate points and L-shells:
set(HHprogress,'string','Calculating conugate region and L-shells');
compTime = calculateConj(guiTag,(longhigh +longlow)/2,0);
if(compTime<0)
    return;
end


axis auto

if(~plot_globe&specify_proj)
    try
        setm(h,'MapProjection',projection_type);
    catch
        set(HHprogress,'string','ERROR: unrecognized projection format')
        %close(figureNo)
        break
    end
end

    
mapProjection = getm(h,'MapProjection');

set(HHprogress,'string','generating country boundaries');

if(~no_day_night)
try
if(plot_topo)
    set(HHprogress,'string','loading topographic map');
    vtemp = round(clipTo180([lathigh,latlow,longhigh,longlow]));
    lathigh = vtemp(1);latlow = vtemp(2); longhigh = vtemp(3); longlow = vtemp(4);
    latRange = lathigh - latlow;
    lonRange = longhigh - longlow;
    numStr = latRange*lonRange;
    if(numStr>10000)
        skip = 6;
    elseif(numStr>6000)
        skip = 4;
    elseif(numStr>3000)
        skip = 3;
    elseif(numStr>1000)
        skip = 2;
    else
        skip = 1;
    end
    [map,maplegend] = tbase(skip,[latlow,lathigh],[longlow,longhigh]);    %need integer values to work properly
    delta = 1/maplegend(1);
    latv = [latlow+delta:delta:lathigh];    %look at
    longv = [longlow+delta:delta:longhigh]; %look at
    
    set(HHprogress,'string','Calculating day-night terminator');
    [LAT,LONG] = meshgrid(latv,longv);
    LAT = LAT';
    LONG = LONG';
    [sun_dark,elev,az] = sunshineC(LAT,LONG,alt,civil_sun,year,month,day,hour,minute,second);
    size_sun_dark = size(sun_dark);
    grat = [size_sun_dark(1)-1,size_sun_dark(2)-1];
    
    minMap = min(min(map));
    maxMap = max(max(map));
    map(find(sun_dark==0)) = map(find(sun_dark==0)) + 3000*sign(map(find(sun_dark==0))+.1);
    map(find(sun_dark==.5)) = map(find(sun_dark==.5)) + 2000*sign(map(find(sun_dark==.5))+.1);  %twilight
    map(find(map>maxMap)) = maxMap; %option 3
    map(find(map<minMap)) = minMap; %option 3

    meshm(map,maplegend,grat)
    demcmap([-9652,6098],256,[],[.6,.8,.6;0,.1,0]);   %all-green earth
    if(0)
        colorbar;
    end
    
else
    set(HHprogress,'string','Calculating day-night terminator');
    %Determine appropriate delta
    longRange = longhigh - longlow;
    latRange = lathigh - latlow;
    
    delta = sqrt(longRange*latRange/numPixels);
    
    latv = [latlow+delta:delta:lathigh];
    longv = [longlow+delta:delta:longhigh];
    
    [LAT,LONG] = meshgrid(latv,longv);
    LAT = LAT';
    LONG = LONG';
    [sun_dark,elev,az] = sunshine(LAT,LONG,alt,civil_sun,year,month,day,hour,minute,second);    
    sun_darklegend = [1/delta,lathigh,longlow];
    size_sun_dark = size(sun_dark);
    grat = [size_sun_dark(1)-1,size_sun_dark(2)-1];
    
    meshm(sun_dark,sun_darklegend,grat)
    
    if(max(max(sun_dark))==0)   %all dark
        colormap([.6,.6,.9]);
    elseif(max(max(sun_dark))==.5)  %civil twilight and dark
        colormap([.6,.6,.9 ; .8, .8,.7]);
    elseif(min(min(sun_dark))==.5)  %no night
        colormap([.8,.8,.7; 1,1,.5]);
    elseif(min(min(sun_dark))==1)   %all light
        colormap([1,1,.5]);
    else
        colormap([.6,.6,.9 ; .8,.8,.7; 1,1,.5]);
    end
    brighten(.5) ;
end
catch
    set(HHprogress,'string','ERROR: could not plot day-night shading.  Try increasing number of pixels in day-night mask')
    close(figureNo)
    break
end



%Feedback
set(HHdelta,'string',[num2str(delta) ' [deg/pixel]']);
end %no_day_night
if(feedback_range)
    set(HHllat,'string',num2str(latlow));
    set(HHulat,'string',num2str(lathigh));
    set(HHllon,'string',num2str(longlow));
    set(HHulon,'string',num2str(longhigh));
end
if(feedback_proj)
    set(HHprojection,'string',mapProjection);
end


%---- plot labels ----
if(0)
title([datestr(datenum([year,month,day,hour,minute,second]),0) '[UT]']);
xlabel(region)
end
%---- plot properties ----
%getm(h)
if(specify_proj&plot_globe)
    setm(h,'frame','off')
end
hidem(gca)

if(no_day_night)
    setm(gca,'FFaceColor','w')
%    setm(h,'frame','on')
end



setm(h,'glinewidth',1)
setm(h,'gcolor',[.25,.25,.25])
if(~show_axis)  
    %setm(h,'plinevisible','off')
    %setm(h,'mlinevisible','off')
    setm(h,'meridianlabel','off')
    setm(h,'parallellabel','off')
    setm(h,'meridianlabel','off')
    setm(h,'parallellabel','off')
    
end
if(1)
    setm(h,'labelrotation','off')
end

if(0)
    stateLine = usahi('stateline');
    for i = 1:51
       plotm(stateLine(i).lat,stateLine(i).long,'k')
   end
end
if(0)
    stateText = usahi('statetext');
    for i = 1:51
        textm(stateText(i).lat,stateText(i).long,stateText(i).string);
    end
end

%water:
if(show_river)
    set(HHprogress,'string','Plotting rivers');
    load worldlo
    displaym(DNline)
end

%Plot sun:
if(show_sun)
    latRange = abs(latlow - lathigh);
    lonRange = (longlow - longhigh);
    [latSun,lonSun] =  sunPosition(year,month,day,hour,minute,second);
    [latSun,lonSun] = scircle1(latSun,lonSun,min(latRange,lonRange)/200);
    plotm(latSun,lonSun,'k')
    patchm(latSun,lonSun,'y')
end


%Plot great arc
compTime = calculateArc(guiTag,1);
if(compTime <0)
    break;
end
set(HHprogress,'string',['Done! (' num2str(cputime-t) ' seconds)  See Figure ' num2str(figureNo) '.']);
