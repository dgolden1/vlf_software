function vlfSavePlot;

global DF;

figure( DF.fig );	

DF.saveName = [DF.saveName '.' DF.saveType];
origpwd = pwd;
cd(DF.destinPath)
if( strcmp( DF.saveType, 'jpg' ) )
	print(DF.fig, '-djpeg', DF.saveName );
else
	print(DF.fig, '-depsc', DF.saveName );
end;

cd(origpwd);
disp(['wrote ' DF.destinPath DF.saveName]);


