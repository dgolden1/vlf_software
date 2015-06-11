% function draw_earth
% By Daniel Golden September 2007

close all;
clear;

grs80 = almanac('earth','grs80','km');

figure
ax = axesm('globe','Geoid',grs80,'Grid','on', ...
    'GLineWidth',1,'GLineStyle','-',...
    'Gcolor',[0.4 0.4 0.4],'Galtitude',100);
set(ax,'Position',[0 0 1 1]);
axis equal off
view(3)
set(gcf,'Renderer','opengl')

load topo
geoshow(topo,topolegend,'DisplayType','texturemap');
demcmap(topo);
land = shaperead('landareas','UseGeoCoords',true);
plotm([land.Lat],[land.Lon],'Color','black');
