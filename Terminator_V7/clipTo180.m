function out = clipTo180(in);

L = length(in);

for i = 1:L
    if(in(i)<-180)
        out(i) = -180;
    elseif(in(i)>180)
        out(i) = 180;
    else
        out(i) = in(i);
    end
end
