function dstPlot (filename)
% plots the DST for a given month

dst = dstRead(filename);

month = datestr(dst.UT(1), 'mmmm');

figure
plot(dst.UT, dst.dst);

set(gca,'xlim',[dst.UT(1) dst.UT(end)]);

xticks = datestr(get(gca,'xtick'));
if (length(xticks) > 13)
    xticks = xticks(:,13:17);
else 
    xticks = xticks(:,1:6);
end
set(gca,'xticklabel',xticks);

title(['HOURLY EQUATORIAL DST VALUES for ' month]);
xlabel('Day of Month')
ylabel('DST in nT')
