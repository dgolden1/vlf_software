% A script to calculate emission from a ground-based vertical dipole
% antenna using the full-wave method
tstart_total=now*24*3600;
if do_axisymmetric
    disp('***** Starting a 2D (axisymmetric) calculation *****');
else
    disp('***** Starting a 3D calculation *****');
end
disp('***** Load various parameters *****');
fwm_antenna_parameters
disp('***** Calculate the best grid *****');
% Try restoring the grid from backup
if exist([datadir 'grid.mat'],'file')
    load([datadir 'grid']);
    disp('----- Loaded grid data -----');
else
    % No backup, have to calculate the best grid
    fwm_antenna_bestgrid
end
if do_axisymmetric
    fwm_antenna_2d
else
    fwm_antenna_3d_waves
    fwm_antenna_3d_assemble
    fwm_antenna_3d_plotting
end
t_total=now*24*3600-tstart_total;
disp(['**** TOTAL TIME = ' hms(t_total) ' ****']);
