function whWhistlerHisto (filename)
% Creates histograms for the whistler count data contained in the function
% argument filename.  The file should be a text file, contain data for
% only one month and be formatted as follows:
% 
% month name
% day #
% whistler count for hour 1
% whistler count for hour 2
% ...
% 
% if the count for a given hour is 0, enter a zero for its whistler count.
% A histogram for each day and for the entire month will be created and
% displayed.

% read in file.  
fid = fopen(filename);
month = textscan(fid, '%s', 1); % read in month name
Data = textscan(fid, '%f'); % read in all other data
fclose(fid);

m = month{1}{1};
d = Data{1};
numdays = size(d,1)/25;

% create plots for each day of data in the file
for n=1:numdays
    day(:,n) = d((n-1)*25+2:(n-1)*25+25,1);
    figure
    bar(day(:,n));
    title(['Histogram of Whistlers per hour on ' m ' ' num2str(d((n-1)*25+1))]);
    xlabel('UT hour')
    ylabel('# of Whistlers')
end

figure

% make the histogram for the entire month
bar(day(:))

set(gca, 'xlim',[0 (size(d,1)/25)*24+1]);
xticks = mod(get(gca, 'xtick'),24);
xticks(find(xticks == 0)) = 24;
xticks(1) = 0;
set(gca, 'xticklabel',xticks);
title(['Histogram of Whistlers per hour in ' m ' from ' num2str(d(1)) ' to ' num2str(d((numdays-1)*25+1))]);
ylabel('# of Whistlers')
xlabel('UT hour')
