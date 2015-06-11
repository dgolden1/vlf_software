function [filenames_out, start_datenums_out, end_datenums_out] = get_datafile_list(type_str, year)
% get_datafile_list(type_str)
% Parse list of DEMETER data files
% 
% type_str may be only 'efield_survey' for now

% By Daniel Golden (dgolden1 at stanford dot edu) March 2011
% $Id$

% Make everything persistent, since looking things up takes a while and
% this function will likely be run multiple times with the same parameters
persistent filenames start_datenums end_datenums last_type_str last_year

if ~strcmp(last_type_str, type_str) || last_year ~= year
  switch type_str
    case 'efield_survey'
      data_dir = fullfile(scottdataroot, 'spacecraft', 'demeter', 'Level1', 'General', '1132_survey_VLF_E_psd', num2str(year));
    otherwise
      error('Invalid type_str: %s', type_str);
  end

  d = dir(fullfile(data_dir, '*.DAT'));

  names = [d.name];
  C = textscan(names, 'DMT_N1_1132_%05f%1f_%04f%02f%02f_%02f%02f%02f_%04f%02f%02f_%02f%02f%02f.DAT');
  
  last_type_str = type_str;
  last_year = year;


  orbitno = C{1};
  b_upcoming = C{2} == 1;
  start_datenums = datenum([C{3} C{4} C{5} C{6} C{7} C{8}]);
  end_datenums = datenum([C{9} C{10} C{11} C{12} C{13} C{14}]);

  filenames = cellfun(@(x) fullfile(data_dir, x), {d.name}, 'UniformOutput', false);
end

filenames_out = filenames;
start_datenums_out = start_datenums;
end_datenums_out = end_datenums;
