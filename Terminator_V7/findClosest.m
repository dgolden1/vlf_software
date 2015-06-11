function index = findClosest(x,v);

%finds index in v corresponding to the closest element to x

difference = abs(v-x);
min_d = min(difference);
index = find(difference==min_d);
index = index(1); %in case of more than one minimum, take first one
