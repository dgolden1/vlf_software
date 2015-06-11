function[result] = buildtree(numlevels)

% BUILDTREE  Build the full wavelet packet tree, numlevels deep.
%
%   [result] = BUILDTREE(numlevels)
%
%   This function generates a full binary tree, numlevels deep, for use
%   with the function wavelet_packet_decomp.  

if (numlevels == 0)
  result = [];
else
  for i=[1:1:numlevels-1]
    for j=[1:1:2^(i-1)]
      result(2^(i-1) + j - 1,1) = (2^(i)) + 2*(j-1);
      result(2^(i-1) + j - 1,2) = (2^(i)) + 2*(j-1) + 1;
    end;
  end;

  %# Finish up the tail.
  for j=[1:1:2^(numlevels-1)]
    result(2^(numlevels-1) + (j-1),1) = 0;
    result(2^(numlevels-1) + (j-1),2) = 0;
  end;
end;
