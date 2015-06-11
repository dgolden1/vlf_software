function redo_emission_stats
% Script to recalculate emission amplitude and burstiness for all events in
% the emission database

% By Daniel Golden (dgolden1 at stanford dot edu) February 2010
% $Id$

%% Setup
db_dir = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/databases';

%% Parallel
PARALLEL = true;

if ~PARALLEL
  warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
  matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
  matlabpool('close');
end

%% Process
for year = 1:11
  t_start = now;
  
  events = [];
%   db_filename = fullfile(db_dir, sprintf('auto_chorus_hiss_db_20%02d.mat', year-1));
%   db_filename = fullfile(db_dir, sprintf('auto_chorus_hiss_db_em_char_20%02d.mat', year-1));
  db_filename = fullfile(db_dir, sprintf('auto_chorus_hiss_db_20%02d_nn_train.mat', year-1));
%   db_filename = fullfile(db_dir, sprintf('auto_chorus_hiss_db_em_20%02d.mat', year-1));

  load(db_filename, 'events');
  events_original = events; % For debugging
  fprintf('Loaded %s (%d events) in %s\n', just_filename(db_filename), length(events), time_elapsed(t_start, now));

  b_valid = true(size(events));
  warning('Parfor disabled!');
  for kk = 1:length(events)
%   parfor kk = 1:length(events)
    try
      ec = get_emission_stats_post_facto(events(kk).start_datenum, events(kk).f_lc, events(kk).f_uc);
      fprintf('%d of %d Old: %0.2f, New: %0.2f, Difference: %0.3f\n', ...
        kk, length(events), events(kk).ec.time_to_term, ec.time_to_term, ...
        angledist(events(kk).ec.time_to_term*2*pi, ec.time_to_term*2*pi, 'rad')/(2*pi));
      events(kk).ec = ec;
    catch er
      fprintf('Deleted event from %s: %s\n', datestr(events(kk).start_datenum), er.message);
      b_valid(kk) = false;
    end
  end

  events(~b_valid) = [];

  save(db_filename, 'events');
  fprintf('Processed %s in %s (deleted %d invalid files)\n', just_filename(db_filename), time_elapsed(t_start, now), sum(~b_valid));
end
