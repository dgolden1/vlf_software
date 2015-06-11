function p = scottdataroot
% Return path to scott data directory on different machines

% By Daniel Golden (dgolden1 at stanford dot edu) March 2010
% $Id$

persistent s_root
if ~isempty(s_root)
  p = s_root;
  return;
end

[stat, hostname] = system('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'quadcoredan.stanford.edu'
    s_root = '/media/scott';
  case 'scott.stanford.edu'
    s_root = '/data';
  case {'shackleton.stanford.edu', 'amundsen.stanford.edu'}
    s_root = '/home/dgolden/scott';
  case 'nansen'
    s_root = '/mnt/scott_data';
  case 'dantop.local'
    s_root = '~/temp/scott';
  case 'goldenmac.stanford.edu'
    s_root = '/Volumes/data';
  otherwise
    if ~isempty(regexp(hostname, 'cluster[0-9][0-9][0-9]'))
      s_root = '/mnt/scott_data';
    else
      error('Unknown hostname ''%s''', hostname(1:end-1));
    end
end

if isempty(s_root)
  error('Unknown hostname ''%s''', hostname(1:end-1));
elseif ~exist(s_root, 'dir')
  error('%s is not a valid directory', s_root);
end

p = s_root;
