function [Output, PowerLineSignal, WeightedFrequency, FrequencyMeasurementTimes]  = humstractor(data_input, fs, NominalHumFreq, HumDecayTime, FrequencyDecayTime, PlotTrackedFrequency, PlotPowerLineSignal)

%------------------------------------------------
%--------------- THE HUMSTRACTOR ----------------
%------------------------------------------------
%--------- WRITTEN BY MORRIS B. COHEN -----------
%------------- MCOHEN@STANFORD.EDU --------------
%----------- MORRIS.COHEN@GMAIL.COM -------------
%--------------- AND RYAN K. SAID ---------------
%------------------------------------------------
%------------ STANFORD UNIVERSITY ---------------
%------------------------------------------------
%---------- LAST MODIFIED 26-MAR-2009 -----------
%------------------------------------------------
%
% This Matlab script removes 50 or 60 Hz power line signals from ELF/VLF.
%
% The code was written with Matlab 2008a. It's probably not written in the
% most computationally efficient way possible, but it already seems to work
% fast enough for real-time operation, so I haven't bothered to optimize it
% too much.  At time of this writing, I was able to process a minute of 100
% kHz data in a few seconds, on a fairly standard computer.
%
% The technique works with the following steps (the details can be found in
% the above paper).
% 1. Track the time-varying fundamental frequency of the power-line
%    signal
% 2. Reconstruction of the power-line signal, utilizing the frequency
%    variations calculated in step 1
% 3. Subtraction of the reconstructed signal from the original
% 
% This function takes the following inputs:
%
% data_input           -- the raw data
% fs                   -- the sampling frequency in Hz must be an integer
% NominalHumFreq       -- the frequency of the power lines (i.e. 50 or 60
%                         Hz), which must also be an integer.
% HumDecayTime         -- the "a" parameter as specified in [Cohen et al.
%                         2009]. Typical values of "a" are between 1/8 and
%                         1. Lower values should be used when the harmonic
%                         content and/or the fundamental frequency change
%                         rapidly.
% FrequencyDecayTime   -- the "b" parameter as specified in [Cohen et al.
%                         2009]. Typical values of "b" are between 1/4 and
%                         2. Lower values should be used when the
%                         fundamental frequency changes rapidly.
% PlotTrackedFrequency -- set this to 1 in order to plot the frequency
%                         variations tracked in step 1
% PlotPowerLineSignal  -- set this to 1 in order to plot the reconstructed
%                         power-line signal from step 2.
%
% We provide this code as is, and cannot guarantee that it will always
% work, or work effectively. Power line signals vary widely. In general,
% the steadier/more well behaved is a power line signal, the better this
% will work.
%
% Note that the Humstractor will ignore a segment of the data at the
% beginning and end, corresponding to the time for the impulse train filter
% to reach 10% amplitude, i.e., -ln(0.1)/a. This value sets the
% "MaxNumberOfHumPeriods" variable, and can therefore be changed. Decreasing
% 10% to a lower value will increase the computation time, but slightly
% improve the performance, while also increasing the "ignore" time at the
% beginning and end of the data. So you must therefore pass in data of
% length at least double this ignore time.
% 
% We also note that the sampling frequency specified in fs ought to be
% substantially higher than the highest hum line frequency you wish to
% subtract. We recommend a factor of 5, i.e., if your power line signals
% extend to 10 kHz, pass in data with sampling rate at least 50 kHz. You
% might therefore need to upsample the data before calling this function.
%
% We hope you find this product useful.  Good luck,
% 
%    -- M. B. Cohen
%       Stanford University STAR Laboratory
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% $Id$

%% SOME ERROR CHECKING
warning off all
if mod(NominalHumFreq,1) > 0.001
    error('NominalHumFreq must be an integer. Should you not be using either 50 Hz or 60 Hz?')
end
if mod(fs,1) > 0.001
    error('fs must be an integer, sorry.')
end

%% CHECK LENGTH
if length(data_input) < 2*fs/NominalHumFreq
    error('Not enough data! Feed me more!')
end

%% REORIENTING INTO ROW VECTOR
Reorient = 0;
InputDimensions = size(data_input);
while InputDimensions(1) == 1
    data_input = shiftdim(data_input,1);
    Reorient = Reorient + 1;
    InputDimensions = size(data_input);
end

%% SUBTRACT DC OFFSET
data_input = data_input - mean(data_input);
DataLength = length(data_input)/fs;

