function color = assign_color(min_val, max_val, value, color_map)
% Get a color from the colormap (jet by default)

if ~exist('color_map', 'var'), color_map = 'jet'; end

eval(sprintf('c = %s;', color_map));
c_len = size(c, 1);

idx = (value - min_val)/(max_val - min_val) * (c_len - 1) + 1;

color = interp1((1:64).', c, idx);
