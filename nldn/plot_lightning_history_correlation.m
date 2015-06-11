% function plot_lightning_history_correlation
% A little function to see how correlated a given hour of lightning is with
% some hour previous to it

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$
clear;

load ~/temp/nldn_epoch_output.mat us_flashes idx_hiss

figure;
for kk = 1:4
	h = 4^kk;
	subplot(2, 2, kk);
	scatter(us_flashes((1 + h):end), us_flashes(1:(end-h)), '.');
	grid on;
	[rho, pval] = corr(us_flashes((1 + h):end), us_flashes(1:(end-h)));
	title(sprintf('h = %d hrs, \\rho=%0.2f, P=%0.2f', h, rho, pval));
	
	if kk == 1 || kk == 3
		ylabel('prev. hr.');
	end
	if kk == 3 || kk == 4
		xlabel('curr. hr.');
	end
end
increase_font(gcf, 12);
