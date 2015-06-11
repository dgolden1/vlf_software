function varargout = matLoad(fileID)
% matLoad(fileID) -- assign variables to calling workspace
% or
% var_struct = matLoad(fileID) -- assign variables to output struct
% 
% See matLoadExcept

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

if nargout == 1
	varargout{1} = matLoadExcept(fileID,'data');
	varargout{1}.data = matGetVariable(fileID,'data');
else
	df = matLoadExcept(fileID,'data');
	names = fieldnames(df);
	for kk = 1:length(names)
		assignin('caller', names{kk}, df.(names{kk})); 
	end
	assignin('caller', 'data', matGetVariable(fileID,'data'));
end
