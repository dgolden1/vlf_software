% Script to list the contents of the THEMIS CDFs

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id$

close all;
clear;


output_filename = '~/temp/blah.txt';
fid = fopen(output_filename, 'w');
cdf_dir = fullfile(scottdataroot, 'spacecraft', 'themis', 'level2', 'dfb', 'tha');

d_year = dir(fullfile(cdf_dir, '20*'));

for jj = 1:length(d_year)
  d_cdfs = dir(fullfile(cdf_dir, d_year(jj).name, '*.cdf'));
  
  for kk = 1:length(d_cdfs)
    [data, info] = cdfread(fullfile(cdf_dir, d_year(jj).name, d_cdfs(kk).name), 'CombineRecords', true);
    
    valid_idx = find(~cellfun(@isempty, data));
    
    % Print CDF filename
    fprintf(fid, '%s\n', d_cdfs(kk).name);
    
    % Print info about frequency bands
    fprintf(fid, 'fbk_fcenter: ');
    fprintf(fid, '%04.0f ', data{strcmp(info.Variables(:,1), 'tha_fbk_fcenter')}(1,:));
    fprintf(fid, '(Hz);  ');
    fprintf(fid, 'fbk_fband: ');
    fprintf(fid, '%04.0f ', data{strcmp(info.Variables(:,1), 'tha_fbk_fband')}(1,:));
    fprintf(fid, '(Hz)\n');
    
    
    % Print list of variables in CDF
    for ll = 1:length(valid_idx)
      fprintf(fid, '%s\n', info.Variables{valid_idx(ll), 1});
    end
    
    fprintf(fid, '\n');
    
    1;
  end
end

fclose all;
