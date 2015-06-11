function[frequencies] = ...
  wavelet_packet_frequency_ranges(lengths)

%WAVELET_PACKET_FREQUENCY_RANGES  Return the normalized frequencies (zero to 1)
%   given the lengths vector from wavelet_packet_decomp().
%
%   Each element in the returned vector is the upper bound of the frequencies.

frequencies = lengths / sum(lengths);

for i=2:1:length(frequencies)
  frequencies(i) = frequencies(i) + frequencies(i-1);
end;

