function varstruct = matLoadExcept(fileID,excludeVariables)

% varstruct = matLoadExcept(fileID,excludeVariables)
%
% Loads variables to the calling workspace. Arguments specify
% the file name or open file ID and a cell array of strings of the
% variables to exclude from loading.
% 
% If varstruct is given as output, the variables will be returned in
% that struct, not to the calling workspace

% BUGS: SEE matGetVariables for significant limitations.
%
% by cPbL@alum.mit.edu and Robert M Barrington Leigh, 2000 August 23
% 
% Modified by Daniel Golden (dgolden1 at stanford.edu) August 2009
% 
% $Id$


if ~exist('fileID','var') || isempty(fileID)% FOR DEBUGGING
   [filename,pathname] = uigetfile('.mat', 'Choose a .mat file to open');
   fileID=fullfile(pathname, filename);
end

[varNames, varTypes, varOffsets, varDimensions, varSizes] = matGetVarInfo(fileID);

if ~iscell(varNames) && isnan(varNames)
   error('Cannot read non version 4 .mat file.');
end

getVariables=setdiff(varNames,excludeVariables)';
for i = 1:length(getVariables)
  % We already know the offset of this variable's data, which speeds up the
  % execution time of matGetVariable
  this_var_name = getVariables{i};
  var_idx = strcmp(varNames, this_var_name);
  known_var_data = struct('varType', varTypes{var_idx}, ...
    'varRows', varDimensions(var_idx, 1), 'varCols', varDimensions(var_idx, 2), ...
    'varSize', varSizes(var_idx), 'varOffset', varOffsets(var_idx));
  var_val = matGetVariable(fileID, getVariables{i}, [], [], known_var_data);
  
	if nargout < 1
		assignin('caller',getVariables{i}, var_val)
	else
		varstruct.(getVariables{i}) = var_val;
	end
end


