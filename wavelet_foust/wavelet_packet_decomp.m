function[coeffs, lengths, depths] = ...
  wavelet_packet_decomp(input, tree, filter, maxlevel, mode, varargin)

%WAVELET_PACKET_DECOMP  Perform a wavelet packet decomposition
%
%   [coeffs] = WAVELET_PACKET_DECOMP(input, tree, filter, maxlevel)
%
%   This function generates the wavelet packet decomposition using the
%   DWT.  The input tree is a 1-d vector of left-right node pairs.  A zero
%   indicates that the branch is null (i.e., the next leaf is null). 
%   The function will recurse at most maxlevel times.
%   Returns the sound data and the DTMF codes generated
%
% Possibilities for good STFT correlation:
%  bior1.3, bior1.5, bior6.8?
%  db4
%  coif2
%  sym8, sym6
%  dmey

if (length(varargin) == 3)
  index = varargin{1};
  level = varargin{2};
  invert = varargin{3};
else
  index = 1;
  level = 1;
  invert = 0;
end;  

%# Implement frequency ordering instead of natural (grey code) ordering
if (invert == 1)
  [CD, CA] = dwt(input, filter, 'mode', mode);
else
  [CA, CD] = dwt(input, filter, 'mode', mode);
end;


if (level == maxlevel || index == 0 || length(input) == 1)
  %# If we're at the last level, store the coeffss unconditionally 
  %# for both leaves.

  %# Low, high (approx, detail)
  coeffs = input;
  lengths = length(input);
  depths = level;

else
  %# Process the left branch (low freq, approx.)
  [coeffs, lengths, depths] = ...
    wavelet_packet_decomp (CA, tree, filter, maxlevel, mode, ...
                           tree(index, 1), level + 1, 0);

  %# Process the right branch (high freq, detail)
  [tmpcoeff, tmplen, tmpdepth] = ...
      wavelet_packet_decomp (CD, tree, filter, maxlevel, mode, ...
                             tree(index, 2), level + 1, 1);
  coeffs = [coeffs, tmpcoeff];
  lengths = [lengths, tmplen];
  depths = [depths, tmpdepth];
end;  
