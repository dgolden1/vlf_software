function [lats_n,lons_n,lats_s,lons_s] = LShell_lines(T,L,num_pts,alt)
%syntax: [lats_n,lons_n,lats_s,lons_s] = LShell_lines(T,L,num_pts,alt)
%
%L is length m vector of desired L-shell lines
%returns lats_n,lons_n,lats_s,lons_s for north and south lat/lon points of
%L-shell lines, each sized m x num_pts
%Time vector T
%alt in km of L-shell altitude (lats/lons are earth projections of L-shell at
%altitude alt). 
%
%compare with http://modelweb.gsfc.nasa.gov/models/cgm/cgm.html
%
%example:
%[lats_n,lons_n,lats_s,lons_s] = LShell_lines([2001 1 1 0 0 0],[2,3],40,100);
%plotm(lats_n(1,:),lons_n(1,:));    %assumes gcf points to valid map figure
%plotm(lats_n(2,:),lons_n(2,:));
%
%
% Ryan Said, Sep 18, 2007

R0 = almanac('earth','radius','km');

delta_pt = .1;

lon_sm_in = linspace(0,360,num_pts);    
lon_sm_in = repmat(lon_sm_in,1,2*length(L));    %times 2 for north and south
lat_sm_in = zeros(size(lon_sm_in));
geo_sm_flag = zeros(size(lat_sm_in)); %sm coordinates, not geo coordinates

%first half of input vector to trace: north; second half: south
ds = delta_pt*[-ones(1,length(lon_sm_in)/2),ones(1,length(lon_sm_in)/2)];

alt_start_vec = R0*(L-1); %[km]
alt_start = []; %I know - inefficint coding - I'm tired and don't want to figure out indices
for ii = 1:length(alt_start_vec);
    alt_start = [alt_start,alt_start_vec(ii)*ones(1,num_pts)];
end
alt_start = repmat(alt_start,1,2);

alt_terminate = alt*ones(size(lon_sm_in));
    
Rstart = 1+alt_start/R0;
Rf = 1+alt_terminate/R0;
[Lf,latf,lonf,num_steps] = trace_L_shell(Rstart,lat_sm_in,lon_sm_in,ds,geo_sm_flag,Rf, T);

lats_n = reshape(latf(1:num_pts*length(L)),num_pts,length(L))';
lons_n = reshape(lonf(1:num_pts*length(L)),num_pts,length(L))';

lats_s = reshape(latf(num_pts*length(L)+1:end),num_pts,length(L))';
lons_s = reshape(lonf(num_pts*length(L)+1:end),num_pts,length(L))';


