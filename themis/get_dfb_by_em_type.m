function [epoch, field_power, eph] = get_dfb_by_em_type(probe, em_type)
% Get DFB data for either chorus or hiss
% 
% [epoch, field_power, eph] = get_dfb_by_em_type(probe, em_type)
% 
% INPUTS
% probe: one of 'A', 'B', 'C', 'D' or 'E'
% em_type: one of 'chorus', 'hiss' or 'both'
% 
% OUTPUTS
% epoch: datenum of each point
% field_power: fb_scm1 amplitude squared (nT^2)
% L: dipole L-shell determined from ephemeris
% MLT: dipole MLT determined from ephemeris

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
error(nargchk(2, 2, nargin));

if ~ischar(probe)
  error('Probe must be one of A, B, C, D or E');
end

b_use_subsampled_densities = false;

%% Get DFB and density data
data_filename = fullfile(vlfcasestudyroot, 'themis_emissions', 'fb_scm1', sprintf('th%s_fb_scm1_dens_common.mat', lower(probe)));
them = load(data_filename, 'epoch', 'fb_scm1', 'loc_flag', 'f_lim');


%% Get ephemeris
eph = get_ephemeris(probe);

%% All emissions
% Just return the three highest channels (f > 80 Hz) if we're getting all emissions
if strcmp(em_type, 'both')
  epoch = them.epoch;
  field_power = them.field_power; % nT^2
end

%% Don't choose density epochs where the B-field data has gaps
% min_data_gap = 10/1440; % A data gap is a gap of this length or greater (days)
% dg = find(diff(dfb.epoch) >= min_data_gap);
% 
% % The FAST way to find density epochs that are in data gaps
% % Histogram bins are like:
% % | gap | continuous | gap | continuous | ...
% % So everything in an odd bin is inside a data gap
% [~, bin] = histc(dens.epoch, sort(dfb.epoch([dg; dg + 1])));
% idx_dens_valid = mod(bin, 2) == 0;
% 
% % The SLOW way
% % idx_dens_valid_slow = true(size(dens.epoch));
% % for kk = 1:length(dg)
% %   idx_dens_valid_slow(dens.epoch >= dfb.epoch(dg(kk)) & dens.epoch < dfb.epoch(dg(kk)+1)) = false;
% % end
% 
% dens.epoch = dens.epoch(idx_dens_valid);
% dens.loc_flag = dens.loc_flag(idx_dens_valid);

%% Hiss
% Hiss is anything in the upper three frequency bins (80 Hz < f < 6 kHz)
% inside the plasmapause off of the equator
% Hiss is informally anything below 2 kHz, but the highest bin goes from
% 1.4 kHz to 6 kHz.  An alternate definition could be bins 2 and 3 only,
% excluding bin 1.
if strcmp(em_type, 'hiss')
  [epoch, field_power] = get_hiss_power(them, eph);
  
