function varargout = cdf_get_data(filename, varname, epoch0name, timename)
% Get a variable and its time vector from a CDF file
% 
% [data, time] = cdf_get_data(filename, varname, epoch0name, timename)
% 
% Use cdf_list_vars() to get a list of variables in a CDF file
% 
% If epoch0name and timename are not specified, only the data is read

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

data = double(cdfread(filename, 'Variables', varname, 'CombineRecords', true));
varargout{1} = data;

% If caller asked for time...
if nargout > 1
% I THINK that time works as follows:
  % Time of the samples is stored in the ..._time variable.  This is a offset
  % in seconds from the CDF epoch, which is stored in the ..._epoch0
  % variable. So to get the true time, convert the CDF epoch to a datenum and
  % add the ..._time variable divided by 86400 (seconds/day).  I don't see
  % this documented anywhere, but when I do it, the times appear to be
  % correct.

  cdf_epoch = cdfread(filename, 'Variables', epoch0name, 'Records', 1, 'ConvertEpochToDatenum', true);
  time = cdf_epoch{1} + double(cdfread(filename, 'Variables', timename, 'CombineRecords', true))/86400;
  varargout{2} = time;
end
