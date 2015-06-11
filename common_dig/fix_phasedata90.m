function output_phase = fix_phasedata90(phase_data_degrees, averaging_length)

x = exp(sqrt(-1)*phase_data_degrees*4/180*pi);
N = averaging_length;
b = 1/sqrt(N)*ones(1,N);
y = fftfilt(b,x);y = fftfilt(b,y(end:-1:1));y = y(end:-1:1); % This is a quick implementation of filtfilt using fftfilt instead of filter
output_phase = (phase_data_degrees-(round(mod(phase_data_degrees/180*pi-unwrap(angle(y))/4,2*pi)*180/pi/90)*90));
temp = mod(output_phase(1),90);
output_phase = output_phase-output_phase(1)+temp;
output_phase = mod(output_phase,360);
s = find(output_phase>= 180);
output_phase(s) = output_phase(s)-360;

% begin90 = 1
% output_phase = zeros(1,length(phase_data_degrees));
% output_phase(1) = phase_data_degrees(1);
% for ii = 2:length(phase_data_degrees)
%     output_phase(ii) = phase_data_degrees(ii);
%     if output_phase(ii) - output_phase(ii-1) > 45
%         output_phase(11) = output_phase(ii) - 90;
%     end
%     if output_phase(ii) - output_phase(ii-1) > 45
%         output_phase(11) = output_phase(ii) - 90;
%     end    
%     if output_phase(ii) - output_phase(ii-1) > 45
%         output_phase(11) = output_phase(ii) - 90;
%     end
%     if output_phase(ii) - output_phase(ii-1) > 45
%         output_phase(11) = output_phase(ii) - 90;
%     end        
%     if output_phase(ii) - output_phase(ii-1) < -45
%         output_phase(11) = output_phase(ii) + 90;
%     end
%     if output_phase(ii) - output_phase(ii-1) < -45
%         output_phase(11) = output_phase(ii) + 90;
%     end
%     if output_phase(ii) - output_phase(ii-1) < -45
%         output_phase(11) = output_phase(ii) + 90;
%     end
%     if output_phase(ii) - output_phase(ii-1) < -45
%         output_phase(11) = output_phase(ii) + 90;
%     end        
%     if abs(output_phase(ii) - output_phase(ii-1)) > 45
%         [int32(ii) output_phase(ii) output_phase(ii-1)]
%     end
% end