%% FREQUENCY ESTIMATION
HarmonicsToEstimate = 1:1:10;
NumberOfPeriodsPerWindow = min(round(FrequencyDecayTime*60),floor(DataLength*60));
WindowSize = ceil(NumberOfPeriodsPerWindow/1)/NominalHumFreq;
StepSize = WindowSize/2;
fs_est = NominalHumFreq*round(3000/NominalHumFreq);
data_tracking = resample(data_input,fs_est,fs);
StepsRemainder = mod(DataLength/StepSize,1);
EstimationStartLocation = StepsRemainder*StepSize/2;
DataLocations = EstimationStartLocation:StepSize:(DataLength-WindowSize);
PhaseMeasurementTimes = DataLocations+StepSize;
FrequencyMeasurementTimes = 0.5*PhaseMeasurementTimes(1:(end-1)) + 0.5*PhaseMeasurementTimes(2:end);

FrequencyWaveformLength = WindowSize*fs_est;
Window = hamming(FrequencyWaveformLength);
HumtrackAmp = zeros(length(DataLocations),length(HarmonicsToEstimate));
HumtrackPhase = zeros(length(DataLocations),length(HarmonicsToEstimate));

%% PHASE TRACKING TECHNIQUE
FrequencyMeasurements = [];
for ii = 1:length(DataLocations)
    DataLocation = DataLocations(ii);
    StartIndex = 1+DataLocations(ii)*fs_est;
    EndIndex = StartIndex + WindowSize*fs_est - 1;    
    data_step = data_tracking(StartIndex:EndIndex);    
    for jj = 1:length(HarmonicsToEstimate)
        data_step_Harmonic = sum(transpose(exp(-i*2*pi*HarmonicsToEstimate(jj)*NominalHumFreq/fs_est*(0:(FrequencyWaveformLength-1)))).*data_step.*Window);
        HumtrackAmp(ii,jj) = abs(data_step_Harmonic);
        HumtrackPhase(ii,jj) = atan(imag(data_step_Harmonic)/real(data_step_Harmonic));
    end
end

%% FREQUENCY DERIVED FROM PHASE DERIVATIVE
Frequency = zeros(length(HumtrackPhase(:,1))-1,length(HarmonicsToEstimate));
Weights = zeros(length(HumtrackPhase(:,1))-1,length(HarmonicsToEstimate));
TotalWeight = 0;
for ii = 1:length(HarmonicsToEstimate)
    Frequency(:,ii) = diff(unwrap(2*HumtrackPhase(:,ii))/4/pi)'/StepSize/HarmonicsToEstimate(ii) + NominalHumFreq;
    Weights(:,ii) = (0.5*HumtrackAmp(1:(end-1),ii) + 0.5*HumtrackAmp(2:end,ii))/HarmonicsToEstimate(ii);
end
WeightedFrequency = Frequency.*Weights;
for ii = 1:length(FrequencyMeasurementTimes)
    [Frequency(ii,:); log10(Weights(ii,:))];
    FrequencyMeasurements = [FrequencyMeasurements; sum(WeightedFrequency(ii,:))/sum(Weights(ii,:))];
end

%% HUM RECONSTRUCTION SETUP
Output = zeros(length(data_input),1);
PowerLineSignal = zeros(length(data_input),1);
HumSteepnessCoefficient = exp(-StepSize/HumDecayTime);
HumGeometricSeriesSum = 1/(1-HumSteepnessCoefficient);
MaxNumberOfHumPeriods = ceil(log10(0.10)/log10(HumSteepnessCoefficient));
FrequencyMeasurementTimes = (StepSize):StepSize:(length(WeightedFrequency)*StepSize);
CurrentIndex = 0;
if length(FrequencyMeasurementTimes) >= 2
    CurrentFrequency = interp1(FrequencyMeasurementTimes, FrequencyMeasurements, CurrentIndex/fs,'linear','extrap');
else
    CurrentFrequency = WeightedFrequency;
end
HumLength = fs/CurrentFrequency;
%if DataLength*fs < (MaxNumberOfHumPeriods+1)*HumLength*2-1
%error('I do not have enough data to effectively track the power-line signal! Feed me more, or shorten the hum decay time.')
%end
CurrentDataPiece = data_input((CurrentIndex+1):(CurrentIndex+HumLength));
Output(CurrentIndex+(1:HumLength)) = CurrentDataPiece;
PowerLineSignal(CurrentIndex+(1:HumLength)) = zeros(1,length(HumLength));
CurrentIndex = CurrentIndex + floor(fs/CurrentFrequency) + 1;

