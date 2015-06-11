function key_value = get_fits_keyword(info_struct, key_str)
% key_value = get_fits_keyword(info_struct, key_str)
% 
% Get the value of the given keyword from a FITS info struct

% By Daniel Golden (dgolden1 at stanford dot edu) April 21
% $Id$

%% Find the key string
find_res = strmatch(key_str, {info_struct.PrimaryData.Keywords{:,1}}, 'exact');
if isempty(find_res), error('Keyword ''%s'' not found', key_str); end
if length(find_res) > 1, error('Multiple copies of keyword ''%s'' found', key_str); end

key_value = info_struct.PrimaryData.Keywords{find_res, 2};
