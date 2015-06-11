function varargout = spectrogram_dan(x, window, noverlap, nfft, fs, b_use_psd)
% [S, F, T, P] = spectrogram_dan(x, window, noverlap, nfft, fs, b_use_psd)
% h = spectrogram_dan(x, window, noverlap, nfft, fs, b_use_psd)
% Dan's wrapper for "spectrogram" which is stupid and plots time on the y axis
% 
% If nargout > 1, the spectrogram is not plotted.
% 
% If b_use_psd is false (default), the (un-normalized) STFT is plotted.
% Otherwise, the PSD is plotted.  You probably want the PSD instead of the
% STFT, but the STFT is the default to agree with the spectrogram()
% function

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id$

if ~exist('b_use_psd', 'var') || isempty(b_use_psd)
  b_use_psd = false;
end

if nargout >= 4 || b_use_psd
  [S, F, T, P] = spectrogram(x, window, noverlap, nfft, fs);
else
  [S, F, T] = spectrogram(x, window, noverlap, nfft, fs);
end

if nargout <= 1
  if b_use_psd
    h = imagesc(T, F, 10*log10(abs(P)));
  else
    h = imagesc(T, F, db(S));
  end
  
	axis xy;
	xlabel('Time (sec)');
	ylabel('Frequency (Hz)');
end

if nargout == 1, varargout{1} = h; end
if nargout > 1, varargout{1} = S; end
if nargout >= 2, varargout{2} = F; end
if nargout >= 3, varargout{3} = T; end
if nargout >= 4, varargout{4} = P; end
