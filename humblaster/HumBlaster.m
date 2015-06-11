function [Data_Out, UpsampledHumEstimate, HumFrequencies, MeanSquaredError] = HumBlaster(Data_In, fs, EstimationHarmonicNumbers, OptimizationHarmonicNumbers, SubtractionHarmonicNumbers, NominalHumFrequency, EstimationSegmentLength, LeastSquaresSegmentLength, UseEstimation)

%------------------------------------------------
%--------------- THE HUMBLASTER -----------------
%------------------------------------------------
%--------- WRITTEN BY MORRIS B. COHEN -----------
%------------- MCOHEN@STANFORD.EDU --------------
%------------------------------------------------
%------------ STANFORD UNIVERSITY ---------------
%------------------------------------------------
%---------- LAST MODIFIED 22-JAN-2010 -----------
%------------------------------------------------
%
% Additional modifications by Dan Golden.
%
% This Matlab script removes 50 or 60 Hz power line signals from ELF/VLF.
%
% The code was written with Matlab 2008a. It's probably not written in the
% most computationally efficient way possible.
% 
% This function takes the following inputs:
%
% Data_In                     -- the raw data
% 
% fs                          -- the sampling frequency in Hz
% 
% EstimationHarmonicNumbers -- These are the power line harmonics used to
% estimate the frequency via quadratic interpolation.  So if this is 1:2,
% then the first two harmonics of 60 Hz (or 50 Hz). This variable is only
% used if quadratic interpolation is used to estimate the frequency.
%
% OptimizationHarmonicNumbers -- These are the power line harmonics used to
% optimize the least-squares routine for frequency.estimate the frequency
% It's best to put in a number of the highest-SNR power line harmonics in
% your data.  I've been using 1:2:15, since the odd harmonics tend to be
% much stronger than even, but if you have an instance where the bottom
% portion of the spectrum is overwhelmed by natural noise like hiss or
% something, you would have to use higher harmonics.  It is this variable
% that most scales the computation time linearly with the number of
% harmonics you use, so put in only the harmonics that you need to get good
% results.  If I have time down the road, I'll figure out a way to
% automatically determine this. This variable only matters if optimization,
% as opposed to estimation, is used to determine the frequency.
% 
% SubtractionHarmonicNumbers  -- This is the set of power line harmonics
% you want to remove.  So if you want to remove the 60 Hz harmonics only
% between 1 and 2 kHz, this would be 17:33.
% 
% NominalHumFreq              -- the frequency of the power lines
% 
% EstimationSegmentLength     -- The humblaster actually divides the data
% into pieces, and assumes a constant frequency within each piece.  This
% variable sets the length of those pieces (seconds) for the purpose of
% estimating the fundamental frequency via quadratic interpolation.
%
% LeastSquaresSegmentLength   -- The humblaster actually divides the data
% into pieces, and assumes a constant frequency within each piece.  This
% variable sets the length of those pieces (seconds) for the purpose of
% least squares optimization.
%
% UseEstimation               -- Key decision: This variable offers you a
% choice between two ways of tracking the freqeuncy: either estimation via
% quadratic interpolation, or optimization via nonlinea least-squares
% analysis. "1" will choose the former.
%
% I provide this code as is, and cannot guarantee that it will always
% work, or work effectively. Power line signals vary widely. In general,
% the steadier/more well behaved is a power line signal, the better this
% will work.
%
%
% I hope you find this product useful.  Good luck,
% 
%    -- M. B. Cohen
%       Stanford University Electrical Engineering
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% $Id$

% Remove DC bias, convert to column vector
Data_In = Data_In(:) - mean(Data_In);

% Calculate maximum downsampling
MinSamplingFreqEstimation = round(NominalHumFrequency*max(EstimationHarmonicNumbers)*3);
MinSamplingFreqOptimization = round(NominalHumFrequency*max(OptimizationHarmonicNumbers)*3);
MinSamplingFreqSubtraction = round(NominalHumFrequency*max(SubtractionHarmonicNumbers)*3);

