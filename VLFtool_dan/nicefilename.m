function out_filename = nicefilename(in_filename, bMakeLowercase)
% out_filename = nicefilename(in_filename)
% 
% Takes in a string and outputs a version that is acceptable as a file name.
% Non-alphanumeric characters are converted to underscores 

if ~exist('bMakeLowercase')
	bMakeLowerCase = false;
end
if bMakeLowerCase
	out_filename = lower(in_filename);
else
	out_filename = in_filename;
end

% Find non-alphanumeric characters and replace them with underscores
bad_letters = ~isstrprop(out_filename, 'alphanum');
out_filename(bad_letters) = '_';
