function [varData]=matGetVariable(fileID,whichVariable,nElements,startOffset,knownVarData)
% varData=matGetVariable(fileID,whichVariable,nElements,startOffset,knownVarData);
%
% Returns a portion of a specified variable from a version 4 (?) MAT file.
% The MAT file (fileID) can be specified by name (string) or by an open fid.
% The variable is specified by its name, a string (whichVariable).
% nElements and startOffset specify the length and offset of the
% desired portion of the variable's data. startOffset is 0-based

% BUGS:-  Will only put data into a 1-D array at the moment. This is easy to generalize and should be but hasn't been yet.
%      -  Can only deal with 5 types of MATLAB variable, and only those
%           with 0, 1, or 2 dimensions.
%      -  Does matlab always save with the same machineformat? Machine format not yet fixed.
%      -  DOES NOT DEAL WITH COMPLEX NUMBERS YET
%
% by cPbL@alum.mit.edu and Robert M Barrington Leigh, 2000 August 23
%
% Modified by Daniel Golden (dgolden1 at stanford dot edu) 2007 Apr 24
% $Id$

%% Setup
varData = [];

if exist('nElements', 'var') && ~isempty(nElements) && nElements - floor(nElements) ~= 0
  error('nElements must be an integer');
elseif ~exist('nElements', 'var')
  nElements = [];
end
if exist('startOffset', 'var') && ~isempty(startOffset) && startOffset - floor(startOffset) ~= 0
  error('startOffset must be an integer');
elseif ~exist('startOffset', 'var')
  startOffset = [];
end

%% OPTIONAL FORMS FOR FIRST ARGUMENT
if ~exist('fileID','var') || isempty(fileID)% FOR DEBUGGING
  [filename,pathname] = uigetfile('.mat', 'Choose a .mat file to open');
  fileID=fullfile(pathname, filename);
end%if
if ischar(fileID)
  [fid, message] = fopen(fileID,'r'); % Need to fix machine format
  if fid == -1
    error('Error opening file %s: %s', fileID, message);
  end
else
  fid=fileID;
end%if

%% IF NO VARIABLE CHOSEN, GIVE A LIST OF THE VARIABLES:
if nargin ==1,
  varNames=matGetVarInfo(fileID);
  varNames'
  if ischar(fileID)
    fclose(fid);
  end%if
  return
end%if

%% If we already know the offset, return that variable
if exist('knownVarData', 'var') && ~isempty(knownVarData)
  fseek(fid, knownVarData.varOffset, 'bof');
  varData = getVariableData(fid, knownVarData.varType, knownVarData.varRows, ...
    knownVarData.varCols, knownVarData.varSize, nElements, startOffset);

  if ischar(fileID)
    fclose(fid);
  end
  
  return
end

%% BEGIN MAJOR LOOP OVER ALL EXISTING VARIABLES IN FILE
frewind(fid); % Rewind file
while (~feof(fid))
  try
    [varName,varType,varRows,varCols,varImag,varSize]=matReadHeader(fid);
  catch er
    % Sometimes, we don't know we're at the EOF until matReadHeader hits it
    if strcmp(er.identifier, 'matReadHeader:eof')
      break;
    else
      rethrow(er);
    end
  end
  
  if strcmp(varName, whichVariable)% THIS IS THE VARIABLE WE WANT
    varData = getVariableData(fid, varType, varRows, varCols, varSize, nElements, startOffset);
    
    if ischar(fileID)
      fclose(fid);
    end
    return
  else % THIS IS NOT THE VARIABLE WE WANT!
    fseek(fid,varCols*varRows*varSize,'cof');
  end
end

if ischar(fileID)
  fclose(fid);
end

% Error if we couldn't find this variable
error('matGetVariable:varNotFound', 'Variable %s not found in file', whichVariable);

function varData = getVariableData(fid, varType, varRows, varCols, varSize, nElements, startOffset)
% Get the variable which begins at the given offset
% If offset is not given, assume the file is already at the right offset

if isempty(nElements)
  nElements = varRows*varCols;
end
if isempty(startOffset)
  startOffset = 0;
end

if startOffset > max(varRows*varCols-1, 0)
  error('The start offset is too large');
end
fseek(fid,(startOffset)*varSize,'cof');

varData=fread(fid,min([nElements varRows*varCols-startOffset]),varType);

if (~isempty(strfind(varType,'char')))
  varData = char(varData)';
end