%   idx = dens.loc_flag == 0; % epochs inside plasmasphere
%   epoch = dens.epoch(idx);
%   
%   field_power = sum(interp1(dfb.epoch, dfb.fb_scm1(:, 1:3), dens.epoch(idx)).^2, 2);
%   % field_power = sum(interp1(dfb.epoch, dfb.fb_scm1(:, 2:3), dens.epoch(idx).^2, 2);
end

%% Chorus
% Chorus is anything outside the plasmasphere but inside the magnetosphere
% in bins which span 0.1--0.5 fceq
if strcmp(em_type, 'chorus')
  eph = get_ephemeris(probe);
  
  [epoch, field_power] = get_chorus_power(them, eph);

%   idx = dens.loc_flag == 1; % epochs outside plasmasphere and inside magnetosphere
% 
%   q = 1.6022e-19; % elementary charge, C
%   me = 9.1094e-31; % electron mass, kg
%   B0 = 3.12e-5;
%   Beq_dipole = B0*(1./interp1(eph.epoch, eph.L, dens.epoch(idx)).^3);
%   fceq_dipole = q*Beq_dipole/(2*pi*me);
%   
%   f_low = 0.1*fceq_dipole;
%   f_high = 0.5*fceq_dipole;
%   
%   dfb_mag_ch = zeros(sum(idx), 3);
%   for kk = 1:3
%     channel_bw = diff(dfb.f_lim(:,kk));
%     channel_fraction_covered = 1 - min(1, (max(0, f_low - dfb.f_lim(1,kk)) + max(0, dfb.f_lim(2,kk) - f_high))/channel_bw);
%     dfb_mag_ch(:,kk) = interp1(dfb.epoch, dfb.fb_scm1(:,kk), dens.epoch(idx)).*channel_fraction_covered;
%   end
%   
%   epoch = dens.epoch(idx);
%   field_power = sum(dfb_mag_ch.^2, 2);
  
end

%% Interpolate each field of eph onto new epochs
eph_epoch = eph.epoch;
eph = rmfield(eph, 'epoch');
fn = fieldnames(eph);
for kk = 1:length(fn)
  if strcmp(fn{kk}, 'MLT')
    % MLT is cyclical, so interpolting across MLT = 0 will give the wrong
    % answer (e.g., interp1([1 2], [23.5 0.5], 1.5 should give 0, but it
    % gives 12). Instead interpolate the complex exponential and get the angle
    eph.(fn{kk}) = mod(angle(interp1(eph_epoch, exp(j*eph.(fn{kk})*2*pi/24), epoch))*24/(2*pi), 24);
  else
    eph.(fn{kk}) = interp1(eph_epoch, eph.(fn{kk}), epoch);
  end
end


function [epoch, field_power] = get_hiss_power(them, eph)
%% Function: get hiss power for a single probe

% magnetic (dipole) latitude must be this many degrees off the equator to
% avoid equatorial magnetosonic emissions
min_lat = 4;

lat = interp1(eph.epoch, eph.lat, them.epoch);

epoch_idx = them.loc_flag == 0 & ... % The nearest density measurement is one that's inside the plasmasphere
            abs(lat) > min_lat; % We're off the equator (to eliminate equatorial magnetosonic waves)

epoch = them.epoch(epoch_idx);
field_power = sum(them.fb_scm1(epoch_idx,:).^2, 2);

1;

function [epoch, field_power] = get_chorus_power(them, eph)
%% Function: get chorus power for a single probe

L = interp1(eph.epoch, eph.L, them.epoch);

epoch = them.epoch;

q = 1.6022e-19; % elementary charge, C
me = 9.1094e-31; % electron mass, kg
B0 = 3.12e-5;
Beq_dipole = B0*(1./L.^3);
fceq_dipole = q*Beq_dipole/(2*pi*me);

f_low = 0.1*fceq_dipole;
f_high = 0.7*fceq_dipole;

% Any of the chorus generation frequency range is outside of the upper
% three channels of the FBK
idx_out_of_range = f_high > 4e3 | f_low < them.f_lim(1, 3);

dfb_mag_ch = nan(length(epoch), 3);
for kk = 1:3
  chan_f_low = them.f_lim(1,kk);
  chan_f_high = them.f_lim(2,kk);
  
  channel_bw = diff(them.f_lim(:,kk));
  
  % Determine the fraction of this channel that is within the chorus
  % source frequency range
  channel_fraction_covered = min(1, max(0, min(f_high, chan_f_high) - max(f_low, chan_f_low))/channel_bw);
% 
%   % Use a nearest neighbor interpolant to avoid interpolating between 0s and
%   % valid values
%   dfb_mag_ch(:,kk) = them.fb_scm1(:,kk).*(channel_fraction_covered >= 0.1);

  % Set the channel amplitude to zero if the channel bandwidth is
  % completely outside the chorus range
  % If the chorus range is at all outside the FBK range (idx_out_of_range
  % == true), then leave the magnitude at NaN
  dfb_mag_ch(~idx_out_of_range,kk) = them.fb_scm1(~idx_out_of_range, kk).*(channel_fraction_covered(~idx_out_of_range) > 0);
end

field_power = sum(dfb_mag_ch.^2, 2);

% Valid points are those with finite power (i.e., chorus generation
% frequencies are not out of range of the DFB) and are outside the
% plasmasphere but inside the magnetosphere
idx_valid = isfinite(field_power) & them.loc_flag == 1;

field_power = field_power(idx_valid);
epoch = epoch(idx_valid);
