function xticks = whSetTickLabels(x)
% Used by the whNewPlotFcn to label the x-axis of the plot.  The initial
% tick is labeled with year, month, day and time.  Following the first
% tick, only the time is displayed unless the day or year changes.  At the
% tick where the change takes place, the day and year are displayed in
% addition to the time.

day = datestr(x(1),'dd');
month = datestr(x(1),'mmm');
year = datestr(x(1),'yyyy');
time = datestr(x(1),'HH:MM:SS');

% Label for the first tick
xticks(1,:) = [day ' ' month ' ' year ' ' time];

% determine appropriate label for all ticks
for n = 2:length(x)
    newday = datestr(x(n),'dd');
    newmonth = datestr(x(n),'mmm');
    newyear = datestr(x(n),'yyyy');
    newtime = datestr(x(n),'HH:MM:SS');
    
    if (strcmp(year, newyear) == 0)
        xticks(n,:) = [newday ' ' newmonth ' ' newyear ' ' newtime];
    elseif (strcmp(month, newmonth) == 0 || strcmp(day, newday) == 0)
        xticks(n,:) = ['   ' newday ' ' newmonth ' ' newtime '  '];        
    else
        xticks(n,:) = ['      ' newtime '      '];
    end
    day = newday;
    month = newmonth;
    year = newyear;
    time = newtime;
end
