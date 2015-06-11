function c = plotATDGrid(lat,lon,lat1,lon1,lat2,lon2,v_c,mapAxes,varargin);

delta = 4;  %[deg] - resolution of grid
plotATDCurves = 0;
if(nargin > 8)
    atd_list = varargin{1}*1e3; %[ms]
    if(length(atd_list)==1)
        atd_list = atd_list*[1,1];
    end
    plotATDCurves = 1;
end

C = myConstants('c');  %[m/s]
v = v_c*C;

longRange = lon(2) - lon(1);
latRange = lat(2) - lat(1);

%delta = sqrt(longRange*latRange/numPixels);


latv = [lat(1)+delta:delta:lat(2)];
longv = [lon(1)+delta:delta:lon(2)];

[LAT,LONG] = meshgrid(latv,longv);
LAT = LAT';
LONG = LONG';

lat1 = lat1*ones(size(LAT));
lon1 = lon1*ones(size(LONG));
lat2 = lat2*ones(size(LAT));
lon2 = lon2*ones(size(LONG));

atd_grid = distanceInKm(lat1,lon1,LAT,LONG)*1e3/v - ...
    distanceInKm(lat2,lon2,LAT,LONG)*1e3/v; %[s]

atd_gridlegend = [1/delta,lat(2),lon(1)];
size_atd_grid = size(atd_grid);
grat = [size_atd_grid(1)-1,size_atd_grid(2)-1];


maxDT = max(max(atd_grid))*1e3;  %[ms]
minDT = min(min(atd_grid))*1e3;  %[ms]

if(mapAxes~=0)
     axes(mapAxes);
end

if(~plotATDCurves)
    colormap('jet');
    meshm(atd_grid*1e3,atd_gridlegend,grat);
    caxis([minDT,maxDT]);
    h = colorbar;
    setColorbarTitle(h,['ATD [ms], \Delta = ' sprintf('%2.3f',(maxDT-minDT)/64)]);
    c = [];
    x = pwd; save([x(1:3) 'lastATDGrid'],'LAT','LONG','atd_grid');
else
    %contourm(atd_grid*1e3,atd_gridlegend);
    if(nargin > 9)
        color = varargin{2};
    else
        color = 'b';
    end

%      [c,h] = contour(LAT,LONG,atd_grid*1e3,atd_list); c = c(:,2:end);    %first and last coordinates are the same 

     c = contourc(longv,latv,atd_grid*1e3,atd_list); c = flipud(c(:,2:end)); 
     
     if(mapAxes~=0)
         plotm(c(1,:),c(2,:),'r--');
         figure(300); hold on; subplot(311); plot(c(1,:),c(2,:));  subplot(312); plot(c(1,:)); hold on; subplot(313); plot(c(2,:));
     end
    x = pwd; save([x(1:3) 'lastContour'],'c');
end

