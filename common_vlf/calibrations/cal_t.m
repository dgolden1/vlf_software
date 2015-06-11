function [data_cal, units, cax_recc] = cal_t(data, fs, sitename, data_datenum, channel)
% [data_cal, units, cax_recc] = cal_t(data, fs, sitename, data_datenum, channel)
% Calibrate time-domain data from a given site and date
% 
% INPUTS
% data: uncalibrated non-interleaved time-domain data variable
% fs: sampling frequency (Hz)
% data_datenum: datenum of data (some site calibrations vary by date
% channel: 0 = N/S, 1 = E/W (magnetic field)
% 
% OUTPUTS
% data_cal: calibrated version of the data
% units: units of the calibrated data (currently fT)
% cax_recc: recommended color axis when plotting the power spectral density
% in dB (that's the P output of spectrogram())
% 
% NOTE: this calibration will almost definitely destroy phase information;
% use uncalibrated data for any analysis that makes use of phase

% Originally by Maria Spasojevic
% By Daniel Golden (dgolden1 at stanford dot edu) February 2010
% $Id$

%% Setup
error(nargchk(4, 5, nargin));
assert(isvector(data));
data = data(:); % Column vector only, please

if ~exist('channel', 'var') || isempty(channel)
  channel = 0; % N/S channel by default
end

%% Load proper calibration
persistent cal last_datenum last_sitename

% This calibration data should convert from raw numeric values to
% picoteslas

if isempty(cal) || last_datenum ~= data_datenum || ~strcmp(last_sitename, sitename)
  switch sitename
    case 'palmer'
      if data_datenum < datenum([2005 04 06 0 0 0])
          load('cal_palmer_2003-11-01.mat'); % The cal that Maria gave me in 2007
      else
          load('cal_palmer_2009-04-02.mat'); % My comb calibration from 2009
      end
    otherwise
      data_cal = data;
      units = 'uncal';
      cax_recc = [-35 35];
      return
%       error('No calibration data available for site %s', sitename);
  end
  
  last_datenum = data_datenum;
  last_sitename = sitename;
end

%% Deal with odd length data
% % If data has an odd length, interpolate it into one more sample.  This is
% % a kludge, and certainly destroys phase information.
% 
% if mod(length(data), 2) ~= 0
% 	data = interp1(linspace(0, 1, length(data)).', data, linspace(0, 1, length(data) + 1).', 'pchip');
% end

% If data has an odd length, add a sample
if mod(length(data), 2) ~= 0
  data = [data; interp1(0:length(data)-1, data, length(data), 'pchip', 'extrap')];
end

%% Calibrate
Data = fft(data);
f = (0:(length(Data)-1))/length(Data)*fs;

if channel == 1
  this_cal = cal.ew;
else
  this_cal = cal.ns;
end

cal_int = interp1(cal.f, cal.ns, f(1:(end/2)+1)); % Up to Nyquist
if any(isnan(cal_int))
  error('Attempted to interpolate cal beyond known frequencies.');
end

Data_cal_pT = Data.*[cal_int fliplr(cal_int(2:end-1))].';
data_cal_pT = ifft(Data_cal_pT);

% This assumes that the cal information converts from sample amplitude to pT.  

% I like femtoteslas better
data_cal_fT = data_cal_pT*1e3;

data_cal = data_cal_fT;
units = 'fT';

cax_recc = [-15 30]; % For the 2003 cal
% cax_recc = [15 60]; % For Ryan's 2004 cal
