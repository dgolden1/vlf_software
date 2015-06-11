function cdf_list_vars(filename)
% List variables in a CDF file
% 
% cdf_list_vars(filename)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2011
% $Id$

info = cdfinfo(filename);

for kk = 1:size(info.Variables, 1)
  var_length = info.Variables{kk, 3};
  if var_length == 0
    continue;
  end
  
  var_name = info.Variables{kk, 1};
  var_dim = info.Variables{kk, 2};
  assert(var_dim(2) == 1);
  
  fprintf('%-20s: %dx%d\n', var_name, var_dim(1), var_dim(2)*var_length);
end
