function [MeanSquaredError HumEstimate] = humestimator(Data, HumFrequency, fs, HarmonicNumbers)
% Solves Y = AX + b to estimate hum, where X is the vector of amplitudes
% and phases (both sine and cosine) of the hum, b is everything else in the
% VLF data, and Y is the observed VLF data. Least-squares estimate of hum
% is generated after estimating X. Frequency is assumed known at this point.

% $Id$

t = (1:length(Data))/fs;
[TimeMesh HarmonicNumbersMesh] = meshgrid(t,HarmonicNumbers);
A = [cos(2*pi*HumFrequency*HarmonicNumbersMesh.*TimeMesh); sin(2*pi*HumFrequency*HarmonicNumbersMesh.*TimeMesh)]';
Hum = inv(transpose(A)*A)*transpose(A)*Data;  % Equivalent to Hum = A\Data, but this seems to run faster
% Hum = A\Data;  % This is about 5 times slower for some reason
HumEstimate = A*Hum;
MeanSquaredError = sqrt(sum((HumEstimate-Data).^2))/length(Data);
