function whTarcsaiPlot
% Allows the user to select an indeterminant number of tarcsai files and
% plots their Neq values versus time.  Points are color coded according to
% their L values.  Error lines are drawn for each point representing the
% error estimate provided for each point's Neq value.  If the error
% estimate is more than half of the Neq value, the point is discarded.

global DF

d = findobj('Tag','destination');

if (isempty(d))
    destin = DF.destinPath;
else
    destin = get(d,'String');
end

if (destin(end) ~= filesep)
    destin = [destin filesep];
else
    destin = destin;
end

% User selects files
[filename, pathname] = uigetfile('*_tarcsai*.mat', 'Select File',...
    destin, 'MultiSelect', 'On');

% load all of the relevant data
for n = 1:length(filename)
    load(fullfile(pathname, filename{n}));
    UT(n) = tarcsai_result.UT;
    L(n) = tarcsai_result.L;
    SigmaL(n) = tarcsai_result.sigma_L;
    Neq(n) = tarcsai_result.neq;
    SigmaNeq(n) = tarcsai_result.sigma_neq;
end

forTitle = sort(UT,'ascend');

name = [datestr(forTitle(1), 'yyyy mmm dd HH:MM:SS') ' to ' datestr(forTitle(end), 'yyyy mmm dd HH:MM:SS')];

l = 1.5 ; % first L value checked
colors = ['m' 'g' 'b' 'c' 'r' 'k' 'y' 'w'];
colorindex = 1;

figure
h = axes;
title(['Neq vs UT for ', name])
xlabel('UT')
ylabel('Neq')
set(h,'NextPlot','add');

legendstrings = {}; % used to label the L value color legend
n = 1;

indices = {};
indcount = 1;

% iterate over logical values of l
while (l<=3.5)
    inds = find(L <= l & L > (l-.25));
    
    % only plot if there are whistlers with specified L value
    if (~isempty(inds))
        % remove all points whose Sigma Neq value is greater than half of
        % the calculated Neq Value
        while( n <= length(inds))
            if (SigmaNeq(inds(n)) > .5*Neq(inds(n)))
                inds = [inds(1:n-1) inds(n+1:end)];
            else
                n = n + 1;
            end
        end
        n = 1;
        
        % plot remaining points 
        if (~isempty(inds))
            axes(h);
            plot(UT(inds),Neq(inds),'LineStyle','none', 'Marker', '.',...
                'MarkerEdgeColor', colors(colorindex),'MarkerFaceColor',colors(colorindex));
            colorindex = colorindex + 1;
            indices{indcount} = inds;
            indcount = indcount + 1;
            legendstrings{end+1} = [num2str(l-.25) ' < L <= ' num2str(l)];
            
            % Display to the console the values of the points being plotted
            for k = 1:length(inds)
               disp(['UT Time: ',datestr(UT(inds(k)))])
               disp(['L ' , num2str(L(inds(k))), ' +- ', num2str(SigmaL(inds(k)))])
               disp(['Neq ',num2str(Neq(inds(k))),' +- ', num2str(SigmaNeq(inds(k)))]) 
               disp(' ')
            end
            
        end
    end
    l = l + .25;
        
end

if (~isempty(legendstrings))
    leg = legend (h, legendstrings, 'Location','SouthOutside');
end

colorindex = 1;

% plot error lines
for n = 1:length(indices)
    top = (Neq(indices{n}) + SigmaNeq(indices{n}));
    bottom = (Neq(indices{n}) - SigmaNeq(indices{n}));
    line([UT(indices{n}); UT(indices{n})], [top; bottom], 'color', colors(colorindex));
    colorindex = colorindex + 1;
end

set(h,'YScale','log');


datetick(h,'x','keeplimits');
xlimits = get(h,'XLim');
xtickmarks = get(h,'xtick');

set(leg,'location','best');
