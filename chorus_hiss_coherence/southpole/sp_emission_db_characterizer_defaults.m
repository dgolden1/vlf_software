function [database_filename, cleaned_data_directory, spec_dir, yyyymmdd] = sp_emission_db_characterizer_defaults
% Function to set default values for emission_db_characterizer

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id$

database_filename = fullfile(danmatlabroot, 'vlf', 'chorus_hiss_coherence', 'southpole', 'sp_event_db.mat');

% cleaned_data_directory = '/home/dgolden/vlf/case_studies/southpole_emissions/log_specs';
cleaned_data_directory = fullfile(scottdataroot, 'user_data', 'dgolden', 'southpole_bb_cleaned');

spec_dir = fullfile(scottdataroot, 'user_data', 'dgolden', 'southpole_bb_cleaned', 'southpole_log_specs');

yyyymmdd = '2002-01-02';
