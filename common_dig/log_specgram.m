function varargout = log_specgram(varargin)
% [S, F, T] = LOG_SPECGRAM(X, FS, WINDOW, NOVERLAP)
% A wrapper for spectrogram

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

%% Error checking
error(nargchk(2, 4, nargin));
error(nargoutchk(0, 3, nargout));

%% Inputs
x = varargin{1};
fs = varargin{2};

if nargin >=3
	window = varargin{3};
else
	window = [];
end

if nargin >=4
	noverlap = varargin{4};
else
	noverlap = [];
end

%% Frequencies
f_min = 300;
f_max = varargin{2}/2;
nfreq = 500;
F = logspace(log10(f_min), log10(f_max), nfreq);

%% Compute spectrogram
[S, F, T] = spectrogram(x, window, noverlap, F, fs);

% switch nargin
% 	case 3
% 		[S, F, T] = spectrogram(varargin{1}, [], [], varargin{2}, varargin{3});
% 	case 4
% 		[S, F, T] = spectrogram(varargin{1}, varargin{4}, [], F, varargin{3});
% 	case 5
% 		[S, F, T] = spectrogram(varargin{1}, varargin{4}, varargin{5}, F, varargin{3});
% end

%% Plot spectrogram
if nargout == 0
	p = pcolor(T, log10(F), db(S));
	set(p, 'linestyle', 'none');
% 	set(gca, 'yscale', 'log');
	xlabel('Time (sec)');
	ylabel('Frequency (log_{10}(Hz))');
end


%% Outputs
if nargout > 0
	varargout{1} = S;
end
if nargout > 1
	varargout{2} = F;
end
if nargout > 2
	varargout{3} = T;
end
