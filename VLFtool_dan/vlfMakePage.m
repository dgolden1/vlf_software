function vlfMakePage
% As far as I can tell, this function is concerned with setting up a funky figure
% ('page') to hold one or more spectrograms --Dan
% 
% Modified by Daniel Golden (dgolden1 at stanford dot edu) Feb 2007

% $Id$

global DF;


for( k = 1:DF.numPlots )

	disp(['** ' num2str(k) ' **']);

	vlfLoadData( DF.filename{k}, DF.pathname{k} )
    
	iiCol = k;

	if( DF.calcPSD )
		disp('----- calcPSD');
		[p, f] = vlfCalcPSD;
		DF.VLF.UT = [DF.VLF.UT DF.bbrec.startDate];
		DF.VLF.freq = f;
		DF.VLF.psd = [DF.VLF.psd p];
	end;

	vlfPlotSpecgram( 1, iiCol);
	
	if( DF.numRows > 1 )
		vlfPlotSpecgram( 2, iiCol);
	end;

	if( k == 1 )
		[y,mo,d,h,mi,s] = datevec(DF.bbrec.startDate);
		yyyy = datestr( DF.bbrec.startDate, 'yyyy');
		mm = datestr( DF.bbrec.startDate, 'mm');
		mmm = datestr( DF.bbrec.startDate, 'mmm');
		dd = datestr( DF.bbrec.startDate, 'dd');
		hh = datestr( DF.bbrec.startDate, 'HH');
		MM = datestr( DF.bbrec.startDate, 'MM');

		set(DF.fig, 'Name', [yyyy mm dd]);
		if( DF.numPlots == 1 )
			saveName = [lower(DF.bbrec.site) '_' yyyy mm dd '_' ...
				hh MM ];
		else
			saveName = [lower(DF.bbrec.site) '_' yyyy mm dd '_' ...
				hh '-'];
		end;
		doy = jday(DF.bbrec.startDate);

		h_t = axes( 'Pos', [DF.titleX  DF.titleY 0.001 0.001]);
		set(h_t, 'Visible', 'off');
		titlestr = [DF.bbrec.site '   ' yyyy ' ' mmm ' ' dd ...
			' (Day ' doy ')   ' ...
			num2str( DF.endSec - DF.startSec ) ' sec snapshots'];
		text(0, 0, titlestr, 'Horiz', 'center');
		
	end;

end;

if( DF.numPlots > 1 )
% 	hh = datestr( DF.bbrec.startDate, 'HH');
	hh = datestr( DF.bbrec.startDate, 'MM');
	saveName =  [saveName hh];
end;

DF.saveName = saveName;



	


