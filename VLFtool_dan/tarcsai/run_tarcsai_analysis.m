function tarcsai_result = run_tarcsai_analysis(wh, sferic_time, timev, freqv, model, filename, pathname)
% run_tarcsai_analysis(wh, sferic_time, timev, freqv, model)
% Run Tarcsai analysis with appropriate error checking

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Run analysis
if ~exist('model', 'var') || isempty(model)
	tarcsai_result = tarcsai(timev',freqv');
else
	tarcsai_result = tarcsai(timev',freqv', model);
end


%% Combine with Whistler information and the Tarcsai result into one fat struct
tarcsai_result = whTarcsaiCombineWhTarcsaiStructs(tarcsai_result, wh, sferic_time);


%% Make sure the result is valid
% Sometimes the computed sferic time is after the start of the whistler
% trace, which is physically impossible. I'm trying to figure out why
% this happens. --DIG Sep 4, 2007
if tarcsai_result.sferic_calc >= min(wh.time)
   error('TARCSAI:overrunSferic', ...
       'Computed sferic time is after start of sferic. Tarcsai results are bunk.');
end
% warning('overrunSferic error is disabled.');

% Check for abnormally large standard deviations
big_error = 0.33;
big_error_percent_str = num2str(round(big_error*100), '%d');
errormsg = '';
if tarcsai_result.sigma_L > big_error*tarcsai_result.L
	errormsg = [errormsg sprintf('L uncertainty (%0.2f) is more than %s%% of L (%0.2f)\n', ...
		tarcsai_result.sigma_L, big_error_percent_str, tarcsai_result.L)];
end
if tarcsai_result.sigma_neq > big_error*tarcsai_result.neq
	errormsg = [errormsg sprintf('neq uncertainty (%1.2e) is more than %s%% of neq (%1.2e)\n', ...
		tarcsai_result.sigma_neq, big_error_percent_str, tarcsai_result.neq)];
end

if ~isempty(errormsg)
	error('TARCSAI:lowConfidence',errormsg);
end
% warning('Low confidence error is disabled');
	
	
%% Save file
% save the results in a mat file with the same name as the whistler
% file with '_tarcsai' added to the end
filename = [filename(1:end-10),'_tarcsai_',filename(end-5:end-4),'.mat'];
save( fullfile(pathname, filename), 'tarcsai_result');
disp( ['wrote ' fullfile(pathname, filename)] );
