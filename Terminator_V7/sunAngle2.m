function [h,az] =  sunAngle2(lat,lon,year,month,day,hour,minute,second)

T = tFormat([year,month,day,hour,minute,second]);
day = T(2);
rad = 180/pi;

    fday =  (hour * 3600 + minute * 60 + second) / 86400.;
	dj = (year - 1900) * 365 + (year - 1901) / 4 + day - .5 + fday;
	t = dj / 36525;
	d1 = dj * .9856473354 + 279.696678;
	vl = mod(d1, 360);
	d1 = dj * .9856473354 + 279.690983 + fday * 360 + 180;
	gst = mod(d1, 360.) / rad;
	d1 = dj * .985600267 + 358.475845;
	g = mod(d1, 360.) / rad;
	slong = (vl + (1.91946 - t * .004789) * sin(g) + sin(g * 2) * .020094) / rad;
	if (slong > 2*pi) 
		slong = slong-2*pi;
    end
	if (slong < 0)
		slong =slong + 2*pi;
    end
	obliq = (23.45229 - t * .0130125) / rad;
	sob = sin(obliq);
	slp = slong - 9.924e-5;

	sind = sob * sin(slp);
	r1 = sind;
	cosd = sqrt(1 - r1 * r1);
	sc = sind / cosd;
	sdec = atan(sc);
	rasn = pi - atan2(cos(obliq) / sob * sc, -cos(slp) / cosd);
	
    
    
		theta = gst + lon/rad;
		tau = theta - rasn;
		lat_rad = lat/rad;
		h = (asin(sin(lat_rad)*sin(sdec) + cos(lat_rad)*cos(sdec).*cos(tau)))*rad;	
		az =(atan2(-sin(tau),(cos(lat_rad)*tan(sdec) - sin(lat_rad).*cos(tau))))*rad;
