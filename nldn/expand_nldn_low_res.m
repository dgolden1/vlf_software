function nldn_out = expand_nldn_low_res(nldn_in, idx)
% nldn_out = expand_nldn_low_res(nldn_in, idx)
% Function to expand out the NLDN low-res data into an estimate of NLDN
% high-res data using the flash multiplicity (nstrokes)
% 
% Include idx as an index into nldn_in to parse out certain values

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Parse out certain indexes if required
if exist('idx', 'var')
	names = fieldnames(nldn_in);
	for kk = 1:length(names)
		nldn_in.(names{kk}) = nldn_in.(names{kk})(idx);
	end
end

%% Expand multiplicity values into separate strokes
nstrokes_in = length(nldn_in.date);
total_strokes = sum(nldn_in.nstrokes);

nldn_out.date = zeros(total_strokes, 1);
nldn_out.g = false(total_strokes, 1);
nldn_out.lat = zeros(total_strokes, 1);
nldn_out.lon = zeros(total_strokes, 1);
nldn_out.nstrokes = ones(total_strokes, 1);
nldn_out.peakcur = zeros(total_strokes, 1);


orig_pos = 1;
pos = 1;
while orig_pos < nstrokes_in
	pos_out_range = (pos:(pos + nldn_in.nstrokes(orig_pos) - 1));

	nldn_out.date(pos_out_range) = nldn_in.date(orig_pos);
	nldn_out.g(pos_out_range) = nldn_in.g(orig_pos);
	nldn_out.lat(pos_out_range) = nldn_in.lat(orig_pos);
	nldn_out.lon(pos_out_range) = nldn_in.lon(orig_pos);
	nldn_out.peakcur(pos_out_range) = nldn_in.peakcur(orig_pos)*2.^-((1:nldn_in.nstrokes(orig_pos)) - 1); % Each return stroke has 1/2 the amplitude of the previous one
	
	pos = pos + nldn_in.nstrokes(orig_pos);
	orig_pos = orig_pos + 1;
end
