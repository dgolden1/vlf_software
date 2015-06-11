function h =  myWorldmap(params)

ver = get_version_number;

switch ver
    case 14
        if(isfield(params,'h'))
            axes(params.h)
        end
        if(isfield(params,'latRange'))
            latRange = params.latRange;
        else
            latRange = [-90,90];
        end
        if(isfield(params,'lonRange'))
            lonRange = params.lonRange;
        else
            latRange = [-180,180];
        end
        h = worldmap(latRange,lonRange,'lineonly');
        plabel('off'); mlabel('off');
        
    case 15
        if(isfield(params,'h'))
            axes(params.h)
        end
        if(isfield(params,'latRange'))
            latRange = params.latRange;
        else
            latRange = [-90,90];
        end
        if(isfield(params,'lonRange'))
            lonRange = params.lonRange;
        else
            latRange = [-180,180];
        end
        
        h = worldmap(latRange,lonRange);
        htemp = get(h,'xlabel'); set(htemp,'visible','on');
        htemp = get(h,'ylabel'); set(htemp,'visible','on');
        
        load coast
        plotm(lat, long,'k');
        
        load usalo;
        plotm(stateborder.lat,stateborder.long,'k');
        
        load worldlo;
        plotm(POline(1).lat,POline(1).long,'k');
        
%         states = shaperead('usastatelo', 'UseGeoCoords', true);
%         geoshow([states.Lat],[states.Lon],'color','k');
        
        plabel('off'); mlabel('off');
        
        
        
    otherwise
        error('unrecognized version number');
end
