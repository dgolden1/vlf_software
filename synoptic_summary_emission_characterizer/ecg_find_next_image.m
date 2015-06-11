function next_image_str = ecg_find_next_image(this_image_str, offset)
% next_image_str = ecg_find_next_image(this_image_str, offset)
% Finds next image in this directory offset images away
% E.g., if offset=1, finds the next image
%       if offset=-1, finds the previous image

% By Daniel Golden (dgolden1 at stanford dot edu) November 2007
% $Id$

error(nargchk(1, 2, nargin));

if ~exist('offset', 'var'), offset = 1; end

% Get listing of other files in directory
[pathstr, name, ext] = fileparts(this_image_str);
thisfilepath = pathstr;
thisfilename = [name ext];
filelist = dir(pathstr);

% Remove directories
filelist([filelist.isdir]) = [];
% Find this image
for kk = 1:length(filelist)
	[pathstr, name, ext] = fileparts(filelist(kk).name);
	if ~strcmp(ext, '.jpg') && ~strcmp(ext, '.png')
		continue;
	end
	if strcmp([name ext], thisfilename)
		thisfileno = kk;
		break;
	end
end
assert(logical(exist('thisfileno', 'var'))); % Make sure we found this image

% Check for no more images
if thisfileno + offset > length(filelist) || thisfileno + offset < 1
	error('ecg_find_next_image:NoMoreImages', 'No more images in folder');
end


next_image_str = fullfile(thisfilepath, filelist(thisfileno+offset).name);
