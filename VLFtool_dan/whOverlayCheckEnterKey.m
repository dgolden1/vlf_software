function whOverlayCheckEnterKey
% Allows the user to hit enter after updating the start time field in the
% overlay analysis interface to regraph the overlay curves instead of
% forcing the user to hit the button.  Does not check to make sure the
% contents of the field are valid.  Hitting enter with invalid contents in
% the Start field will lead to bad things.
% 
% Determined obsolete by Daniel Golden (dgolden1 at stanford dot edu) May 4 2007

% $Id$

%get(gcf,'CurrentCharacter')

error('This function is obsolete');

if (get(gcf,'CurrentCharacter') == 13)
    % it didn't work without this pause.  Somehow the new contents of the
    % field were not updated in the object unless I put this pause here.
    pause(.05); 
    whShowOverlay;
end
