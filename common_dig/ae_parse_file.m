function ae_parse_file(ae_filename)
% parse_ae_file(ae_filename)
% Function to remove the extraneous AU, AL and AO information from combined
% AE files

fid = fopen(ae_filename);
new_ae_file = '';

while ~feof(fid)
	line = fgets(fid);
	if length(line) > 2 && strcmp(line(1:2), 'AE')
		new_ae_file = [new_ae_file line];
	end
end

fclose(fid);
fopen(ae_filename, 'w');
fwrite(fid, new_ae_file);
fclose(fid);
