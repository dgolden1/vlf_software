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

% Last Modified by GUIDE v2.5 26-Sep-2007 16:25:39
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
global ALLDATA;

if isempty(DF)
	DF = vlfLoadSettings;
else
	vlfPopulateFieldValues(DF);
end

ALLDATA = get(findobj('Tag','allData'),'Value');



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


% --- Executes on button press in row1.
function row1_Callback(hObject, eventdata, handles)
% hObject    handle to row1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of row1


% --- Executes on button press in settingsRow1.
function settingsRow1_Callback(hObject, eventdata, handles)
% hObject    handle to settingsRow1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vlfSettingsGui(1);


% --- Executes on button press in row2.
function row2_Callback(hObject, eventdata, handles)
% hObject    handle to row2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of row2


% --- Executes on button press in settingsRow2.
function settingsRow2_Callback(hObject, eventdata, handles)
% hObject    handle to settingsRow2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vlfSettingsGui(2);


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


% --- Executes on button press in sourceBrowse.
function sourceBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to sourceBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DF;
directory = uigetdir(DF.sourcePath);
if( directory ~= 0 )
	DF.sourcePath = directory;
	set( findobj('Tag', 'sourcePath'), 'String', DF.sourcePath );
end;


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


% --- Executes on button press in destinBrowse.
function destinBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to destinBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DF;
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

vlfRefreshDFFromFieldValues;
global DF;
DF.process24 = 0;

DF.VLF.UT = [];
DF.VLF.freq = [];
DF.VLF.psd = [];

try
	vlfSelectFiles;
catch
	er = lasterror;
	h = errordlg(er.message, 'File Selection Error');
	uiwait(h);
% 	rethrow(er); % Rethrow the error
end


% --- Executes on button press in processDVD.
function processDVD_Callback(hObject, eventdata, handles)
% hObject    handle to processDVD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vlfRefreshDFFromFieldValues;
global DF;
DF.process24 = 0;

DF.VLF.UT = [];
DF.VLF.freq = [];
DF.VLF.psd = [];

try
	vlfProcessDVD;
catch
	er = lasterror;
	h = errordlg(er.message, 'Error processing DVD');
	uiwait(h);
end


% --- Executes on button press in process24.
function process24_Callback(hObject, eventdata, handles)
% hObject    handle to process24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DF;
if( DF.process24 == 0 )
	DF.VLF.UT = [];
	DF.VLF.freq = [];
	DF.VLF.psd = [];
end;
	
vlfRefreshDFFromFieldValues;

DF.process24 = 1;
set( findobj('Tag', 'selectFiles'), 'Enable', 'off');
set( findobj('Tag', 'processDVD'), 'Enable', 'off');
set( findobj('Tag', 'exit'), 'Enable', 'off');
if( isunix )
	[status, result] = unix('mount /mnt/cdrom1');
end;
if( DF.calcPSD )
	disp('----- calcPSD');
	vlfProcessDVDpsd;
end;

vlfProcess24;
if( isunix )
	[status, result] = unix('umount /mnt/cdrom1');
	if ( ~status )
		unix('eject /mnt/cdrom1');
	else
		disp(result);
	end;
end;

beep; pause(0.25);
beep; pause(0.25);
beep; pause(0.25);
beep; pause(0.25);

ans = questdlg('Process Another DVD?', 'Process 24', 'Yes', 'No', 'Yes');
if( strcmp( ans, 'No' ) )
	clean24_Callback;
else
	process24_Callback;
end;

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closereq;



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


% --- Executes on button press in clean24.
function clean24_Callback(hObject, eventdata, handles)
% hObject    handle to clean24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global FIG;
global DF;

for( k = 1:length(FIG.h) )
	DF.fig = FIG.h(k);
	DF.saveName = FIG.saveName{k};
	vlfSavePlot;
	close( DF.fig );
end;

if( DF.calcPSD )
	stime = [ datestr( DF.VLF.UT(1), 'yyyy' ) ...
		datestr( DF.VLF.UT(1), 'mm' ) datestr( DF.VLF.UT(1), 'dd' ) ];
	etime = [ datestr( DF.VLF.UT(end), 'yyyy' ) ...
		datestr( DF.VLF.UT(end), 'mm' ) datestr( DF.VLF.UT(end), 'dd' ) ];

	VLF = DF.VLF;
	VLF.site = DF.bbrec.site;

	savename = [ lower(VLF.site) '_psd_' stime '_' etime '.mat'];
	save( [DF.destinPath savename], 'VLF');
	disp(['wrote ' DF.destinPath savename] );
end;

FIG = [];
set( findobj('Tag', 'selectFiles'), 'Enable', 'on');
set( findobj('Tag', 'processDVD'), 'Enable', 'on');
set( findobj('Tag', 'exit'), 'Enable', 'on');


% --- Executes on button press in calcPSD.
function calcPSD_Callback(hObject, eventdata, handles)
% hObject    handle to calcPSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of calcPSD


% --- Executes on button press in plotPSD.
function plotPSD_Callback(hObject, eventdata, handles)
% hObject    handle to plotPSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vlfPlotPSD;


% --- Executes on selection change in calibration.
function calibration_Callback(hObject, eventdata, handles)
% hObject    handle to calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns calibration contents as cell array
%        contents{get(hObject,'Value')} returns selected item from calibration


% --- Executes during object creation, after setting all properties.
function calibration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in useCal.
function useCal_Callback(hObject, eventdata, handles)
% hObject    handle to useCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns useCal contents as cell array
%        contents{get(hObject,'Value')} returns selected item from useCal


% --- Executes during object creation, after setting all properties.
function useCal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to useCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in colorScale.
function colorScale_Callback(hObject, eventdata, handles)
% hObject    handle to colorScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns colorScale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colorScale


% --- Executes during object creation, after setting all properties.
function colorScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fullData.
function fullData_Callback(hObject, eventdata, handles)
% hObject    handle to fullData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fullData
global ALLDATA;
ALLDATA = get(hObject,'Value');
if (ALLDATA)
    set(findobj('Tag','maxPlots'),'String','1');
    set(findobj('Tag','maxPlots'),'Enable','off');
else
    set(findobj('Tag','maxPlots'),'Enable','on');
end

function lengthData_Callback(hObject, eventdata, handles)
% hObject    handle to lengthData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lengthData as text
%        str2double(get(hObject,'String')) returns contents of lengthData as a double


% --- Executes during object creation, after setting all properties.
function lengthData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lengthData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxPlots_Callback(hObject, eventdata, handles)
% hObject    handle to maxPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxPlots as text
%        str2double(get(hObject,'String')) returns contents of maxPlots as a double


% --- Executes on button press in savesettingsbutton.
function savesettingsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savesettingsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DF
vlfRefreshDFFromFieldValues;
vlfSaveSettings(DF);

% --- Executes on button press in loadsettingsbutton.
function loadsettingsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadsettingsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DF
DF = vlfLoadSettings;


% --- Executes on button press in pushbutton_tarcsai.
function pushbutton_tarcsai_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_tarcsai (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

whTarcsai;