%% HUM RECONSTRUCTION AND SUBTRACTION
KeepGoing = 1;
while KeepGoing == 1
    if length(FrequencyMeasurementTimes) >= 1
        CurrentFrequency = interp1(FrequencyMeasurementTimes, FrequencyMeasurements, CurrentIndex/fs,'linear','extrap');
    else
        CurrentFrequency = FrequencyMeasurements;
    end
    HumLength = (fs/CurrentFrequency);
    CurrentDataPiece = data_input((CurrentIndex+1):(CurrentIndex+HumLength));
    NumberOfPeriodsAhead = min(MaxNumberOfHumPeriods,(length(data_input)-CurrentIndex)/HumLength-1);
    NumberOfPeriodsBehind = min(MaxNumberOfHumPeriods,CurrentIndex/HumLength);
    NumberOfHumPeriods = floor(min(NumberOfPeriodsAhead,NumberOfPeriodsBehind));
    
    if NumberOfHumPeriods >= 1
        ForwardHum = zeros(HumLength,1);
        BackwardHum = zeros(HumLength,1);
        HumWeightSum = 0;
        for ii = 1:NumberOfHumPeriods
            ForwardHum  = ForwardHum  + data_input((CurrentIndex+1+ii*HumLength):(CurrentIndex+(ii+1)*HumLength))*HumSteepnessCoefficient^(ii-1);
            BackwardHum = BackwardHum + data_input((CurrentIndex+1-ii*HumLength):(CurrentIndex-(ii-1)*HumLength))*HumSteepnessCoefficient^(ii-1);
            HumWeightSum = HumWeightSum + HumSteepnessCoefficient^(ii-1);
        end
        WaveformToSubtract = 0.5*(ForwardHum + BackwardHum)/HumWeightSum;
        Output(CurrentIndex+(1:HumLength)) = CurrentDataPiece - WaveformToSubtract;
        PowerLineSignal(CurrentIndex+(1:HumLength)) = WaveformToSubtract;        
    else
        Output(CurrentIndex+(1:HumLength)) = CurrentDataPiece;
        %[CurrentIndex+1 CurrentIndex+HumLength]
    end
    CurrentIndex = CurrentIndex + floor(fs/CurrentFrequency);
    if (CurrentIndex + HumLength + 1) >= length(data_input)
        Output((CurrentIndex+1):end) = data_input((CurrentIndex+1):end);
        KeepGoing = 0;
    end
end

%% REORIENTING FROM ROW VECTOR IF NECESSARY
if Reorient ~= 1
    Output = shiftdim(Output, -Reorient);
end

