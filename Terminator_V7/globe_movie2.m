%plot_day_night
clear M
clear h
guiTag = gcf;
t = cputime;

%Progress and error report:
HHprogress = findobj(guiTag,'tag','progress');

monthString = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

%Altitude
HH = findobj(guiTag,'tag','civil_sun');
civil_sun = get(HH,'Value');

HH = findobj(guiTag,'tag','alt');
alt = str2num(get(HH,'string'))*1000;   %[m]
if(~civil_sun&(isempty(alt)|~isnumeric(alt)|alt<0|~isreal(alt)))
    set(HHprogress,'string','ERROR: altitude must be nonnegative number')
    break
end

%movie stuff
HH = findobj(guiTag,'tag','num_frames');
num_frames = str2num(get(HH,'string'));   %[m]
if(isempty(num_frames)|~isnumeric(num_frames)|num_frames<1|num_frames>1000|~isreal(num_frames)|num_frames~=floor(num_frames))
    set(HHprogress,'string','ERROR: number of unique frames must be integer between 1 and 1000')
    break
end

HH = findobj(guiTag,'tag','num_fps');
num_fps = str2num(get(HH,'string'));   %[m]
if(isempty(num_fps)|~isnumeric(num_fps)|num_fps<1|num_fps>60|~isreal(num_fps)|num_fps~=floor(num_fps))
    set(HHprogress,'string','ERROR: number of unique frames must be integer between 1 and 60')
    break
end

HH = findobj(guiTag,'tag','view_angle');
view_angle = str2num(get(HH,'string'));
if(isempty(view_angle)|~isnumeric(view_angle)|view_angle<-90|view_angle>90|~isreal(view_angle))
    set(HHprogress,'string','ERROR: viewing latitude for movie must be in [-90,90]')
    break
end

HH = findobj(guiTag,'tag','view_az');
view_az = str2num(get(HH,'string'));
if(isempty(view_az)|~isnumeric(view_az)|view_az<-180|view_az>360|~isreal(view_az))
    set(HHprogress,'string','ERROR: viewing longitude for movie must be in [-180,360]')
    break
end

% HH = findobj(guiTag,'tag','vantage_pt');
% vantage_index = get(HH,'Value');

HH = findobj(guiTag,'tag','save_avi');
save_avi = get(HH,'Value');




%Date and time

HH = findobj(guiTag,'tag','year');
year = str2num(get(HH,'string'));
if(isempty(year)|~isnumeric(year)|round(year)~=year|~isreal(year))
    set(HHprogress,'string','ERROR: year must be an integer')
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
    set(HHprogress,'string','ERROR: day must be an integer')
    break
end

HH = findobj(guiTag,'tag','hour');
hour = str2num(get(HH,'string'));
if(isempty(hour)|~isnumeric(hour)|round(hour)~=hour|~isreal(hour))
    set(HHprogress,'string','ERROR: hour must be an integer')
    break
end

HH = findobj(guiTag,'tag','minute');
minute = str2num(get(HH,'string'));
if(isempty(minute)|~isnumeric(minute)|round(minute)~=minute|~isreal(minute))
    set(HHprogress,'string','ERROR: minute must be an integer')
    break
end

HH = findobj(guiTag,'tag','second');
second = str2num(get(HH,'string'));
if(isempty(second)|~isnumeric(second)|~isreal(second))
    set(HHprogress,'string','ERROR: second must be a number')
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
atlas_on = 0;

HH = findobj(guiTag,'tag','show_river');
show_river = get(HH,'Value');

HH = findobj(guiTag,'tag','show_coord_label');
show_coord_label = get(HH,'Value');

HH = findobj(guiTag,'tag','show_axis');
show_axis = get(HH,'Value');

HH = findobj(guiTag,'tag','show_state');
show_state = get(HH,'Value');
show_state = 0;

HH = findobj(guiTag,'tag','show_sun');
show_sun = get(HH,'Value');
show_sun = 0;

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

%
%Feedback
HHdelta = findobj(guiTag,'tag','delta');

feedback_range = 0;
feedback_proj = 0;


fig =figure(figureNo);
cla reset

%if user specifies lat/long, pick an appropriate projection (near pole/near equator, etc..)
%and load worldhi/world lo, use plotm, and skip next if statement

set(HHprogress,'string','generating country boundaries');

if(1) %always do globe
    load worldlo
    h = axesm('globe');
    hh = worldlo('POline');
   plothandle1= plotm(hh(1).lat,hh(1).long,'k');
    plothandle2 = plotm(hh(2).lat,hh(2).long,'k');
    latlow = -90;
    lathigh = 90;
    longlow = -180;
    longhigh =180;
end

set(HHprogress,'string','Calculating conugate region and L-shells');
calculateConj(guiTag,(longhigh +longlow)/2,0);

axis auto;

mapProjection = getm(h,'MapProjection');

%---- plot properties ----
%getm(h)
if(specify_proj&plot_globe)
    setm(h,'frame','off');
end
hidem(gca);

if(no_day_night)
    setm(gca,'FFaceColor','w');
    %    setm(h,'frame','on')
end



setm(h,'glinewidth',1)
setm(h,'gcolor',[.25,.25,.25]);
if(~show_axis)  
    %setm(h,'plinevisible','off')
    %setm(h,'mlinevisible','off')
    setm(h,'meridianlabel','off');
    setm(h,'parallellabel','off');
    setm(h,'meridianlabel','off');
    setm(h,'parallellabel','off');
    
end
setm(h,'labelrotation','off');

%water:
if(show_river)
    set(HHprogress,'string','Plotting rivers');
    load worldlo;
    displaym(DNline);
