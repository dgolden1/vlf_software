function sp_plot_db(start_datenum, end_datenum)
% Plot the dates of the chorus and hiss database

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

if ~exist('start_datenum', 'var') || isempty(start_datenum)
  start_datenum = 0;
end
if ~exist('end_datenum', 'var') || isempty(end_datenum)
  end_datenum = inf;
end

load /home/dgolden/vlf/case_studies/southpole_emissions/sp_event_db.mat

chorus_dates = cell2mat(db_chorus.keys());
chorus_dates = chorus_dates(chorus_dates >= start_datenum & chorus_dates < end_datenum);
hiss_dates = cell2mat(db_hiss.keys());
hiss_dates = hiss_dates(hiss_dates >= start_datenum & hiss_dates < end_datenum);

[start_year, ~] = datevec(min([chorus_dates, hiss_dates]));
[end_year, ~] = datevec(max([chorus_dates, hiss_dates]));

edges = datenum([start_year 01 01 0 0 0]):datenum([end_year+1 01 01 0 0 0]);

n_chorus = histc(chorus_dates, edges);
n_hiss = histc(hiss_dates, edges);

figure;
s(1) = subplot(2, 1, 1);
bar(edges, n_chorus, 1);
grid on;
datetick2('x');
ylabel('Chorus');

s(2) = subplot(2, 1, 2);
bar(edges, n_hiss, 1);
grid on;
datetick2('x');
ylabel('Hiss');

linkaxes(s);
zoom xon
