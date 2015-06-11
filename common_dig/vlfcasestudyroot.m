function p = dancasestudyroot
% Return path to Dan's case study directory on different machines

% By Daniel Golden (dgolden1 at stanford dot edu) Dec 2008
% $Id$

persistent d_root
if ~isempty(d_root)
	p = d_root;
	return;
end

[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
	case 'dantop.local'
		d_root = '/Users/dgolden/temp/case_studies';
  case 'goldenmac.stanford.edu'
    d_root = '/Users/dgolden/Documents/vlf/case_studies/';
	case 'quadcoredan.stanford.edu'
		d_root = '/home/dgolden/vlf/case_studies';
  otherwise
    if ~isempty(regexp(hostname(1:end-1), '^cluster[0-9]{3}$'))
      % Nansen unix cluster
      d_root = '/home/dgolden/shared/case_studies';
    else
      error('Unknown hostname ''%s''', hostname(1:end-1));
      % d_root = uigetdir(pwd, 'Choose case study directory');
    end
end

if ~exist(d_root, 'dir')
  error('%s is not a valid directory', d_root);
end

p = d_root;
