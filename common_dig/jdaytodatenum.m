function datenumber = jdaytodatenum(jday)
% datenumber = jdaytogday(jday)
% 
% Convert from Julian Day to Matlab datenum
% From http://en.wikipedia.org/w/index.php?title=Julian_day&oldid=205880816
% And http://aa.usno.navy.mil/data/docs/JulianDate.php

% J = jday;
% j = J + 32044;
% g = j / 146097;
% dg = mod(j, 146097);
% c = (dg/36524 + 1)*3/4;
% dc = dg - c*36524;
% b = dc/1461;
% db = mod(dc, 1461);
% a = (db/365 + 1)*3/4;
% da = db - a*365;
% y = g*400 + c*100 + b*4 + a;
% m = (da*5 + 308)/153 - 2;
% d = da - (m + 4)*153/5 + 122;
% Y = y - 4800 + (m + 2)/12;
% M = mod((m + 2), 12) + 1;
% D = d + 1.5;

% datenumber = datenum([Y M D 0 0 0]);

millennium_j_date = 2451544.5;
millennium_m_date = 730486;


datenumber = jday - millennium_j_date + millennium_m_date;
