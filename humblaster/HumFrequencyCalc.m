function BestGuessFrequency = HumFrequencyCalc(Data_In, fs, HarmonicNumbers, NominalHumFrequency)

% Written by Morris Cohen, last modified October 2009
% This module written for use in HumBlaster power-line interference removal
%
% Calculates best-guess fundamental frequency, within 2 Hz of the nominal
% frequency. Determination of the frequency more exactly simply speeds up
% the nonlinear least-squares optimization, so this step is not actually
% required.

% $Id$

DataLength = length(Data_In)/fs;
Window = gausswin(length(Data_In));
DataFFT = fft(Window.*Data_In);
LogFFT = log10(abs(DataFFT));
FFT_Frequencies = (0:(length(DataFFT)-1))*fs/length(DataFFT);
AllowedFundamentalDrift = NominalHumFrequency/max(HarmonicNumbers)/2;
EstimatedFrequencies = [];
EstimatedPeaks = [];
for Harmonic = HarmonicNumbers
    IndicesToSearch = find(abs(FFT_Frequencies-NominalHumFrequency*Harmonic) <= AllowedFundamentalDrift*Harmonic);
    [Max Index] = max(LogFFT(IndicesToSearch));
    Index = Index + IndicesToSearch(1) - 1;
    [InterpolationFrequency InterpolationPeak] = Quadratic_Interpolation(FFT_Frequencies(Index),1/DataLength,LogFFT(Index-1),LogFFT(Index),LogFFT(Index+1));
    EstimatedFrequency = InterpolationFrequency/Harmonic;

    % If we failed to find a reasonable frequency, discard this measurement
    if abs(EstimatedFrequency - NominalHumFrequency) > 5*AllowedFundamentalDrift
      continue;
    end
    
    EstimatedFrequencies = [EstimatedFrequencies; EstimatedFrequency];
    EstimatedPeaks = [EstimatedPeaks; 10^(InterpolationPeak)];
end

if isempty(EstimatedFrequencies)
    BestGuessFrequency = nan;
else
    BestGuessFrequency = sum(EstimatedFrequencies.*EstimatedPeaks)/sum(EstimatedPeaks);
end
