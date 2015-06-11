function [L_edges, L_centers, MLT_edges, MLT_centers, lat_edges, lat_centers] = get_bin_edges
% Get bin edges for THEMIS/Polar chorus model

% By Daniel Golden (dgolden1 at stanford dot edu) April 2012
% $Id$

%% THEMIS/Polar bins

% If you change this file, remember to re-run pre_slice_them_chorus.m

% dL = 1.5; % Re
% L_edges = 5:dL:11;
% L_centers = L_edges(1:end-1) + dL/2;
% 
% dMLT = 3; % hours
% MLT_edges = 0:dMLT:24;
% MLT_centers = MLT_edges(1:end-1) + dMLT/2;
% 
% dlat = 10; % degrees
% lat_edges = 0:dlat:50;
% lat_centers = lat_edges(1:end-1) + dlat/2;

%% THEMIS Only bins

% If you change this file, remember to re-run pre_slice_them_chorus.m

dL = 1; % Re
L_edges = 5:dL:11;
L_centers = L_edges(1:end-1) + dL/2;

dMLT = 2; % hours
MLT_edges = 0:dMLT:24;
MLT_centers = MLT_edges(1:end-1) + dMLT/2;

% dlat = 3; % degrees
% lat_edges = 0:dlat:20;
% lat_centers = lat_edges(1:end-1) + dlat/2;
lat_edges = [0 90];
lat_centers = 0;
