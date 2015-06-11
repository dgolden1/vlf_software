% Starting position
lat = 20.00;
long = 0.00;
alt = 6371; % starting in km 
minalt = 100; % in km
maxalt = 7000; % in km
direction = -1; % Tracing direction (-1 in northern hemisphere)
tmax = 10000; % tracing tmax, set bigger (but not too much bigger) than
             % you expect the path length will be in km

% time
year=2001;
month=3;
day=1;

% Start position
pos0 = altlonglat_to_cart(alt,long,lat);
% vector function
f = @(t,pos) geofield(year,month,day, pos, direction);
fstop = @(t,pos) stopevents(t,pos,minalt,maxalt);

opts = odeset('Events',fstop,'RelTol',1e-6);
[t,pos] = ode45(f,[0,tmax], pos0, opts);

posstop = pos(end,:);

[stopalt,stoplong,stoplat] = cart_to_altlonglat(posstop);

fprintf('Final altitude: %f\nLon: %f\nLat: %f\n', stopalt, stoplong, stoplat);
