function generate_nldn_statistics
% generate_nldn_statistics
% Generate lightning statistics for lightning flashes in the vicinity of
% Palmer's conjugate point in 2003
% 
% The output will be an arbitrary unit of "lightning intensity" which is
% defined as follows:
% o In the given hours, take all lightning strokes within a 2000 km radius
% from Palmer's conjugate point
% o Weight the amplitude in kA as follows: according to Nikolai's FWM code,
% we expect a ~2 kHz wave to attenuate by about 10 dB/1000 km in the FAR
% FIELD (see plot_gnd_power() in the fwm_whistler/ directory). Let A =
% stroke VLF amplitude (at source), A' = weighted VLF amplitude and Mm =
% distance in Megameters. Then we want 20*log10(A') = 20*log10(A) - 10/Mm,
% or A' = A*10^(-5e-4/km).
% o Assume each return stroke has half the energy of the initial stroke, so weight
% strokes with high multiplicity as 2^0 + 2^-1 + 2^-2 + ... etc.

% By Daniel Golden (dgolden1 at stanford dot edu) July 2009
% $Id$

%% Setup
[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
        case 'polarbear'
			nldn_source_dir = '/home/dgolden1/input/nldn/daily';
			output_dir = '/home/dgolden1/output/nldn_statistics';
        case 'quadcoredan.stanford.edu'
			nldn_source_dir = '/home/dgolden/vlf/case_studies/nldn/daily';
			output_dir = '/home/dgolden/vlf/case_studies/nldn/statistics';
        otherwise
               error('Unknown host (%s)', hostname(1:end-1));
end

date_start = datenum([2003 01 01 0 0 0]);
date_end = datenum([2003 11 1 0 0 0]);
hours = (date_start:1/24:date_end).';
days = (date_start:date_end).';

% Coords around which to center circle
center_str = 'palmer_conj';
% center_str = 'maine';
switch center_str
	case 'palmer_conj'
		% Palmer conjugate coords
		p_lat = 40.06;
		p_lon = -69.43;
	case 'maine'
		% Coords determined from hiss_nldn_superposed_epoch_hourly.m flash maps
		p_lat = 47;
		p_lon = -67;
end

% mask_type = 'east_coast';
mask_type = 'east_coast_flashrate';
% mask_type = 'circle_no_atten';
% mask_type = 'circle_atten';
% mask_type = 'circle_flashrate';

catchall_distance_km = 1000;
atten_per_megameter = 70; % dB/Mm

%% Lightning options
ampl_thresh = 00; % Amplitude threshold in kA
disp(sprintf('Using amplitude threshold of %d kA', ampl_thresh));
pause(1);

%% Parallel
PARALLEL = false;

if ~PARALLEL
	warning('Parallel mode disabled!');
end

poolsize = matlabpool('size');
if PARALLEL && poolsize == 0
	matlabpool('open');
end
if ~PARALLEL && poolsize ~= 0
	matlabpool('close');
end

%% Loop over days
lightning_amp = zeros(size(hours));

t_start = now;
for kk = 1:(length(days) - 1)
	t_file_start = now;
	
	nldn_filename = sprintf('nldn%s.mat', datestr(days(kk), 'yyyymmdd'));
	nldn = load(fullfile(nldn_source_dir, nldn_filename));
	
	% Remove flashes below amplitude threshold
	idx = nldn.peakcur > ampl_thresh;
	names = fieldnames(nldn);
	for jj = 1:length(names)
		nldn.(names{jj}) = nldn.(names{jj})(idx);
	end

	dist = deg2km(distance(p_lat, p_lon, nldn.lat, nldn.lon));

	for jj = 1:24
		hour_idx = (kk - 1)*24 + jj;
		lightning_amp(hour_idx) = gen_distance_mask(p_lon, nldn, hours(hour_idx), hours(hour_idx+1), dist, mask_type, catchall_distance_km, atten_per_megameter);
	end
	
	disp(sprintf('Processed %s in %0.0f seconds', nldn_filename, (now - t_file_start)*86400));
end
disp(sprintf('Processed all files in %0.0f seconds', (now - t_start)*86400));

%% Determine unit string
switch mask_type
	case {'east_coast', 'circle_no_atten', 'circle_atten'}
		unit_str = 'Sum lightning amplitude (kA)';
	case {'east_coast_flashrate', 'circle_flashrate'}
		unit_str = 'Flashes per hour';
	otherwise
		error('Invalid mask_type (%s)', mask_type);
end

% Append add'l information to unit string
unit_str = sprintf('%s %s', unit_str, strrep(mask_type, '_', '\_'));
if ~isempty(findstr(mask_type, 'circle'))
	unit_str = sprintf('%s %s\\_%dkm', unit_str, strrep(center_str, '_', '\_'), catchall_distance_km);
end

%% Save
% output_filename = sprintf('nldn_statistics_%02ddb_%04dkm.mat', atten_per_megameter, catchall_distance_km);
output_filename = 'nldn_statistics.mat';
save(fullfile(output_dir, output_filename), 'hours', 'lightning_amp', 'mask_type', 'center_str', 'unit_str', 'catchall_distance_km');
disp(sprintf('Wrote %s', fullfile(output_dir, output_filename)))

% % Plot resulting ECLE
% figure;
% plot(hours, lightning_amp, 'LineWidth', 2);
% grid on;
% xlim([date_start date_end]);
% datetick('x', 'keeplimits');
% xlabel('Date');
% ylabel(unit_str);
% increase_font;


function lightning_amp = gen_distance_mask(p_lon, nldn, this_hour, next_hour, dist, mask_type, catchall_distance_km, atten_per_megameter)
% Various ways to filter out or attenuate lightning strokes
% If mask_type is 'east_coast', then catchall_distance_km isn't used

lightning_amp = 0;
switch mask_type
	% Search for strokes within 20 degrees East or West of Palmer's
	% conjugate point. Ignore latitude and distance
	case 'east_coast'
		idx = find(nldn.date >= this_hour & nldn.date < next_hour & angledist([nldn.lon], p_lon) < 20);
		for jj = 1:length(idx)
			this_lightning_amp = abs(nldn.peakcur(idx(jj))) * sum(2.^(0:-1:(-nldn.nstrokes(idx(jj)) + 1))); % Multiplicity 
			lightning_amp = lightning_amp + this_lightning_amp;
		end
		
	% Ignore amplitude
	case 'east_coast_flashrate'
		idx = find(nldn.date >= this_hour & nldn.date < next_hour & angledist([nldn.lon], p_lon) < 20);
		for jj = 1:length(idx)
			this_lightning_amp = abs(nldn.peakcur(idx(jj))) * sum(2.^(0:-1:(-nldn.nstrokes(idx(jj)) + 1))); % Multiplicity 
			lightning_amp = lightning_amp + this_lightning_amp;
		end
		
	% Search for strokes within a certain radius of Palmer's conjugate
	% point; pay no attention to distance
	case 'circle_no_atten'
		idx = find(nldn.date >= this_hour & nldn.date < next_hour & dist <= catchall_distance_km);
		for jj = 1:length(idx)
			this_lightning_amp = abs(nldn.peakcur(idx(jj))) * sum(2.^(0:-1:(-nldn.nstrokes(idx(jj)) + 1))); % Multiplicity 
			lightning_amp = lightning_amp + this_lightning_amp;
		end
	
	% Also ignore peak current
	case 'circle_flashrate'
		idx = nldn.date >= this_hour & nldn.date < next_hour & dist <= catchall_distance_km;
		lightning_amp = sum(nldn.nstrokes(idx));
		
	% Search for strokes within a certain radius of Palmer's conjugate
	% point; pay attention to peak current and attenuate strokes by paying
	% attention to propagation effects within the EI waveguide
	case 'circle_atten'
		idx = find(nldn.date >= this_hour & nldn.date < next_hour & dist <= catchall_distance_km);
		for jj = 1:length(idx)
			this_lightning_amp = abs(nldn.peakcur(idx(jj))) * ... % Original current
								 sum(2.^(0:-1:(-nldn.nstrokes(idx(jj)) + 1))) * ... % Multiplicity
								 10^(-atten_per_megameter/1e3*dist(idx(jj))); % Distance
			lightning_amp = lightning_amp + this_lightning_amp;
		end
end
