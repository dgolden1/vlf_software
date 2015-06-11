function h_boxes = neg_draw_emission_boxes(h_ax, emission_list, h_boxes, first_box)
% h_boxes = neg_draw_emission_boxes(h_ax, emission_list, h_boxes, first_box)
% Draw boxes around emissions; highlight the "first_box" emission

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

%% Setup
if ~exist('first_box', 'var') || isempty(first_box)
	first_box = 1;
end

	%% Remove existing boxes
if ~exist('h_boxes', 'var')
	h_boxes = [];
end

for kk = 1:length(h_boxes)
	if ishandle(h_boxes(kk).r)
		delete(h_boxes(kk).r);
	end
	if ishandle(h_boxes(kk).t)
		delete(h_boxes(kk).t);
	end
end

h_boxes = struct('r', {}, 't', {});

%% Draw new boxes
if length(emission_list) >= 1
	color = [1 0.25 0.25]; linewidth = 2;
	for kk = 1:length(emission_list)
		if kk == first_box, continue; end

		h_boxes(end+1) = neg_mark_single_emission(emission_list(kk), h_ax, color, linewidth, kk);
	end
	color = [1 0 0]; linewidth = 4;
	h_boxes(end+1) = neg_mark_single_emission(emission_list(first_box), h_ax, color, linewidth, first_box);
end
