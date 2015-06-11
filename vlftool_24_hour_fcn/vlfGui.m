function varargout = vlfGui(varargin)
%VLFGUI M-file for vlfGui.fig
%      VLFGUI, by itself, creates a new VLFGUI or raises the existing
%      singleton*.
%
%      H = VLFGUI returns the handle to a new VLFGUI or the handle to
%      the existing singleton*.
%
%      VLFGUI('Property','Value',...) creates a new VLFGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to vlfGui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VLFGUI('CALLBACK') and VLFGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VLFGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vlfGui

% Last Modified by GUIDE v2.5 30-Jan-2011 13:07:29

% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vlfGui_OpeningFcn, ...
                   'gui_OutputFcn',  @vlfGui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before vlfGui is made visible.
function vlfGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for vlfGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vlfGui wait for user response (see UIRESUME)
% uiwait(handles.vlfGui);

% #############
% ADDED
% #############

global DF;

set(handles.vlfGui, 'Name', 'vlfTool');

h = findobj('Tag', 'sourcePath');
set(h, 'String', DF.sourcePath );
h = findobj('Tag', 'destinPath');
set(h, 'String', DF.destinPath );

h = findobj('Tag', 'maxPlots');
set(h, 'String', num2str(DF.maxPlots));
h = findobj('Tag', 'wildcard');
wc = [];
for( k = 1:length(DF.wildcard)-1 )
  wc = [wc DF.wildcard{k} ', '];
end;
wc = [wc DF.wildcard{end}];
set(h, 'String', wc );
h = findobj('Tag', 'startSec');
set(h, 'String', num2str(DF.startSec) );
h = findobj('Tag', 'endSec');
set(h, 'String', num2str(DF.endSec) );

h = findobj('Tag', 'savePlots');
set(h, 'Value', DF.bSavePlot );
h = findobj('Tag', 'saveType');
if( strcmp(DF.saveType, 'jpg') );
	set(h, 'Value', 1);
elseif ( strcmp(DF.saveType, 'eps') )
	set(h, 'Value', 2);
elseif ( strcmp(DF.saveType, 'png') )
	set(h, 'Value', 3);
end;

h = findobj('Tag', 'useMLT');
set(h, 'Value', DF.useMLT);
set(h, 'Enable', 'off');

h = findobj('Tag', 'mltOffset');
set(h, 'String', '4');
set(h, 'Enable', 'off');

h = findobj('Tag', 'hideFigure');
set(h, 'Value', DF.hideFigure);


if( DF.numRows == 1 )
	h = findobj('Tag', 'row1');
	set(h, 'Value', 1);
	h = findobj('Tag', 'row2');
	set(h, 'Value', 0);
elseif( DF.numRows == 2 );
	h = findobj('Tag', 'row1');
	set(h, 'Value', 1);
	h = findobj('Tag', 'row2');
	set(h, 'Value', 1);
end;


% --- Executes on button press in settingsRow1.
function settingsRow1_Callback(hObject, eventdata, handles)
% hObject    handle to settingsRow1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vlfSettingsGui(1);



% --- Executes on button press in settingsRow2.
function settingsRow2_Callback(hObject, eventdata, handles)
% hObject    handle to settingsRow2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vlfSettingsGui(2);


% --- Executes on button press in sourceBrowse.
function sourceBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to sourceBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DF;
updateDF;
directory = uigetdir(DF.sourcePath);
if( directory ~= 0 )
	DF.sourcePath = directory;
	set( findobj('Tag', 'sourcePath'), 'String', DF.sourcePath );
end;


% --- Executes on button press in destinBrowse.
function destinBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to destinBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DF;
updateDF;
directory = uigetdir(DF.destinPath);
if( directory ~= 0 )
	DF.destinPath = directory;
	set( findobj('Tag', 'destinPath'), 'String', DF.destinPath );
end;


% --- Executes on button press in selectFiles.
function selectFiles_Callback(hObject, eventdata, handles)
% hObject    handle to selectFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateDF;
global DF;

vlfProcess(1);


% --- Executes on button press in processDVD.
function processDVD_Callback(hObject, eventdata, handles)
% hObject    handle to processDVD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateDF;
global DF;

vlfProcess;


% --- Executes on button press in process24.
function process24_Callback(hObject, eventdata, handles)
% hObject    handle to process24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DF;
updateDF;

