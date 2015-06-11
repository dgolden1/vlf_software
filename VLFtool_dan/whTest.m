%function whTest
% not sure what this function was for, but I don't think it is used

load time_plot

% add sferic_time to the time vector
t = t + sferic_time;

start_time = 3.22;
end_time = 4.1;

start_ind = find(t<start_time,1,'first');
end_ind = find(t<end_time,1,'first');

numpoints = 20*rand

interval = round((start_ind - end_ind)/numpoints);

time = [];
frequency = [];

i = end_ind;
 
while (i<start_ind)
   time = [time t(i)];
   frequency = [frequency freq(i)];
   i = i + interval;    
end

time = fliplr(time);
time = time' - sferic_time;
frequency = fliplr(frequency);
frequency = frequency'/1000;

tarcsai(time, frequency)
