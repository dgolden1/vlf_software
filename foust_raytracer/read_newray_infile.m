function [config]  = read_newray_infile( file );

% [config] = read_newray_infile( file );
%
% Reads the 15 'Cards' from a newray input file and parses them into 
% the 75 newray variables.
%
% If the input file does not strictly conform to the newray.in format, the
% results of this call are not guaranteed, since no error checking is done.
%
% Note that Cards 3, 12 and 15 are 'input termination' cards whose values 
% never change.  They are read and returned for completeness. The companion 
% calls alter_newray_cards and write_newray_infile omit these cards from 
% their argument lists.
%
% See also parse_newray_cards, alter_newray_cards, build_newray_cards

% $$$ if nargin < 1, file = 'newray.in'; end;

fid = fopen( file, 'r' );
if fid < 0
  error('Could not open file');
end;

disp(['read_newray_infile: reading ' file]);

% we use sccanf( fgets(fid), ... ) to always gobble to end-of-line.
card1 = sscanf( fgets(fid), '%d', 4 )';

i = 0;
done = 0;
while ~done,
  a = sscanf( fgets(fid), '%g', 2 )';
  if a(1) > 0,
    i = i + 1;
    distre(i) = a(1); satlat(i) = a(2);
  else
    done = 1;
  end;
end;
card2 = [distre(:) satlat(:)];
card3 = [a(1) a(2)];

card4 = sscanf( fgets(fid), '%g', 10 )';
kducts = card4(5);

card5 = sscanf( fgets(fid), '%g', 5 )';

card6 = sscanf( fgets(fid), '%g', 5 )';

card7 = sscanf( fgets(fid), '%g', 5 )';

card8 = sscanf( fgets(fid), '%g', 5 )';

if kducts > 1,
  for i=1:(kducts-1),
    card9(i,:) = sscanf( fgets(fid), '%g', 12)';
  end;
else,
  card9 = [];
end;

card10 = sscanf( fgets(fid), '%g', 8 )';

i = 0;
done = 0;
while ~done,
  a = sscanf( fgets(fid), '%g', 8 )';
  if a(1) > 0,
    i = i + 1;
    fkc(i) = a(1); x01(i) = a(2); latitu(i) = a(3); delt(i) = a(4);
    psi(i) = a(5); tiniti(i) = a(6); x05(i) = a(7); tgfina(i) = a(8);
  else,
    done = 1;
  end;
end;
card11 = [fkc(:) x01(:) latitu(:) delt(:) psi(:) tiniti(:) x05(:) tgfina(:)];
card12 = [a(1) a(2) a(3) a(4) a(5) a(6) a(7) a(8)];

card13 = fgets(fid);
card13 = card13(1:length(card13)-1);	% remove \n

card14 = sscanf( fgets(fid), '%g', 10 )';

card15 = fgets(fid);
card15 = card15(1:length(card15)-1);

fclose(fid);



[config] = parse_newray_cards( card1,card2,card3,card4,card5,card6,...
                               card7,card8,card9,card10,card11,card12,...
                               card13,card14,card15 );