DF.process24 = 1;

status = 'Process';

while( strcmp(status, 'Process') )
  isvalid = vlfProcess;
  if( ~isvalid )
    DF.process24 = 0;
    return;
  end;

  beep; pause(0.25); beep; pause(0.25);
  beep; pause(0.25); beep; pause(0.25);

  if( length( DF.h_ax ) == 96 )
    status = 'Done';
  else
%     status = questdlg('Insert next disc', 'Process 24', 'Process', 'Done', 'Process');
	
	new_disc_dir = uigetdir(DF.sourcePath, 'Insert next disc');
	if ischar(new_disc_dir)
		status = 'Process';
		DF.sourcePath = fullfile(new_disc_dir, filesep);
		h = findobj('Tag', 'sourcePath');
		set(h, 'String', DF.sourcePath );
	else
		status = 'Done';
	end
  end;

  if( strcmp( status, 'Done' ) )
    if( DF.bSavePlot )
      vlfSavePlot;
    end;
    DF.h_ax = [];
    DF.h_cb = [0 0];
    DF.process24 = 0;

  else
    DF.process24 = DF.process24 + 1;
  end;
end;

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closereq;

% --- Outputs from this function are returned to the command line.
function varargout = vlfGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function vlfGui_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vlfGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




function maxPlots_Callback(hObject, eventdata, handles)
% hObject    handle to maxPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxPlots as text
%        str2double(get(hObject,'String')) returns contents of maxPlots as a double


% --- Executes during object creation, after setting all properties.
function maxPlots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wildcard_Callback(hObject, eventdata, handles)
% hObject    handle to wildcard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wildcard as text
%        str2double(get(hObject,'String')) returns contents of wildcard as a double


% --- Executes during object creation, after setting all properties.
function wildcard_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wildcard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savePlots.
function savePlots_Callback(hObject, eventdata, handles)
% hObject    handle to savePlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of savePlots


% --- Executes on selection change in saveType.
function saveType_Callback(hObject, eventdata, handles)
% hObject    handle to saveType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns saveType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from saveType
global DF;

h = findobj('Tag', 'saveType');
type = get(h, 'Value');
if( type == 1 )
	DF.saveType  = 'jpg';
elseif type == 2
	DF.saveType  = 'eps';
else
	DF.saveType  = 'png';
end;



% --- Executes during object creation, after setting all properties.
function saveType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hideFigure.
function hideFigure_Callback(hObject, eventdata, handles)
% hObject    handle to hideFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hideFigure


% --- Executes on button press in useMLTlabel.
function useMLTlabel_Callback(hObject, eventdata, handles)
% hObject    handle to useMLTlabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useMLTlabel



function mltOffset_Callback(hObject, eventdata, handles)
% hObject    handle to mltOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mltOffset as text
%        str2double(get(hObject,'String')) returns contents of mltOffset as a double


% --- Executes during object creation, after setting all properties.
function mltOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mltOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in row1.
function row1_Callback(hObject, eventdata, handles)
% hObject    handle to row1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of row1

% --- Executes on button press in row2.
function row2_Callback(hObject, eventdata, handles)
% hObject    handle to row2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of row2



function sourcePath_Callback(hObject, eventdata, handles)
% hObject    handle to sourcePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sourcePath as text
%        str2double(get(hObject,'String')) returns contents of sourcePath as a double


% --- Executes during object creation, after setting all properties.
function sourcePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sourcePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function destinPath_Callback(hObject, eventdata, handles)
% hObject    handle to destinPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destinPath as text
%        str2double(get(hObject,'String')) returns contents of destinPath as a double




% --- Executes during object creation, after setting all properties.
function destinPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destinPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function startSec_Callback(hObject, eventdata, handles)
% hObject    handle to startSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startSec as text
%        str2double(get(hObject,'String')) returns contents of startSec as a double


% --- Executes during object creation, after setting all properties.
function startSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endSec_Callback(hObject, eventdata, handles)
% hObject    handle to endSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endSec as text
%        str2double(get(hObject,'String')) returns contents of endSec as a double


% --- Executes during object creation, after setting all properties.
function endSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_use_cal.
function checkbox_use_cal_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_use_cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_use_cal


% --- Executes on button press in checkbox_force_1every15.
function checkbox_force_1every15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_force_1every15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_force_1every15
