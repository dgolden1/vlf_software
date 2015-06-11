function [epoch, symh, symd, asyh, asyd] = asy_sym_read(filename)
% Function to parse ASY/SYM data from the Kyoto web site
% [epoch, symh, symd, asyh, asyd] = asy_sym_read(filename)
% 
% Acquire data from here: http://wdc.kugi.kyoto-u.ac.jp/aeasy/index.html
% Data format: http://wdc.kugi.kyoto-u.ac.jp/aeasy/format/asyformat.html

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Open text file
[fid, message] = fopen(filename);
if fid == -1
	error(message);
end



%% Parse the text file
C = textscan(fid, ['%*6c %*5c%02f%02f%02f%c%02f%3c%*10c ' ...
                   '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' ...
                   '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' ...
                   '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' ...
                   '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' ...
                   '%f']);

year = 1900 + C{1} + 100*(C{1} < 50); % 19-- if year is 50 or above, 20-- if year is 49 or below
month = C{2};
day = C{3};
component = C{4};
hour = C{5};
idx_name = num2cell(C{6}, 2);
vals = cell2mat(C(7:66));
hourly_mean = C{67};

[datenum_remainder, datenum_minute] = ndgrid(datenum([year month day hour zeros(length(year), 2)]), (0:59)/1440);
epoch_full = datenum_remainder + datenum_minute;

idx_symh = component == 'H' & strcmp(idx_name, 'SYM');
idx_symd = component == 'D' & strcmp(idx_name, 'SYM');
idx_asyh = component == 'H' & strcmp(idx_name, 'ASY');
idx_asyd = component == 'D' & strcmp(idx_name, 'ASY');

epoch = flatten(epoch_full(idx_symh, :).');

% Make sure epochs for each index are the same
assert(all(epoch == flatten(epoch_full(idx_symd, :).')));
assert(all(epoch == flatten(epoch_full(idx_asyh, :).')));
assert(all(epoch == flatten(epoch_full(idx_asyd, :).')));

symh = flatten(vals(idx_symh, :).');
symd = flatten(vals(idx_symd, :).');
asyh = flatten(vals(idx_asyh, :).');
asyd = flatten(vals(idx_asyd, :).');
