function varargout = vlfGetCombinedData(num_channels, data, fname, startSample, endSample)
% [data1, data2] = vlfGetCombinedData(num_channels, data, fname, startSample, endSample)
% If one output argument, combines both channels of data in a sqrt(NS^2 + EW^2) sense
% If two output argument, returns both channels without screwing with them

% If num_channels is two, we already have both channels, interleaved in the
% 'data' variable
if num_channels == 2
	if nargout == 1
		varargout{1} = sqrt(data(1:2:end).^2 + data(2:2:end).^2);
	else
		varargout{1} = data(1:2:end);
		varargout{2} = data(2:2:end);
	end
	
% Otherwise, we'll need to open the other file
else
	% Make sure this file is in the '002' '003' format
	assert(~isempty(strfind(fname, '002.mat')));
	fname = strrep(fname, '002.mat', '003.mat');
	data2 = matGetVariable(fname, 'data', endSample-startSample, startSample);
	
	if nargout == 1
		varargout{1} = sqrt(data.^2 + data2.^2);
	else
		varargout{1} = data;
		varargout{2} = data2;
	end
end
