function idx_darkness = find_terminator_cached(start_datenum, end_datenum, epoch)
% A stupid function which caches the find-terminator function since it
% takes forever

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

%% Setup
persistent last_start_datenum last_end_datenum last_epoch last_idx_darkness

lat = -64.77;
lon = -64.05;
palmer_mlt_offset = -4; % MLT at UTC midnight, hours

%% Run
if ~isempty(last_start_datenum) && start_datenum == last_start_datenum && ...
    end_datenum == last_end_datenum && all(last_epoch == epoch)
  idx_darkness = last_idx_darkness;
  return;
end

% Determine dawn and dusk times in Palmer MLT
term_epoch = start_datenum:7:end_datenum;
if term_epoch(end) ~= end_datenum, term_epoch(end+1) = end_datenum; end
for kk = 1:length(term_epoch)
  [dawn_datenum(kk), dusk_datenum(kk)] = find_terminator(lat, lon, term_epoch(kk));
end

dawn_mlt = mod(angle(interp1(term_epoch, exp(j*fpart(dawn_datenum + palmer_mlt_offset/24)*2*pi), epoch))/(2*pi), 1);
dusk_mlt = mod(angle(interp1(term_epoch, exp(j*fpart(dusk_datenum + palmer_mlt_offset/24)*2*pi), epoch))/(2*pi), 1);

idx_darkness = fpart(epoch + palmer_mlt_offset/24) < dawn_mlt | fpart(epoch + palmer_mlt_offset/24) > dusk_mlt;
