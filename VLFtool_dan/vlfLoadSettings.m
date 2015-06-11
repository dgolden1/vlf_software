function DF = vlfLoadSettings(settingsFileName)
% DF = vlfLoadSettings(settingsFileName)
% Loads vlfTool settings. Populates fields of vlfGui via the vlfPopulateFieldValues()
% function.
% 
% INPUTS
%   settingsFileName: file name string for the settings file (default = 'settings.mat')
% 
% OUTPUTS
%   DF = the resultant DF struct
% 
% By Daniel Golden (dgolden1 at stanford dot edu) May 3 2007

% $Id$

if ~exist('settingsFileName', 'var'), settingsFileName = 'settings.mat'; end

load(settingsFileName, 'DF');
if ~exist('DF', 'var')
	error('Invalid settings file (%s): does not contain ''DF'' struct', settingsFileName);
end

vlfPopulateFieldValues(DF);
