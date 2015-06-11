function eph = get_ephemeris(probe, start_datenum, end_datenum)
% eph = get_ephemeris(probe, start_datenum, end_datenum)
% 
% Get THEMIS ephemeris data for a given probe in a given time range
% 
% INPUTS
% probe: one of 'A', 'B', 'C', 'D' or 'E'
% 
% OUTPUTS
% eph: struct with the following fields:
%   epoch (Nx1, UTC)
%   xyz_sm  (Nx3, dipole solar magnetic, earth radii)
%   lat     (Nx1, dipole, degrees)
%   MLT     (Nx1, dipole, hours)
%   L       (Nx1, dipole, earth radii)

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

%% Setup
eph_dir = fullfile(scottdataroot, 'spacecraft', 'themis', 'ephemeris');

if ~ischar(probe) || ~any(strcmpi({'A', 'B', 'C', 'D', 'E'}, probe))
  error('Probe should be one of ''A'', ''B'', ''C'', ''D'' or ''E''');
end

if ~exist('start_datenum', 'var') || isempty(start_datenum)
  start_datenum = 0;
end
if ~exist('end_datenum', 'var') || isempty(end_datenum)
  end_datenum = Inf;
end

%% Get ephemeris
filename = sprintf('th%s_ephemeris.mat', lower(probe));
eph_raw = load(fullfile(eph_dir, filename));

%% Parse out time range
idx = eph_raw.epoch >= start_datenum & eph_raw.epoch < end_datenum;
for field = fieldnames(eph_raw).'
  eph.(field{1}) = eph_raw.(field{1})(idx, :);
end

%% Tack on latitude, MLT and L
[eph.lat, eph.MLT, eph.L] = xyz_to_lat_mlt_L(eph.xyz_sm);
