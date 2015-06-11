function plot_pp_density(fits_filename, db_filename, handles)

try
	plot_palmer_plasma_density(fits_filename, 6, [], handles.axes_density_1d, db_filename)
catch err
	if strcmp(err.identifier, 'plot_palmer_plasma_density:NotEnoughVals')
		cla(handles.axes_density_1d);
		warning(err.message);
	else
		rethrow(err);
	end
end
