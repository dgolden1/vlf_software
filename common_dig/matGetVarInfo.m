function [varNames,varTypes,varOffsets,varDimensions,varSizes]=matGetVarInfo(fileID)
%function [varNames,varTypes,dataOffsets,varDimensions,varSizes]=matGetVarInfo(fileID)
%
% Reads a .mat file and returns the names of the variables contained within.
%  Can also return the variables types (cell array), byte offsets in the .mat file
%  for the data for each variable, and the row X cols dimensions of each variable.
%
% BUGS:-  Can only deal with 5 types of MATLAB variable, and only those
%           with 0, 1, or 2 dimensions.
%      -  Does matlab always save with the same machineformat? Machine format not yet fixed.
%      -  DOES NOT DEAL WITH COMPLEX NUMBERS YET
%
% by cPbL@alum.mit.edu and Robert M Barrington Leigh, 2000 August 23
%
% Modified by Daniel Golden (dgolden1 at stanford dot edu) 2007

% $Id$

% OPTIONAL FORMS FOR FIRST ARGUMENT
if ~exist('fileID','var') || isempty(fileID)% FOR DEBUGGING
  [filename,pathname] = uigetfile('.mat', 'Choose a .mat file to open');
  fileID=fullfile( pathname, filename );
end%if
if ischar(fileID)
  [fid, message] = fopen(fileID,'r','ieee-le'); % Need to fix machine format
  if fid == -1, error(message); end
else
  fid=fileID;
end%if

% INITIALIZATION OF VARIABLES
nVars=0;

% BEGIN MAJOR LOOP OVER ALL EXISTING VARIABLES IN FILE

bUseKludgeHeader = true; % This accounts for BB data from 2004 that was recorded incorrectly
frewind(fid); % Rewind file
while (~feof(fid))
  nVars=nVars+1;
  
  % Unless we determine that this data is narrowband data, we'll continue
  % to use matReadHeaderKludge, which corrects the fact that BB data from
  % summer 2004 was labeled as float32 point, but is actually int16
  if bUseKludgeHeader
    [varName,varType,varRows,varCols,varImag,varSize]=matReadHeaderKludge(fid);
    if strcmp(varName, 'is_broadband')
      pos = ftell(fid);
      is_broadband = matGetVariable(fid,'is_broadband');
      fseek(fid, pos, 'bof'); % Undo the file seeking that matGetVariable did
      if ~is_broadband, bUseKludgeHeader = false; end
    end
  else
    [varName,varType,varRows,varCols,varImag,varSize]=matReadHeader(fid);
  end
  if isnumeric(varName) && varName==-1 % EOF HAS OCCURRED
    break;
  end%if
  if ~ischar(varName) || isempty(varName) % .MAT file format is bad -- maybe it is not v4.
    error('Can''t get file information for non version-4 .mat file.');
  end%if
  varNames{nVars,1}=varName;
  varOffsets(nVars,1)=ftell(fid);
  varDimensions(nVars,:)=[varRows varCols];
  varTypes{nVars,1}=varType;
  varSizes(nVars, 1)=varSize;
  % SKIP OVER THE DATA FOR THIS VARIABLE:
  status = fseek(fid,varSize*varRows*varCols,'cof');
  if status ~= 0, error('Error seeking in file; perhaps the file is incomplete?'); end
  
end%while LOOP OVER EXISTING VARIABLES

if ischar(fileID)
  fclose(fid);
end%if


