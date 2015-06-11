function determine_tweek_params
% Function to manually analzye a bunch of tweeks
% 
% As of revision 557 (2009-10-27), the role of this function has changed to
% analyze false positives in general, not just tweeks

% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id$

%% Setup
input_dir = '/media/vlf-alexandria-array/data_products/dgolden/burstiness';
output_dir = '/home/dgolden/temp/burstiness/tweeks';
db_file = '/home/dgolden/vlf/case_studies/chorus_hiss_detection/auto_chorus_hiss_db.mat';

%% Load events
load(db_file, 'events');

%% Parse events
% There are a lot of false positives at 0400 UT
% The chorus peak is at 1000 UT
% The hiss peak is at 1900 UT
events = events(([events.start_datenum] >= datenum([2003 02 01 0 0 0]) & [events.start_datenum] < datenum([2003 03 01 0 0 0]) | ...
              [events.start_datenum] >= datenum([2003 09 01 0 0 0]) & [events.start_datenum] < datenum([2003 10 01 0 0 0])) ...
         & ...
                (fpart([events.start_datenum]) >= 4/24 & fpart([events.start_datenum]) < 5/24 | ...
           fpart([events.start_datenum]) >= 10/24 & fpart([events.start_datenum]) < 11/24 | ...
           fpart([events.start_datenum]) >= 19/24 & fpart([events.start_datenum]) < 20/24));

% Delete events that occur on the same day as another event for simplicity.
[b, m, n] = unique([events.start_datenum].');
A = accumarray(n(:), ones(size(n(:))));
m(A > 1) = [];
events = events(m);

%% Copy PNGs and create spreadsheet template
% user_entry = input(sprintf('Delete all PNG files from %s? Y/N: ', output_dir), 's');
% if ~strcmpi(user_entry, 'Y')
%   disp('Aborting...');
%   return;
% end

disp(sprintf('Deleting all PNG files from %s... ', output_dir));
delete(fullfile(output_dir, '*.png'));

% disp(sprintf('\nDate\tTweek?'));
events_t_mask = true(size(events));
for kk = 1:length(events)
  this_dirname = fullfile(input_dir, sprintf('auto_chorus_hiss_%s', datestr(events(kk).start_datenum, 'mm_dd')));
  this_filenames = sprintf('PA_%s*.png', datestr(events(kk).start_datenum, 'yyyy_mm_ddTHHMM'));
%   disp(sprintf('%s\tTRUE', datestr(events(kk).start_datenum)));
  d = dir(fullfile(this_dirname, this_filenames));
  if length(d) ~= 1
    warning('%d files matching pattern %s', length(d), this_filenames);
  end
  if length(d) >= 1
    disp(sprintf('Copying %s...', this_filenames));
    copyfile(fullfile(this_dirname, this_filenames), output_dir);
  else
    events_t_mask(kk) = false;
  end
end
events = events(events_t_mask);

disp(sprintf('Copied %d files', length(events)));

%% User section
% disp('Copy dates into two columns of spreadsheet');
% disp(sprintf('Look at plots in %s', output_dir));
% disp('If it''s not a tweek, change to FALSE');
% disp('Paste TRUE/FALSE column into Matlab as A_pastespecial');
% disp('Then dbcont');

disp(sprintf('\nDelete PNGs from %s that are false positives emissions', output_dir));
disp(sprintf('Then press any key\n'));
% pause;

%% If the user deleted a PNG, assuming it's a false positive
G = cell(size(events));
disp(sprintf('\nDate\tEmission?'));
for kk = 1:length(events)
  this_png_name = sprintf('PA_%s_*_002_cleaned_burst_norm.png', ...
    datestr(events(kk).start_datenum, 'yyyy_mm_ddTHHMM'));
  d = dir(fullfile(output_dir, this_png_name));
  if isempty(d)
    G{kk} = '[false p]';
    disp(sprintf('%s\tFALSE', datestr(events(kk).start_datenum)));
  else
    assert(length(d) == 1);
    G{kk} = '[true p]';
    disp(sprintf('%s\tTRUE', datestr(events(kk).start_datenum)));
  end
end

%% Determine which event is an emission or tweek based on A_pastespecial
disp('dbstop here to paste in a spreadsheet of TRUE/FALSE values');
if exist('A_pastespecial', 'var')
%   b_true_pos = cellfun(@(x) strcmp(x, 'TRUE'), A_pastespecial);
%   b_false_pos = cellfun(@(x) strcmp(x, 'FALSE'), A_pastespecial);
%   b_maybe_pos = cellfun(@(x) strcmp(x, 'MAYBE'), A_pastespecial);
  G = cell(size(A_pastespecial));
  for kk = 1:length(A_pastespecial)
    switch A_pastespecial{kk}
      case 'TRUE'
        G{kk} = '[true]';
      case 'FALSE'
        G{kk} = '[false]';
      case 'MAYBE'
        G{kk} = '[maybe]';
      otherwise
        error('Invalid entry in A_pastespecial{%d}: %s', kk, A_pastespecial{kk});
    end
%     if b_true_pos(kk)
%       G{kk} = '[false p]';
%     else
%       G{kk} = '[true p]';
%     end
  end
else
  b_true_pos = strcmp(G, '[true p]');
end

%% Plot
sferic_params = [events.sferic_params];

sfigure(1); clf;
pos = get(gcf, 'position');
% if pos(3)/pos(4) ~= 2 + 2/3
%   figure_squish;
%   figure_squish(gcf, 0.5, 1);
% end

f = fieldnames(sferic_params(1));
for kk = 1:length(f)
  subplot(1, length(f), kk);
  boxplot([sferic_params.(f{kk})], G);
  grid on;
  ylabel(strrep(f{kk}, '_', '\_'));
end
em_types = sprintf('%d true positives, %d false positives, %d unknown', ...
  sum(cellfun(@(x) strcmp(x, 'TRUE'), A_pastespecial)), ...
  sum(cellfun(@(x) strcmp(x, 'FALSE'), A_pastespecial)), ...
  sum(cellfun(@(x) strcmp(x, 'MAYBE'), A_pastespecial)));

title(sprintf('%s to %s; %s', datestr(floor(events(1).start_datenum)), datestr(ceil(events(end).start_datenum)), em_types));

%% Display results
disp(em_types);
b_true_pos = cellfun(@(x) strcmp(x, 'TRUE'), A_pastespecial);
b_false_pos = cellfun(@(x) strcmp(x, 'FALSE'), A_pastespecial);
b_maybe_pos = cellfun(@(x) strcmp(x, 'MAYBE'), A_pastespecial);

sferic_params = [events.sferic_params];
vcorr = [sferic_params.vcorr];

disp(sprintf('True Positives 95%% confidence interval: [%0.2f %0.2f]', mean(vcorr(b_true_pos)) + [-1 1]*1.96*std(vcorr(b_true_pos))));
disp(sprintf('False Positives 95%% confidence interval: [%0.2f %0.2f]', mean(vcorr(b_false_pos)) + [-1 1]*1.96*std(vcorr(b_false_pos))));
disp(sprintf('Maybe Positives 95%% confidence interval: [%0.2f %0.2f]', mean(vcorr(b_maybe_pos)) + [-1 1]*1.96*std(vcorr(b_maybe_pos))));

disp('');
