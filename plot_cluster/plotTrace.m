clear all

% PLOT ORBITS
a = load('c1_trace.txt');
b = load('c2_trace.txt');
c = load('c3_trace.txt');
d = load('c4_trace.txt');

a_UT = datenum(a(:,1), 0, a(:,2), a(:,3), 0, 0);
b_UT = datenum(b(:,1), 0, b(:,2), b(:,3), 0, 0);
c_UT = datenum(c(:,1), 0, c(:,2), c(:,3), 0, 0);
d_UT = datenum(d(:,1), 0, d(:,2), d(:,3), 0, 0);

a_lat=[]; a_lon=[]; a_r=[];
b_lat=[]; b_lon=[]; b_r=[];
c_lat=[]; c_lon=[]; c_r=[];
d_lat=[]; d_lon=[]; d_r=[];

for j=1:length(a)
    a_lat = vertcat(a_lat,a(j,4));
    a_lon = vertcat(a_lon,a(j,5));
    a_r=vertcat(a_r,a(j,6));
    j=j+1;
end

for j=1:length(b)
    b_lat = vertcat(b_lat,b(j,4));
    b_lon = vertcat(b_lon,b(j,5));
    b_r=vertcat(b_r,b(j,6));
    j=j+1;
end

for j=1:length(c)
    c_lat = vertcat(c_lat,c(j,4));
    c_lon = vertcat(c_lon,c(j,5));
    c_r=vertcat(c_r,c(j,6));
    j=j+1;
end

for j=1:length(d)
    d_lat = vertcat(d_lat,d(j,4));
    d_lon = vertcat(d_lon,d(j,5));
    d_r=vertcat(d_r,d(j,6));
    j=j+1;
end

for i=1:length(a_lat)
    [Messa(i), Lata(i), Longa(i), NumberStepsa(i)] = trace(a_r(i),a_lat(i),a_lon(i),-0.2*sign(a_lat(i)),1,1+90/6370,[2008, 3, 1, 1, 1, 1]);
    dista(i)=deg2km(distance(Lata(i),Longa(i),62.4,214.8));
end
hold on;

for i=1:length(b_lat)
    [Messb(i), Latb(i), Longb(i), NumberStepsb(i)] = trace(b_r(i),b_lat(i),b_lon(i),-0.2*sign(a_lat(i)),1,1+90/6370,[2008, 3, 1, 1, 1, 1]);
    distb(i)=deg2km(distance(Latb(i),Longb(i),62.4,214.8));
end
hold on;

for i=1:length(c_lat)
    [Messc(i), Latc(i), Longc(i), NumberStepsc(i)] = trace(c_r(i),c_lat(i),c_lon(i),-0.2*sign(a_lat(i)),1,1+90/6370,[2008, 3, 1, 1, 1, 1]);
    distc(i)=deg2km(distance(Latc(i),Longc(i),62.4,214.8));
end
hold on;

for i=1:length(d_lat)
    [Messd(i), Latd(i), Longd(i), NumberStepsd(i)] = trace(d_r(i),d_lat(i),d_lon(i),-0.2*sign(a_lat(i)),1,1+90/6370,[2008, 3, 1, 1, 1, 1]);
    distd(i)=deg2km(distance(Latd(i),Longd(i),62.4,214.8));
end
hold on;

h = worldmap([50 70],[-155 -130]); %([Lat limits],[Long limits])
setm(h,'mapprojection','mercator');
setm(h,'mlinelocation',[-145]);
setm(h,'mlabellocation',[-145 -130]);
setm(h,'plinelocation',[60]);
setm(h,'plabellocation',[60 70]);
setm(h,'plabelmeridian','west')
landareas = shaperead('landareas.shp','UseGeoCoords',true);
geoshow(landareas,'FaceColor','none','EdgeColor',[0 0 0]);
gridm on

%This plots HAARP
plotm(62.4, -145.2,'g','Marker','o','MarkerSize',4,'MarkerFaceColor','g');
hold on;

plotm(Lata,Longa,'m');
hold on;

plotm(Latb,Longb,'b', 'LineWidth', 3);
hold on;

plotm(Latc,Longc,'r');
hold on;

plotm(Latd,Longd,'c');
hold on;

%small circles
sca100 = scircle1(62.4, 214.8, 0.898); %circle of r = 0.898 degree (100 km)
linem(sca100(:,1), sca100(:,2),'g','LineWidth',1); %plot of this circle

sca200 = scircle1(62.4, 214.8, 2*0.898); %circle of r = 2*0.898 degree (200 km)
linem(sca200(:,1), sca200(:,2),'g','LineWidth',1);

sca300 = scircle1(62.4, 214.8, 3*0.898);
linem(sca300(:,1), sca300(:,2),'g','LineWidth',1);

sca400 = scircle1(62.4, 214.8, 4*0.898);
linem(sca400(:,1), sca400(:,2),'g','LineWidth',1);

sca500 = scircle1(62.4, 214.8, 5*0.898);
linem(sca500(:,1), sca500(:,2),'g','LineWidth',1);

sca600 = scircle1(62.4, 214.8, 6*0.898);
linem(sca600(:,1), sca600(:,2),'g','LineWidth',1);

sca700 = scircle1(62.4, 214.8, 7*0.898);
linem(sca700(:,1), sca700(:,2),'g','LineWidth',1);

sca800 = scircle1(62.4, 214.8, 8*0.898);
linem(sca800(:,1), sca800(:,2),'g','LineWidth',1);

sca900 = scircle1(62.4, 214.8, 9*0.898);
linem(sca900(:,1), sca900(:,2),'g','LineWidth',1);

sca1000 = scircle1(62.4, 214.8, 10*0.898);
linem(sca1000(:,1), sca1000(:,2),'g','LineWidth',1);

sca1100 = scircle1(62.4, 214.8, 11*0.898);
linem(sca1100(:,1), sca1100(:,2),'g','LineWidth',1);

sca1200 = scircle1(62.4, 214.8, 12*0.898);
linem(sca1200(:,1), sca1200(:,2),'g','LineWidth',1);

sca1300 = scircle1(62.4, 214.8, 13*0.898);
linem(sca1300(:,1), sca1300(:,2),'g','LineWidth',1);
