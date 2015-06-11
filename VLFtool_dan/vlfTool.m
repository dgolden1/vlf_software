% Script to run the VlfTool GUI
% Modified by Daniel Golden (dgolden1 at stanford dot edu) Apr 2007

% $Id$

close all;
clear all;

global DF

% First try to load settings.mat settings file
try
   DF = vlfLoadSettings; 
catch
    % If that fails, load the default settings
    disp('settings.mat not found. Loading default settings...');
    DF = vlfDefaults;
end

% Then run the GUI
vlfGui;
