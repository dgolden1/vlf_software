function [L,latf,lonf,num_steps] = calculateConjLshellPt(T,lat,lon,alt_start,alt_end)
%syntax:  [L,latf,lonf,num_steps] = calculateConjLshellPt(T,lat,lon,alt_start,alt_end)
%
%T is [year month day hour minute second]
%input lat,lon can be vectors of size 1xn
%returns L,latf,lonf,num_steps of vectors 1xn
%L is L-shell value
%alt_start, alt_end in km
%compare with http://modelweb.gsfc.nasa.gov/models/cgm/cgm.html
%
%example: 
%[L,latf,lonf,num_steps] = calculateConjLshellPt([2001 1 1 0 0 0],[60,40],[0,270],100,100)
%
% Ryan Said, Sep 18, 2007

R0 = almanac('earth','radius','km');

delta_pt = .1;

ds = delta_pt*sign(lat);
ds(ds==0) = delta_pt;
geo_sm_flag = ones(size(lat));
alt_start = alt_start*ones(size(lat));
alt_terminate = alt_end*ones(size(lat));

Rstart = 1+alt_start/R0;
Rf = 1+alt_terminate/R0;
[L,latf,lonf,num_steps] = trace_L_shell(Rstart,lat,lon,ds,geo_sm_flag,Rf, T);
