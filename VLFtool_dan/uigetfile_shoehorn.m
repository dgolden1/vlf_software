function [filename, pathname, filterindex] = uigetfile_shoehorn(varargin)

%UIGETFILE Standard open file dialog box.
%   This code is a wrapper for uipickfiles around uigetfile written by
%   Daniel Golden (dgolden1 at stanford dot edu), because his Linux Matlab
%   7.1 version of uigetfile doesn't work when getting multiple files,
%   which is lame.
% 
%   [FILENAME, PATHNAME, FILTERINDEX] = UIGETFILE(FILTERSPEC, TITLE)
%   displays a dialog box for the user to fill in, and returns the filename
%   and path strings and the index of the selected filter. A successful
%   return occurs only if the file exists.  If the user  selects a file
%   that does not exist, an error message is displayed,  and control
%   returns to the dialog box. The user may then enter  another filename,
%   or press the Cancel button.
%
%   The FILTERSPEC parameter determines the initial display of files in
%   the dialog box.  For example '*.m' lists all the MATLAB M-files.  If
%   FILTERSPEC is a cell array, the first column is used as the list of
%   extensions, and the second column is used as the list of descriptions.
%
%   When FILTERSPEC is a string or a cell array, "All files" is  appended
%   to the list.
%
%   When FILTERSPEC is empty the default list of file types is used.
%
%   Parameter TITLE is a string containing the title of the dialog box.
%
%   The output variable FILENAME is a string containing the name of the
%   file selected in the dialog box.  If the user presses Cancel, it is set
%   to 0.
%
%   The output variable PATHNAME is a string containing the path of the
%   file selected in the dialog box.  If the user presses Cancel, it is set
%   to 0.
%
%   The output variable FILTERINDEX returns the index of the filter
%   selected in the dialog box. The indexing starts at 1. If the user
%   presses Cancel, it is set to 0.
%
%   [FILENAME, PATHNAME, FILTERINDEX] = UIGETTFILE(FILTERSPEC, TITLE, FILE)
%   FILE is a string containing the name to use as the default selection.
%
%   [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y]) places the
%   dialog box at screen position [X,Y] in pixel units. This option is
%   supported on UNIX platforms only.
%
%   [FILENAME, PATHNAME] = UIGETFILE(..., 'MultiSelect', SELECTMODE)
%   specifies if multiple file selection is enabled for the UIGETFILE
%   dialog. Valid values for SELECTMODE are 'on' and 'off'. If the value of
%   'MultiSelect' is set to 'on', the dialog box supports multiple file
%   selection. 'MultiSelect' is set to 'off' by default.
%
%   The output variable FILENAME is a cell array of strings if multiple
%   filenames are selected. Otherwise, it is a string representing
%   the selected filename.
%
%   [FILENAME, PATHNAME] = UIGETFILE(..., X, Y) places the dialog box at
%   screen position [X,Y] in pixel units. This option is supported on UNIX
%   platforms only.  THIS SYNTAX IS OBSOLETE AND WILL BE REMOVED. PLEASE
%   USE THE FOLLOWING SYNTAX INSTEAD:
%       [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])
%
%
%   Examples:
%
%   [filename, pathname, filterindex] = uigetfile('*.m', 'Pick an M-file');
%
%   [filename, pathname, filterindex] = uigetfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)';
%       '*.m',  'M-files (*.m)'; ...
%       '*.fig','Figures (*.fig)'; ...
%       '*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file');
%
%   [filename, pathname, filterindex] = uigetfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file', 'Untitled.mat');
%
%   Note, multiple extensions with no descriptions must be separated by semi-
%   colons.
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m';'*.mdl';'*.mat';'*.*'}, ...
%       'Pick a file');
%
%   Associating multiple extensions with one description:
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)'; ...
%       '*.*',                   'All Files (*.*)'}, ...
%       'Pick a file');
%
%   Enabling multiple file selection in the dialog:
%
%   [filename, pathname, filterindex] = uigetfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file', ...
%       'MultiSelect', 'on');
%
%   This code checks if the user pressed cancel on the dialog.
%
%   [filename, pathname] = uigetfile('*.m', 'Pick an M-file');
%   if isequal(filename,0) || isequal(pathname,0)
%      disp('User pressed cancel')
%   else
%      disp(['User selected ', fullfile(pathname, filename)])
%   end
%
%
%   See also UIPUTFILE, UIGETDIR.

%   Last modified Dec 5, 2006

% This is really a shoehorn, so we'll be a bit specific in the
% implementation

if nargin == 0
	filenameout = uipickfiles;
% If we have two arguments, we'll hope that they're the FILTERSPEC and
% TITLE parameters; if we have more than two and the third is
% 'MultiSelect', then we'll throw the third (and subsequent ones) away
elseif nargin == 2 || (nargin > 2 && ischar(varargin{3}) && strcmpi('MultiSelect', varargin{3}))
	if ~(ischar(varargin{1}) && ischar(varargin{2}))
		error('Expected FILTERSPEC and TITLE character arguments');
	end
	filenameout = uipickfiles('FilterSpec', varargin{1}, 'Prompt', varargin{2});
% Here, we hope that the arguments are FILTERSPEC, TITLE, FILE, and then
% some special arguments. We'll throw away the special arguments.
elseif nargin > 2
	if ~(ischar(varargin{1}) && ischar(varargin{2}) && ischar(varargin{3}))
		error('Expected FILTERSPEC, TITLE and NAME character arguments');
	end
	
	filterspec = varargin{1};
	title = varargin{2};
	file = varargin{3};
	
	% This is the filterspec format expected by uipickfiles; it's the file
	% and filterspec fields concatenated together
	full_filterspec = fullfile(file, filterspec);

	filenameout = uipickfiles('FilterSpec', full_filterspec, 'Prompt', title);
else
	error('Wierd argument error.');
end


% filenameout has the full file names (with paths) in a 1xn cell array,
% where n is the number of selected files
n = size(filenameout, 2);

filterindex = 0;
if n == 0      % no selection made
	filename = 0; pathname = 0;
else
	for j = 1:n
		[pathstr, name, ext] = fileparts(filenameout{j});
		if j > 1 && ~strcmp(pathstr, pathname)
			error('All files must be from the same directory for compatibility with original uigetfile');
		elseif j == 1
			pathname = [pathstr '/'];
		end
		filename{j} = [name ext];
	end
end

% If only one file was selected, break the filename out of its cell
if size(filename) == [1 1]
	filename = filename{1};
end
