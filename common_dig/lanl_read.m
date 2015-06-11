% function [UT, glat, glon, radius, e050_075, e075_105, e105_150, e150_225, e225_315, e315_500, e500_750, e750_11, e11_15, e15] = lanl_read(filename)
function [UT, glat, glon, radius, energies] = lanl_read(filename)
% [UT, glat, glon, radius, energies] = lanl_read(filename)
% function to parse LoE data from LANL satellites
% request data from here: http://leadbelly.lanl.gov/lanl_ep_data/request/ep_request.cgi
% see graphs online at: http://leadbelly.lanl.gov/lanl_ep_data/cgi-bin/ep_plot_choose_3.cgi
% 
% INPUTS
% filename: the LANL filename
% 
% OUTPUTS
% UT: vector of universal times (in decimal hours)
% glat: vector of geographic latitude (degrees)
% glon: vector of geographic longitude (degrees)
% radius: vector of satellite radius (from center of Earth, in Earth radii)
% energies: structs with fields
%  o e_low = lower energy level (keV)
%  o e_high = higher energy level (keV)
%  o flux = matrix of values of particle flux, in #/cm^2/s/str/keV
%     energies go across rows, and time goes down columns



% By Daniel Golden (dgolden1 at stanford dot edu) October 19, 2007
% $Id$

%% Setup
error(nargchk(1, 1, nargin));

[fid, message] = fopen(filename);
if fid == -1
	error(message);
end

%% Preallocate vectors

% Count lines
numlines = 0;
while ~feof(fid)
	line = fgetl(fid);
	if length(line) < 3, continue; end

	numlines = numlines + 1;
end
numlines = numlines - 1; % Skip the header row
frewind(fid); % Rewind file

% Preallocate vectors
UT = zeros(numlines, 1);
glat = zeros(numlines, 1);
glon = zeros(numlines, 1);
radius = zeros(numlines, 1);
e050_075 = zeros(numlines, 1);
e075_105 = zeros(numlines, 1);
e105_150 = zeros(numlines, 1);
e150_225 = zeros(numlines, 1);
e225_315 = zeros(numlines, 1);
e315_500 = zeros(numlines, 1);
e500_750 = zeros(numlines, 1);
e750_11 = zeros(numlines, 1);
e11_15 = zeros(numlines, 1);
e15 = zeros(numlines, 1);

%% Parse the file

junk = fgetl(fid); % Skip the first line, which is header info
lineno = 1;
while ~feof(fid)
% 	values = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', 14);
	values = fscanf(fid, '%f', 14);
	
	% If this line is incomplete, we're at the end of the file
	if length(values) < 14, break; end
	
	UT(lineno) = values(1);
	glat(lineno) = values(2);
	glon(lineno) = values(3);
	radius(lineno) = values(4);
	e050_075(lineno) = values(5);
	e075_105(lineno) = values(6);
	e105_150(lineno) = values(7);
	e150_225(lineno) = values(8);
	e225_315(lineno) = values(9);
	e315_500(lineno) = values(10);
	e500_750(lineno) = values(11);
	e750_11(lineno) = values(12);
	e11_15(lineno) = values(13);
	e15(lineno) = values(14);
	
	% Skip the rest of the line
	junk = fgetl(fid);
	
	lineno = lineno + 1;
end

%% Populate the vector of energy structs
% energies = repmat(struct('e_low', 0, 'e_high', 0, 'flux', []), 1, 10);
energies = struct('e_low', zeros(1, 10), 'e_high', zeros(1, 10), ...
	'flux', zeros(numlines, 10));
energies.e_low(1) = 50;
energies.e_high(1) = 75;
energies.flux(:,1) = e050_075;

energies.e_low(2) = 75;
energies.e_high(2) = 105;
energies.flux(:,2) = e075_105;

energies.e_low(3) = 105;
energies.e_high(3) = 150;
energies.flux(:,3) = e105_150;

energies.e_low(4) = 150;
energies.e_high(4) = 225;
energies.flux(:,4) = e150_225;

energies.e_low(5) = 225;
energies.e_high(5) = 315;
energies.flux(:,5) = e225_315;

energies.e_low(6) = 315;
energies.e_high(6) = 500;
energies.flux(:,6) = e315_500;

energies.e_low(7) = 500;
energies.e_high(7) = 750;
energies.flux(:,7) = e500_750;

energies.e_low(8) = 750;
energies.e_high(8) = 1100;
energies.flux(:,8) = e750_11;

energies.e_low(9) = 1100;
energies.e_high(9) = 1500;
energies.flux(:,9) = e11_15;

energies.e_low(10) = 1500;
energies.e_high(10) = inf;
energies.flux(:,10) = e15;
