% Script to take events that begin at 0005 and move them to 0000
% and take events that end at 2355 and move them to 0000

close all;
clear;

load /home/dgolden/vlf/vlf_software/dgolden/synoptic_summary_emission_characterizer/2003_chorus_list.mat;

for kk = 1:length(events)
	% Events that start at 0005
	if (events(kk).start_datenum - floor(events(kk).start_datenum))*24*60 < 6
		events(kk).start_datenum = floor(events(kk).start_datenum);
	end
	
	% Events that end at 2355
	if (1 - (events(kk).end_datenum - floor(events(kk).end_datenum)))*24*60 < 6
		events(kk).end_datenum = ceil(events(kk).end_datenum);
	end
end

save /home/dgolden/vlf/vlf_software/dgolden/synoptic_summary_emission_characterizer/2003_chorus_list.mat events
