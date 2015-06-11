function [database_filename, summary_plot_directory, cleaned_data_directory, initial_datenum] = emission_db_corrector_defaults
% Function to set default values for emission_db_corrector

% By Daniel Golden (dgolden1 at stanford dot edu) November 2009
% $Id$

database_filename = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/databases/auto_chorus_hiss_db_em_char_2000.mat';
summary_plot_directory = '/media/scott/user_data/dgolden/synoptic_summary_plots';
cleaned_data_directory = '/media/scott/user_data/dgolden/palmer_bb_cleaned';
initial_datenum = datenum([2000 05 06 00 05 00]);
