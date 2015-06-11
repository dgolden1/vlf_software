function [c,cd,cn,h] = plotDayNight(T,lat,lon,numPixels,alt,mapAxes)
%
%inputs
%------
%lat: [latLow latHigh]
%lon: [lonLo lonHigh]
%T: [year month day hour minute second] (in UT)
%numPixels: number of pixels for display
%alt: altitude (in meters)
%figureNo: figure of already-made map
%subplotNo: subplot number.  set to 111 if no subplots. 

if(mapAxes~=0)
    axes(mapAxes);
end

plot_DayNight = 1;   %otherwise plot ionosphere regions

longRange = lon(2) - lon(1);
latRange = lat(2) - lat(1);

delta = sqrt(longRange*latRange/numPixels);
%delta = .5;

latv = [lat(1)+delta:delta:lat(2)];
longv = [lon(1)+delta:delta:lon(2)];

[LAT,LONG] = meshgrid(latv,longv);
LAT = LAT';
LONG = LONG';

[sun_dark,h,az,h_corr] = night_day(T,LAT,LONG,alt/1000);

sun_darklegend = [1/delta,lat(2),lon(1)];
size_sun_dark = size(sun_dark);
grat = [size_sun_dark(1)-1,size_sun_dark(2)-1];

if(plot_DayNight)
    h = meshm(sun_dark,sun_darklegend,grat,-1);
else
    %h = meshm(h_corr*180/pi,sun_darklegend,grat,-1);
    %h = meshm(az,sun_darklegend,grat,-1);
    %make regions:
    h1 = -15; h2 = -30; h3 = -10;
    regions = 5*ones(size(h));
    regions(find(h_corr>0)) = 1;
    regions(find(h_corr > h1*pi/180 & h_corr < 0 & az < 0))=2;
    regions(find(h_corr > h2*pi/180 & h_corr < h1*pi/180 & az < 0)) = 3;
    regions(find(h_corr > h3*pi/180 & h_corr < 0 & az > 0)) = 4;
    meshm(regions,sun_darklegend,grat,-1);
end

if(max(max(h_corr)) > .01 & min(min(h_corr)) < -.01)
    c = contourc(longv,latv,h_corr,0*[1,1]); c = flipud(c(:,2:end)); h(1) = plotm(c(1,:),c(2,:),'k');
    cd = contourc(longv,latv,h_corr,.01*[1,1]); cd = flipud(cd(:,2:end)); h(2) = plotm(cd(1,:),cd(2,:),'y');
    cn = contourc(longv,latv,h_corr,-.01*[1,1]); cn = flipud(cn(:,2:end)); h(3) = plotm(cn(1,:),cn(2,:),'b');
else
    c = [];
    cd = [];
    cn = [];
    h = [];
end

if(plot_DayNight)
    colormap([.6,.6,.9 ; .8,.8,.7; 1,1,.5]);
    brighten(.5) ;
    caxis([0,1]);
end

