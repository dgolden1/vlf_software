function center_earth(axis_h)
% Center the earth in the figure window so it's consistent across multiple
% times (by default, Matlab shimmies things around to fit them well)
% 
% INPUTS
% 
% axis_h: axis handle

xlims = 3.3;
ylims = 2.9;


xlim(axis_h, [-xlims xlims]);
ylim(axis_h, [-ylims ylims]);
