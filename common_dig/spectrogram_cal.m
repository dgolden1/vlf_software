function varargout = spectrogram_cal(varargin)
% [S_cal, F, T, unit_str, caxis_recommendation] = spectrogram_cal(x, window, noverlap, nfft, fs, sitename, data_datenum)
%  -- make the spectrogram, and plot if no output arguments
% [S_cal, F, T, unit_str, caxis_recommendation] = spectrogram_cal(S_cal, F, T, unit_str, cax)
%  -- plot the spectrogram
% 
% Dan's wrapper for "spectrogram" which is stupid and plots time on the y axis
% Includes calibration
% Can be called to either make the spectrogram or just plot the spectrogram
% given pre-made spectrogram output stuff
% 
% Input data is UNCALIBRATED data.  This function performs the calibration.
% 
% calibration is available for palmer {2000-2010} ONLY

%% Setup
switch nargin
  case 7 % We're making the spectrogram
    b_make_spec = true;
    x = varargin{1};
    window = varargin{2};
    noverlap = varargin{3};
    nfft = varargin{4};
    fs = varargin{5};
    sitename = varargin{6};
    data_datenum = varargin{7};
  case 5 % We're just plotting the spectrogram
    b_make_spec = false;
    S_cal = varargin{1};
    F = varargin{2};
    T = varargin{3};
    unit_str = varargin{4};
    cax = varargin{5};
    
    if isvector(S_cal)
      error('Must supply station name and data_datenum to create spectrogram');
    end
  otherwise
    error('Wrong number of input arguments -- got %d, should be (x, S_cal, F, T, unit_str, cax) or (x, window, noverlap, nfft, fs, sitename, datenum)', nargin);
end

if exist('data_datenum', 'var') && data_datenum < 2020
  error('data_datenum (%f) should be a datenum, not a year.', data_datenum);
end

%% Calibrate if we have calibration data
if b_make_spec
  [x_cal, units, cax] = cal_t(x, fs, sitename, data_datenum);
  [junk, F, T, P] = spectrogram(x_cal, window, noverlap, nfft, fs);
  S_cal = 10*log10(P);
  unit_str = ['dB-' units '/Hz^{1/2}'];
end

%% Plot
if nargout == 0 || ~b_make_spec
  imagesc(T, F, S_cal);
  axis xy;
  xlabel('Time (sec)');
  ylabel('Frequency (Hz)');
  c = colorbar;
  set(get(c, 'ylabel'), 'string', unit_str);
  caxis(cax);
  set(gca, 'tickdir', 'out');
end

%% Assign output arguments
if nargout >= 1, varargout{1} = S_cal; end
if nargout >= 2, varargout{2} = F; end
if nargout >= 3, varargout{3} = T; end
if nargout >= 4, varargout{4} = unit_str; end
if nargout >= 5, varargout{5} = cax; end
