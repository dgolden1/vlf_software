function vec = str_to_datevec(str)
% Return a string of the form [yyyy mm dd HH MM SS] as a datevec

% By Daniel Golden (dgolden1 at stanford dot edu) Nov 7, 2007
% $Id$

assert(str(1) == '[');
assert(str(end) == ']');

[vec(1), vec(2), vec(3), vec(4), vec(5)] = strread(str(2:end-1), '%d %d %d %d %d');
