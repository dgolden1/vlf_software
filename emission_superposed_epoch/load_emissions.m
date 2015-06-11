function events_out = load_emissions
% Cache events because loading them takes forever

persistent events

if isempty(events)
  emission_db_filename = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/databases/auto_chorus_hiss_db_em_char_all_reprocessed.mat';
  load(emission_db_filename);
end

events_out = events;
