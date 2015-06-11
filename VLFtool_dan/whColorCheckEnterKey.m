function whColorCheckEnterKey
% executes when the user presses a key while editing the text fields in the
% color manipulation interface.  If the user hits enter, the colormap
% limits are changed to match the strings in the text fields.  Currently,
% there is not checking to ensure values contained in the fields are valid.

if (get(gcf,'CurrentCharacter') == 13)
    % it didn't work without this pause.  Somehow the new contents of the
    % field were not updated in the object unless I put this pause here.
    pause(.05); 
    cminv = str2num(get(findobj('Tag','cminedit'),'String'));
    cmaxv = str2num(get(findobj('Tag','cmaxedit'),'String'));
    set(findobj('Tag','spec_axis'),'CLim', [cminv cmaxv]);
    
    h = findobj('Tag','colorbari');
    colorLabel = get(get(h,'Ylabel'),'String');
    set(h,'YLim',[cminv cmaxv]);
    
    % Taken from vlfPlotSpecgram.  Redraws the colorbar with the new user
    % entered limits
    y = [cminv:0.25:cmaxv];
	x = ones(size(y));

	axes(h);
     
	imagesc( x, y, y' );
	axis xy;
	set(h, 'XTick', [], 'YAxisLoca', 'right', 'TickDir', 'out');
    title('dB');
    ylabel(colorLabel);
    axes(findobj('Tag','spec_axis'));
    set(h,'Tag','colorbari');
    figure(findobj('Tag','colormanip'));
end
