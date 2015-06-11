function [T96_date, Pdyn, ByIMF, BzIMF] = T96_read_datenum(year)
% [T96_date, Pdyn, ByIMF, BzIMF] = T96_read_datenum(year)
% 
% Function to get solar wind parameters for running the T96 Tsyganenko
% magnetic field model from OMNI_5m_with_TS05_variables files
% 
% Files can be downloaded from
% http://geo.phys.spbu.ru/~tsyganenko/TS05_data_and_stuff/ and turned into
% trimmed .mat files with T96_parse_file().

% By Daniel Golden (dgolden1 at stanford dot edu) February 2010
% $Id$

T96_filename = sprintf('%04d_OMNI_5m_with_TS05_variables.mat', year);
load(T96_filename);

% Well that wasn't very hard...