%% FREQUENCY ESTIMATION (IF CHOSEN)
if UseEstimation == 1
    EstimationNumberOfSegments = floor(length(Data_In)/(EstimationSegmentLength*fs));
    EstimationFrequencies = [];
    EstimationFrequenciesTimes = [];
    for ii = 1:EstimationNumberOfSegments  % GO!!
        
        % Extract current segment of data
        SegmentStartIndex = fs*(ii-1)*EstimationSegmentLength+1;
        SegmentEndIndex = fs*ii*EstimationSegmentLength;
        Data_Segment = Data_In(SegmentStartIndex:SegmentEndIndex);
        
        % Perform downsampling
        Data_Estimation = resample(Data_Segment,MinSamplingFreqEstimation,round(fs));
        
        % Estimate frequency with quadradic interpolation
        EstimationFrequency = HumFrequencyCalc(Data_Segment, fs, EstimationHarmonicNumbers, NominalHumFrequency);
        
        % Update output
        EstimationFrequencies = [EstimationFrequencies; EstimationFrequency];
        EstimationFrequenciesTimes = [EstimationFrequenciesTimes; (ii-0.5)*EstimationSegmentLength];
        
    end
end

%% LEAST SQUARES REMOVAL

% Determine number of segments
NumberOfSegments = floor(length(Data_In)/(LeastSquaresSegmentLength*fs));

Data_Out = [];
UpsampledHumEstimate = [];
HumFrequencies = nan(NumberOfSegments, 1);
MeanSquaredError = 0;
MeanSquaredErrorVec = zeros(NumberOfSegments, 1);
for ii = 1:NumberOfSegments

    % Extract current segment of data   
    SegmentStartIndex = fs*(ii-1)*LeastSquaresSegmentLength+1;
    SegmentEndIndex = fs*ii*LeastSquaresSegmentLength;
    Data_Segment = Data_In(SegmentStartIndex:SegmentEndIndex);

    % Perform downsampling
    Data_Optimization = resample(Data_Segment,MinSamplingFreqOptimization,round(fs));
    Data_Subtraction = resample(Data_Segment,MinSamplingFreqSubtraction,round(fs));
    
    % Find best frequency
    if UseEstimation ~= 1  % Use non-linear optimization 
        options = optimset('Display', 'Off');
        [HumFrequency,resnorm,residual,exitflag,output] = lsqnonlin(@(HumFrequency) HumEstimator(Data_Optimization, HumFrequency, MinSamplingFreqOptimization, OptimizationHarmonicNumbers),NominalHumFrequency, NominalHumFrequency-0.1, NominalHumFrequency+0.1, options);
    else  % Use the previously calculated quadratic interpolation estimation results
        idx_nan = isnan(EstimationFrequencies);
        HumFrequency = interp1(EstimationFrequenciesTimes(~idx_nan),EstimationFrequencies(~idx_nan),(ii-0.5)*LeastSquaresSegmentLength,'pchip');
%         HumFrequency = EstimationFrequencies(nearest((ii-0.5)*LeastSquaresSegmentLength, EstimationFrequenciesTimes));
    end

    % HumFrequency can be Nan if the quadratic interpolation failed for all
    % harmonics in the frequency estimation step, above
    if ~isnan(HumFrequency)
        % Determine hum at optimal frequency and subtract
        [MeanSquaredError_Segment HumEstimate_Segment] = HumEstimator(Data_Subtraction, HumFrequency, MinSamplingFreqSubtraction, SubtractionHarmonicNumbers);

        MeanSquaredError = MeanSquaredError + MeanSquaredError_Segment;
        MeanSquaredErrorVec(ii) = MeanSquaredError_Segment;
    end
    
    % Use this estimate only if the error is low and the hum frequency
    % isn't more than 2 Hz off
    if true || ~isnan(HumFrequency) && MeanSquaredError_Segment < 1.5 && abs(HumFrequency - NominalHumFrequency) < 2
        UpsampledHumEstimate_Segment = resample(HumEstimate_Segment,round(fs),MinSamplingFreqSubtraction);
        Data_Out = [Data_Out; Data_Segment - UpsampledHumEstimate_Segment];
        UpsampledHumEstimate = [UpsampledHumEstimate; UpsampledHumEstimate_Segment];   
        HumFrequencies(ii) = HumFrequency;    
    else  % Big error
%         disp(sprintf('DEBUG Segment %d (t = %0.1f sec): MSE = %0.1f, skipping', ii, (ii-1)*LeastSquaresSegmentLength, MeanSquaredError_Segment));
        Data_Out = [Data_Out; Data_Segment];
        UpsampledHumEstimate = [UpsampledHumEstimate; 0*length(Data_Segment)];   
    end

end

1;
