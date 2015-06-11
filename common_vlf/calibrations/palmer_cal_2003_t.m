function [data_cal, units, cax_recc] = palmer_cal_2003_t(data, fs)
% Depreciated.  Use palmer_cal_t instead.

% Originally by Maria Spasojevic
% By Daniel Golden (dgolden1 at stanford dot edu) February 2010
% $Id$

warning('This function is depreciated.  Use palmer_cal_t instead.');
[data_cal, units, cax_recc] = palmer_cal_t(data, fs, 2003);