%% VIEW FREQUENCY TRACKING
if PlotTrackedFrequency == 1
    figure;
    FigureFontSize = 18;

    subplot(4,2,1)
    plot(FrequencyMeasurementTimes,Frequency01H,'Color',[0 0 1])
    grid on
    axis([0 DataLength 1*(NominalHumFreq-2) 1*(NominalHumFreq+2)])
    theAxis = axis;
    Coordinates = [0.01 1.10];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),'Hum first harmonic','FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.90];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(mean(Frequency01H),4),'FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.75];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(std(Frequency01H),2),'FontSize',FigureFontSize,'FontName','Times')
    set(gca,'FontSize',FigureFontSize,'FontName','Times')
    ylabel('Freq','FontSize',FigureFontSize,'FontName','Times')

    subplot(4,2,2)
    plot(FrequencyMeasurementTimes,Frequency03H)
    grid on
    axis([0 DataLength 3*(NominalHumFreq-2) 3*(NominalHumFreq+2)])
    theAxis = axis;
    Coordinates = [0.01 1.10];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),'Hum third harmonic','FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.90];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(mean(Frequency03H/3),4),'FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.75];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(std(Frequency03H/3),2),'FontSize',FigureFontSize,'FontName','Times')
    set(gca,'FontSize',FigureFontSize,'FontName','Times')
    ylabel('Freq','FontSize',FigureFontSize,'FontName','Times')

    subplot(4,2,3)
    plot(FrequencyMeasurementTimes,Frequency05H)
    grid on
    axis([0 DataLength 5*(NominalHumFreq-2) 5*(NominalHumFreq+2)])
    theAxis = axis;
    Coordinates = [0.01 1.10];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),'Hum fifth harmonic','FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.90];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(mean(Frequency05H/5),4),'FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.75];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(std(Frequency05H/5),2),'FontSize',FigureFontSize,'FontName','Times')
    set(gca,'FontSize',FigureFontSize,'FontName','Times')
    ylabel('Freq','FontSize',FigureFontSize,'FontName','Times')

    subplot(4,2,4)
    plot(FrequencyMeasurementTimes,Frequency07H)
    grid on
    axis([0 DataLength 7*(NominalHumFreq-2) 7*(NominalHumFreq+2)])
    theAxis = axis;
    Coordinates = [0.01 1.10];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),'Hum seventh harmonic','FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.90];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(mean(Frequency07H/7),4),'FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.75];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(std(Frequency07H/7),2),'FontSize',FigureFontSize,'FontName','Times')
    set(gca,'FontSize',FigureFontSize,'FontName','Times')
    ylabel('Freq','FontSize',FigureFontSize,'FontName','Times')

    subplot(4,2,5)
    plot(FrequencyMeasurementTimes,Frequency09H)
    grid on
    axis([0 DataLength 9*(NominalHumFreq-2) 9*(NominalHumFreq+2)])
    theAxis = axis;
    Coordinates = [0.01 1.10];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),'Hum ninth harmonic','FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.90];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(mean(Frequency09H/9),4),'FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.75];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(std(Frequency09H/9),2),'FontSize',FigureFontSize,'FontName','Times')
    set(gca,'FontSize',FigureFontSize,'FontName','Times')
    ylabel('Freq','FontSize',FigureFontSize,'FontName','Times')
    
    subplot(4,2,6)
    plot(FrequencyMeasurementTimes,Frequency11H)
    grid on
    axis([0 DataLength 11*(NominalHumFreq-2) 11*(NominalHumFreq+2)])
    theAxis = axis;
    Coordinates = [0.01 1.10];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),'Hum 11th harmonic','FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.90];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(mean(Frequency11H/11),4),'FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.75];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(std(Frequency11H/11),2),'FontSize',FigureFontSize,'FontName','Times')
    set(gca,'FontSize',FigureFontSize,'FontName','Times')
    ylabel('Freq','FontSize',FigureFontSize,'FontName','Times')
    
    subplot(4,2,7)
    plot(FrequencyMeasurementTimes,Frequency13H)
    grid on
    axis([0 DataLength 13*(NominalHumFreq-2) 13*(NominalHumFreq+2)])
    theAxis = axis;
    Coordinates = [0.01 1.10];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),'Hum 13th harmonic','FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.90];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(mean(Frequency13H/13),4),'FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.75];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(std(Frequency13H/13),2),'FontSize',FigureFontSize,'FontName','Times')
    set(gca,'FontSize',FigureFontSize,'FontName','Times')
    ylabel('Freq','FontSize',FigureFontSize,'FontName','Times')    

    subplot(4,2,8)
    hold on
    plot(FrequencyMeasurementTimes,WeightedFrequency,'Color',[0 0 1])
    plot(FrequencyMeasurementTimes,WeightedFrequency,'Color',[1 0 0],'LineWidth',2.5)
    hold off
    grid on
    axis([0 DataLength 1*58 1*62])
    theAxis = axis;
    Coordinates = [0.01 1.10];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),'Hum weighted average','FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.90];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(AverageFrequency,4),'FontSize',FigureFontSize,'FontName','Times')
    Coordinates = [0.01 0.75];text(Coordinates(1)*(theAxis(2)-theAxis(1))+theAxis(1), Coordinates(2)*(theAxis(4)-theAxis(3))+theAxis(3),num2str(FrequencyJitter,2),'FontSize',FigureFontSize,'FontName','Times')
    set(gca,'FontSize',FigureFontSize,'FontName','Times')
    ylabel('Freq','FontSize',FigureFontSize,'FontName','Times')
end

%% VIEW POWER-LINE SIGNAL
if PlotPowerLineSignal == 1
    figure;
    FigureFontSize = 18;    
    
    MaxFreq = 10E3;
    PowerLineResampled = resample(PowerLineSignal,MaxFreq,fs);
    WindowLength = round(0.05*MaxFreq);
    NFFT = 2*WindowLength;
    Overlap = WindowLength*(3/4);
    [B, F, T] = specgram(PowerLineResampled/WindowLength*4,NFFT,MaxFreq, WindowLength, Overlap);
    imagesc(T, F/1000, 20*log10(abs(B)))
    axis xy;
    caxis([max(max(abs(B)))-80 max(max(abs(B)))])
    h = colorbar;
    set(get(h,'title'),'string','dB-rel','FontSize',FigureFontSize,'FontName','Garamond');    
    set(gca,'FontSize',FigureFontSize,'FontName','Times')    
    ylabel('Frequency (kHz)','FontSize',FigureFontSize,'FontName','Times')    
    xlabel('Time (seconds)','FontSize',FigureFontSize,'FontName','Times')        
    title('Power-line signal (\DeltaF = 20 Hz)','FontSize',FigureFontSize,'FontName','Times')            
end

%% A HELPER FUNCTION TO APPROXIMATE THE DERIVATIVE WITHOUT DECREASING THE LENGTH
function Out = Derivative(In)

DiffOut = diff(In);
Out = 0.5*([0 DiffOut] + [DiffOut 0]);
