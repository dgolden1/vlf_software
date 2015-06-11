function[output] = grid_wavelet_packet(coeffs, lengths, depths)

% GRID_WAVELET_PACKET  Grid a wavelet packet for plotting.
%
%   GRID_WAVELET_PACKET(coeffs, lengths, depths)
%
%   This function plots a wavelet packet decomposition given 
%   the coefficients and a suitable length vector.

%# Plot from the lowest 'frequency' to the highest.

%# Plot on a symmetric matrix.  Find the maximum length.  This 
%# dictate the width of the matrix.
maxlen = max (lengths);
%# Find the maximum depth.  This will set the smallest vertical increment.
maxdepth = max (depths);

%# Iterate over the coefficients, starting at the beginning (it's frequency
%# ordered so this is the lowest frequency).

output = [];

coeff_index = 1;
row_index = 1;
%# For each collection of coefficients
for i=[1:1:length(lengths)]
  %# For each graphical row
  for j=[1:1:2^(maxdepth-depths(i))]
    %# For each graphical column
    for k=[1:1:maxlen]
      %# Grid the coefficients
      output(row_index + j-1,k) = ...
          coeffs(coeff_index + floor(lengths(i)*((k-1)/maxlen)));
    end;
  end;
  coeff_index = coeff_index + lengths(i);
  row_index = row_index + 2^(maxdepth-depths(i));
end;

output = flipud (output);
