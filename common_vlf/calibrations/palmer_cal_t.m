function [data_cal, units, cax_recc] = palmer_cal_t(data, fs, data_datenum)
% This function is obsolete.  Use cal_t()

% By Daniel Golden (dgolden1 at stanford dot edu) February 2010
% $Id$

warning('This function is obsolete.  Use cal_t()');
[data_cal, units, cax_recc] = cal_t(data, fs, 'palmer', data_datenum);
