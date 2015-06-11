function emission_list = neg_access_emission_list(filename, emission, str_add_rem)
% emission_list = neg_access_emission_list(filename, emission, str_add_rem)
% Function to access the emission list for a given data file.
% 
% INPUTS
% filename: filename of the BROADBAND DATA FILE (not the emission list)
% emission: an emission to either add or delete from the emission list (may
%  be blank for no change). emission is a struct with the following fields:
%  t_start
%  t_end
%  f_lc
%  f_uc
%  confidence
%  em_type (em_type is itself a struct with three boolean fields: 'chorus',
%  'hiss' and 'corruption'.)
% str_add_rem: if emission is specified and str_add_rem is 'add', that
%  emission will be added; if emission is specified and str_add_rem is
%  'rem', that emission will be deleted.
% 
% OUTPUTS
% emission_list: the updated emission_list (array of emission structs)

%% Load emission database
[pathstr, name, ext] = fileparts(filename);
em_filename = fullfile(pathstr, [name '.dat']);

if exist(em_filename, 'file')
	load('-mat', em_filename);
else
	emission_list = [];
end

if ~exist('emission', 'var') || isempty(emission)
	return;
else
	if ~exist('str_add_rem', 'var') || isempty(str_add_rem)
		error('If emission is specified, str_add_rem must also be specified');
	end
end

%% Add emission
n = length(emission_list)+1;
switch str_add_rem
	case 'add'
		emission_list(n).t_start = emission.t_start;
		emission_list(n).t_end = emission.t_end;
		emission_list(n).f_lc = emission.f_lc;
		emission_list(n).f_uc = emission.f_uc;
		emission_list(n).confidence = emission.confidence;
		emission_list(n).em_type = emission.em_type;
%% Delete emission
	case 'rem'
		em_i = arrayfun(@(x) isequal(x, emission), emission_list);
		if ~any(em_i)
			error('Emission to be deleted not found in database!');
		elseif sum(em_i) > 1
			error('More than one emission matching emission to be deleted found in database!');
		else
			emission_list(em_i) = [];
		end
	otherwise
		error('Invalid value for str_add_rem (''%s'')', str_add_rem);
end

if isempty(emission_list)
	delete(em_filename);
	disp(sprintf('No more emissions; deleted %s', just_filename(em_filename)));
else
	save(em_filename, 'emission_list');
	disp(sprintf('Saved %s', just_filename(em_filename)));
end
