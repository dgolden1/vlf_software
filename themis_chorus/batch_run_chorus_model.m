function batch_run_chorus_model(start_datenum, end_datenum, dt, output_filename)
% Run the chorus model for arbitrary times and save output

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id$

%% Setup
if ~exist('output_filename', 'var') || isempty(output_filename)
  output_filename = fullfile('~/temp/chorus_model_output.mat');
end

%% Choose times
if ~exist('start_datenum', 'var') || isempty(start_datenum)
  start_datenum = datenum([1995 01 02 0 0 0]);
  end_datenum = datenum([2012 01 01 0 0 0]);
end
if ~exist('dt', 'var') || isempty(dt)
  dt = 1/24;
end

epoch = start_datenum:dt:end_datenum;

%% Load model features
model = load(fullfile(vlfcasestudyroot, 'themis_chorus', 'themis_chorus_regression.mat'), '-regexp', '^(?!Y).*');

%% Run model
t_pred_start = now;
[X_all, X_names_all] = set_up_predictor_matrix_v2(epoch);
fprintf('Loaded model features in %s\n', time_elapsed(t_pred_start, now));

t_model_start = now;
lat = 0;
chorus_ampl_map = run_chorus_model(X_all, X_names_all, model, lat);
chorus_ampl_map = squeeze(chorus_ampl_map); % Squeeze out latitude dimension, which is singleton
fprintf('Ran model in %s\n', time_elapsed(t_model_start, now));

%% Save as .mat file
L = model.L_centers;
MLT = model.MLT_centers;
save(output_filename, 'chorus_ampl_map', 'epoch', 'L', 'MLT');
fprintf('Saved %s\n', output_filename);

%% Save as CSV file
% [L_mat, MLT_mat, epoch_mat] = ndgrid(L, MLT, epoch);
% fid = fopen(strrep(output_filename, '.mat', '.csv'), 'w');
% 
% fprintf(fid, 'L,MLT,Date,log10_pT\n');
% for kk = 1:numel(L_mat)
%   fprintf(fid, '%0.1f,%0.1f,%s,%0.3E\n', L_mat(kk), MLT_mat(kk), datestr(epoch_mat(kk), 'yyyy-mm-dd HH:MM'), chorus_ampl_map(kk));
% end
% 
% fclose(fid);

% cell_array = cell(numel(L_mat), 4);
% cell_array(:, 1) = num2cell(L_mat(:));
% cell_array(:, 2) = num2cell(MLT_mat(:));
% cell_array(:, 3) = num2cell(epoch_mat(:));
% cell_array(:, 4) = cellfun(@(x) datestr(x, 'yyyy-mm-dd HH:MM'), num2cell(chorus_ampl_map(:)));
% cell_to_csv(strrep(output_filename, '.mat', '.csv'), cell_array);




%% Plot (for debugging)
figure
figure_grow(gcf, 2, 1);
imagesc(epoch, MLT, squeeze(nanmean(chorus_ampl_map, 1)));
axis xy;
caxis([0 1]);
datetick2;
ylabel('MLT');
zoom xon;
