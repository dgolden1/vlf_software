% Program to plot lots of histograms for a certain day of hiss near
% Palmer's conjugate

% $Id$

close all;
clear;

addpath('/home/dgolden/vlf/vlf_software/dgolden/nldn');

load ~/temp/junk.mat

dist_lim = 500:100:2000;
ampl_lim = 10:15:100;

% ampl = abs(nldn.nstrokes.*nldn.peakcur);
ampl = abs(nldn.peakcur);

[Ampl_lim, Dist_lim] = meshgrid(ampl_lim, dist_lim);

n_full = zeros(numel(Dist_lim), 24);
edges = [(0:23)/24 Inf];
for kk = 1:numel(Dist_lim)
	idx = find(nldn.date >= start_datenum & nldn.date < end_datenum & dist < Dist_lim(kk) & ampl > Ampl_lim(kk));
	nldn_expanded = expand_nldn_low_res(nldn, idx);
	n = histc(fpart(nldn_expanded.date), edges);
	n = n(:);
	n = [n(1:end-2); (n(end-1)+n(end))];
	n_full(kk, :) = n;
end

figure;
imagesc((0.5:23.5)/24, 1:numel(Dist_lim), n_full);
axis xy;
set(gca, 'xtick', (0:24)/24);
datetick('x', 'keepticks');
load jet_with_white;
colormap(jet_with_white);
grid on;
c = colorbar;
set(get(c, 'ylabel'), 'string', 'Num strokes');
xlabel('Feb 10, 2003');
ylabel('Thresh idx');
