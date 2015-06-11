function them = package_themis_struct(probe, epoch, field_power, eph)
% Package THEMIS parameters into a common struct

% By Daniel Golden (dgolden1 at stanford dot edu) October 2011
% $Id$

them.probe = probe;
them.epoch = epoch;
them.field_power = field_power;

fn = {'lat', 'MLT', 'L', 'xyz_sm'};
for jj = 1:length(fn)
  them.(fn{jj}) = eph.(fn{jj});
end
