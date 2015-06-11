function varargout = whTarcsaiGUI(varargin)
% WHTARCSAIGUI M-file for whTarcsaiGUI.fig
%      WHTARCSAIGUI, by itself, creates a new WHTARCSAIGUI or raises the existing
%      singleton*.
%
%      H = WHTARCSAIGUI returns the handle to a new WHTARCSAIGUI or the handle to
%      the existing singleton*.
%
%      WHTARCSAIGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WHTARCSAIGUI.M with the given input arguments.
%
%      WHTARCSAIGUI('Property','Value',...) creates a new WHTARCSAIGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before whTarcsaiGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to whTarcsaiGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% $Id:whTarcsaiGUI.m 522 2007-09-24 21:29:08Z dgolden $

% Edit the above text to modify the response to help whTarcsaiGUI

% Last Modified by GUIDE v2.5 29-Aug-2007 13:29:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @whTarcsaiGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @whTarcsaiGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before whTarcsaiGUI is made visible.
function whTarcsaiGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to whTarcsaiGUI (see VARARGIN)

% Choose default command line output for whTarcsaiGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes whTarcsaiGUI wait for user response (see UIRESUME)
% uiwait(handles.tarcsaifig);


% --- Outputs from this function are returned to the command line.
function varargout = whTarcsaiGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in tarcsai_selwh.
function tarcsai_selwh_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_selwh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% try
	bMadeImage = whTarcsaiSelectWhistler;

    
    % If we didn't make an image, don't play with the checkboxes
    if ~bMadeImage
        return;
    end
	
	% Enable the checkboxes
	set(handles.tarcsai_showdata_check, 'Enable', 'on');
	set(handles.tarcsai_showest_check, 'Enable', 'on');
	
    % Display the data points
    whTarDisWhistler;
    
    % Set the "Show Data Points" checkbox to be on
    set(handles.tarcsai_showdata_check, 'Value', 1);

    % Set the "Show Estimate" checkbox to be on
	set(handles.tarcsai_showest_check, 'Value', 1);
    
% catch
% 	er = lasterror;
% 	h = errordlg(er.message, 'TARCSAI error');
% 	uiwait(h);
% end

% --- Executes on button press in tarcsai_selwhs.
function tarcsai_selwhs_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_selwhs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whTarcsaiSelectWhistlers;

% --- Executes on button press in tarcsai_selfol.
function tarcsai_selfol_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_selfol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whProcessWhistlers;


% --- Executes on button press in tarcsai_donebutton.
function tarcsai_donebutton_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_donebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whDoneTarcsai;


% --- Executes on button press in tarcsai_cldata.
function tarcsai_cldata_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_cldata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whTarClearWhistler;


% --- Executes on button press in tarcsai_showdata_check.
function tarcsai_showdata_check_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_showdata_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tarcsai_showdata_check
if get(hObject, 'Value') == 1
	whTarDisWhistler;
% 	set(hObject, 'Value', 1);
else
	whTarClearWhistler;
% 	set(hObject, 'Value', 0);
end


% --- Executes on button press in tarcsai_clest.
function tarcsai_clest_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_clest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whTarClearOverlay;


% --- Executes on button press in tarcsai_showest_check.
function tarcsai_showest_check_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_showest_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tarcsai_showest_check
if get(hObject, 'Value') == 1
	whTarShowOverlay;
% 	set(hObject, 'Value', 1);
else
	whTarClearOverlay;
% 	set(hObject, 'Value', 0);
end


% --- Executes on selection change in tarcsai_modellist.
function tarcsai_modellist_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_modellist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns tarcsai_modellist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tarcsai_modellist


% --- Executes during object creation, after setting all properties.
function tarcsai_modellist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_modellist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_stationfield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_stationfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_stationfield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_stationfield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_stationfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_stationfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_datefield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_datefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_datefield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_datefield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_datefield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_datefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_timefield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_timefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_timefield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_timefield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_timefield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_timefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_modelfield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_modelfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_modelfield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_modelfield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_modelfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_modelfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_dcifield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_dcifield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_dcifield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_dcifield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_dcifield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_dcifield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_dofield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_dofield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_dofield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_dofield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_dofield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_dofield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_fheqfield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_fheqfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_fheqfield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_fheqfield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_fheqfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_fheqfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_tfield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_tfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_tfield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_tfield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_tfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_tfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_lfield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_lfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_lfield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_lfield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_lfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_lfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tarcsai_neqfield_Callback(hObject, eventdata, handles)
% hObject    handle to tarcsai_neqfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tarcsai_neqfield as text
%        str2double(get(hObject,'String')) returns contents of tarcsai_neqfield as a double


% --- Executes during object creation, after setting all properties.
function tarcsai_neqfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tarcsai_neqfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