end

%Plot great arc
calculateArc(guiTag,1);

if(~no_day_night)
    try
        if(plot_topo)
            set(HHprogress,'string','loading topographic map');
            vtemp = round(clipTo180([lathigh,latlow,longhigh,longlow]));
            lathigh = vtemp(1);latlow = vtemp(2); longhigh = vtemp(3); longlow = vtemp(4);
            latRange = lathigh - latlow;
            lonRange = longhigh - longlow;
            numStr = latRange*lonRange;
            skip = 12;
            [map,maplegend] = tbase(skip,[latlow,lathigh],[longlow,longhigh]);    %need integer values to work properly
            delta = 1/maplegend(1);
            latv = [latlow+delta:delta:lathigh];    %look at
            longv = [longlow+delta:delta:longhigh]; %look at
                            minMap = min(min(map));
                maxMap = max(max(map));
        end
    end
end


elevation = view_angle;
num_frames;    %number of unique frames (revisites first frame at end)
%k = vantage_index;


axis('vis3d')
shuffle = [3,4,1,2];
offset = [0,90,180,270];    %sunset midnight sunrise noon
hour_v = linspace(0,24,num_frames+1) + hour;
view_az = view_az+90;
set(fig,'DoubleBuffer','on');
for i = 0:length(hour_v)-1;

    tic;
    hour = hour_v(i+1);
    
    if(~no_day_night)
        try
            if(plot_topo)
                map2 = map;
                %set(HHprogress,'string','Calculating day-night terminator');
                [LAT,LONG] = meshgrid(latv,longv);
                LAT = LAT';
                LONG = LONG';
                
                [sun_dark,elev,az] = sunshineC(LAT,LONG,alt,civil_sun,year,month,day,hour,minute,second);
                
                size_sun_dark = size(sun_dark);
                grat = [size_sun_dark(1)-1,size_sun_dark(2)-1];
                map2(find(sun_dark==0)) = map(find(sun_dark==0)) + 3000*sign(map(find(sun_dark==0))+.1);
                map2(find(sun_dark==.5)) = map(find(sun_dark==.5)) + 2000*sign(map(find(sun_dark==.5))+.1);  %twilight
                map2(find(map>maxMap)) = maxMap; %option 3
                map2(find(map<minMap)) = minMap; %option 3
                meshHandle = meshm(map2,maplegend,grat);
                demcmap([-9652,6098],256,[],[.6,.8,.6;0,.1,0]);   %all-green earth
                
            else
                %set(HHprogress,'string','Calculating day-night terminator');
                %Determine appropriate delta
                longRange = longhigh - longlow;
                latRange = lathigh - latlow;
                
                delta = sqrt(longRange*latRange/numPixels);
                
                latv = [latlow+delta:delta:lathigh];
                longv = [longlow+delta:delta:longhigh];
                
                [LAT,LONG] = meshgrid(latv,longv);
                LAT = LAT';
                LONG = LONG';
                [sun_dark,elev,az] = sunshineC(LAT,LONG,alt,civil_sun,year,month,day,hour,minute,second);    

                sun_darklegend = [1/delta,lathigh,longlow];
                size_sun_dark = size(sun_dark);
                grat = [size_sun_dark(1)-1,size_sun_dark(2)-1];
                
                meshHandle = meshm(sun_dark,sun_darklegend,grat);
                
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
            set(HHprogress,'string','ERROR: could not plot day-night shading.  Try increasing number of pixels in day-night mask');
            close(figureNo);
            break
        end
              
        %Feedback
        set(HHdelta,'string',[num2str(delta) ' [deg/pixel]']);
    end %no_day_night
%     if(feedback_range)
%         set(HHllat,'string',num2str(latlow));
%         set(HHulat,'string',num2str(lathigh));
%         set(HHllon,'string',num2str(longlow));
%         set(HHulon,'string',num2str(longhigh));
%     end
%     if(feedback_proj)
%         set(HHprojection,'string',mapProjection);
%     end

    axis('vis3d');
    %view(h,-10+offset(shuffle(k))-i*360/(length(hour_v)-1),elevation);
    view(h,view_az,elevation);
      if(~no_day_night)
    showm(meshHandle);
end
    M(i+1) = getframe(h);

    
    %drawnow 
    if(~no_day_night)
    hidem(meshHandle);
end
     set(HHprogress,'string',['Rendering frame ' num2str(i+1) '/' num2str(length(hour_v)) '. Will take ' num2str(toc) ' seconds' ]);

 end
   if(~no_day_night)
 showm(meshHandle);
end

 movie(h,M,.5)

 set(HHprogress,'string','Creating avi file');
 
 if(save_avi)
     num_rows = size(M(1).cdata);
     num_rows = num_rows(1);
     for i = 1:length(M)
         M(i).cdata = M(i).cdata(floor(num_rows/8):floor(num_rows-num_rows/8),:,:);
     end
     file_exists = 1;
     movie_number = 1;
     while(file_exists)
         file_exists = inFolder(['globe_movie' num2str(movie_number) '.avi']);
         movie_number = movie_number+1;
     end
     movie_number = movie_number - 1;
     warning off
       movie2avi(M,['globe_movie' num2str(movie_number)],'quality',100,'compression','Indeo5'); 
    warning on    
   end

 
if(save_avi)
    set(HHprogress,'string',['Done! (' num2str(cputime-t) ' seconds)  See Figure ' num2str(figureNo) '. Avi file saved to globe_movie' num2str(movie_number) '.avi.']);
else
    
 set(HHprogress,'string',['Done! (' num2str(cputime-t) ' seconds)  See Figure ' num2str(figureNo) '.']);
end
