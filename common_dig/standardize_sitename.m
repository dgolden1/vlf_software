function [site_dirname, site_prettyname] = standardize_sitename(mat_sitename)
% [site_dirname, site_prettyname] = standardize_sitename(mat_sitename)
% 
% Function that takes a site name from the station_name or similar variable
% and changes it to a standardized site name
% 
% For example, in the past, the station_name variable of Palmer has been
% any of the following: PalmerStation, palmer station, palmerbb, palmer__,
% palmer. This script will convert it to just 'palmer'
%
% This script will call a helper Python function to fetch the site name
% mapping from an online Google doc at:
% https://spreadsheets.google.com/ccc?key=0Asf3e2bVdAXzdEtRT0s4SmNCY0tnSTRsbkVkR3JvWlE&hl=en

% By Daniel Golden (dgolden1 at stanford dot edu) November 2009
% $Id$

%% Setup
cache_filename = fullfile(danmatlabroot, 'common_dig', 'standardize_sitename_db.pickle');


%% Fetch site info from Google doc
persistent C last_fetch_time

% Only fetch from the Google doc if we haven't done so in the last hour.
% Otherwise, if looping over a bunch of files, we'd have to check the
% Google doc for each one, which is wasteful and slow.
if isempty(last_fetch_time) || (now - last_fetch_time) >= 1/24
  script_filename = fullfile(danmatlabroot, 'alexandria_sort_script_python', 'fetch_vlf_site_info.py');
  script_args = sprintf('--outfile=%s --infile=%s', cache_filename, cache_filename);

  if isunix
    ext = '';
  else
    ext = '.exe';
  end

  cmd = sprintf('python%s %s %s', ext, script_filename, script_args);
%   disp(cmd);
  [blah, A] = system(cmd);

  if blah ~= 0
    error(A);
  end

  C = textscan(A, '%s %s', 'headerlines', 1, 'delimiter', ';');
  
  last_fetch_time = now;
end

%% Get folder name
site_dirname = '';
for kk = 1:length(C{1})
	[this_site_dirname, mat_names] = strtok(C{1}{kk}, '=');
	mat_names = mat_names(2:end); % Remove = sign

	% This shouldn't happen, but skip this line of C if we don't have any .mat sitename for this folder name
	if isempty(mat_names)
		continue;
	end
	
	mat_name_list = textscan(mat_names, '%s', 'delimiter', ',');
	mat_name_list{1}{end+1} = this_site_dirname; % Make sure proper dir name is also a possibility
	findres = strcmpi(mat_sitename, mat_name_list{1});
	
	if any(findres)
		site_dirname = this_site_dirname;
		break;
	end
end

if isempty(site_dirname)
	error('Site %s not found', mat_sitename);
end

%% Get pretty name

site_prettyname = '';
for kk = 1:length(C{2})
	[this_prettyname, this_dirname] = strtok(C{2}{kk}, '=');
	this_dirname = this_dirname(2:end); % Remove = sign
	
	if strcmpi(site_dirname, this_dirname)
		site_prettyname = this_prettyname;
		break;
	end
end

if isempty(site_prettyname)
	error('Pretty name for site dir %s not found', site_dirname);
end
