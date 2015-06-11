function amplitude = get_true_emission_amplitude(f, s_mediogram, idx_lc, idx_uc)
% Get true emission amplitude, in dB-fT
% amplitude = get_true_emission_amplitude(f, s_mediogram, idx_lc, idx_uc)
% 
% Input mediogram is created from CALIBRATED time-domain data, and is in
% units of dB

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

if ~exist('idx_lc', 'var') || isempty(idx_lc)
  idx_lc = 1;
end
if ~exist('idx_uc', 'var') || isempty(idx_uc)
  idx_uc = length(s_mediogram);
end

df = f(2) - f(1);
these_medio_values = s_mediogram(idx_lc:idx_uc);
amplitude = 10*log10(sum(10.^(these_medio_values/10))*df);
