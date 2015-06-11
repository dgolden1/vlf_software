function varargout = mapTool(varargin)
% MAPTOOL M-file for mapTool.fig
%      MAPTOOL, by itself, creates a new MAPTOOL or raises the existing
%      singleton*.
%
%      H = MAPTOOL returns the handle to a new MAPTOOL or the handle to
%      the existing singleton*.
%
%      MAPTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPTOOL.M with the given input arguments.
%
%      MAPTOOL('Property','Value',...) creates a new MAPTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mapTool_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mapTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help mapTool

% Last Modified by GUIDE v2.5 23-Apr-2007 22:25:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mapTool_OpeningFcn, ...
                   'gui_OutputFcn',  @mapTool_OutputFcn, ...
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


%% --- Executes just before mapTool is made visible.
function mapTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mapTool (see VARARGIN)

% Choose default command line output for mapTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mapTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%% --- Outputs from this function are returned to the command line.
function varargout = mapTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;


%% ---- lower_lat ----
function lower_lat_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function lower_lat_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','-90');
guidata(hObject,handles);

%% ---- upper_lat ----
function upper_lat_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function upper_lat_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','90');
guidata(hObject,handles);

%% ---- lower_lon ----
function lower_lon_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function lower_lon_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0');
guidata(hObject,handles);

%% ---- upper_lon ----
function upper_lon_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function upper_lon_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','360');
guidata(hObject,handles);


%% --- Executes on button press in plot_world.
function plot_world_Callback(hObject, eventdata, handles)
figureNo = str2num(get(handles.figure_no,'string'));
lower_lat = str2num(get(handles.lower_lat,'string'));
upper_lat = str2num(get(handles.upper_lat,'string'));
lower_lon = str2num(get(handles.lower_lon,'string'));
upper_lon = str2num(get(handles.upper_lon,'string'));
figure(figureNo);
clf; set(figureNo,'color','white')
params.latRange = [lower_lat,upper_lat];
params.lonRange = [lower_lon,upper_lon];
h = myWorldmap(params);
%worldmap([lower_lat,upper_lat],[lower_lon,upper_lon]);
mapData.latLonRanges = [lower_lat,upper_lat,lower_lon,upper_lon];
mapData.mapAxes(figureNo) = h;  %save map axes in figureNo slot in vector
set(figureNo,'UserData',mapData);



%% ---- figure_no -----
function figure_no_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function figure_no_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','1');
guidata(hObject,handles);

%% ----- mod_fig_no ----
function mod_fig_no_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function mod_fig_no_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','1');
guidata(hObject,handles);

%%  --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)

%% ---- T -----
function T_Callback(hObject, eventdata, handles)
Ttest = eval(get(hObject,'string'));
if(isnumeric(Ttest) & length(Ttest)==6)
    guidata(hObject,handles);
else
    error('Invalid time format')
end
function T_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','[2004 1 1 0 0 0]');
guidata(hObject,handles);

%% ---- altitude ----
function altitude_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function altitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0');
guidata(hObject,handles);

%% ---- number_pixels-----
function number_pixels_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function number_pixels_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','10000');
guidata(hObject,handles);


%% --- Executes on button press in plot_day_night.
function plot_day_night_Callback(hObject, eventdata, handles)
numPixels = str2num(get(handles.number_pixels,'string'));
alt = str2num(get(handles.altitude,'string'))*1000;
T = eval(get(handles.T,'string'));
figureNo = str2num(get(handles.mod_fig_no,'string'));
subplotNo = 111;
lat = [str2num(get(handles.lower_lat,'string')),...
    str2num(get(handles.upper_lat,'string'))];
lon = [str2num(get(handles.lower_lon,'string')),...
    str2num(get(handles.upper_lon,'string'))];
mapData = get(figureNo,'UserData');
if(isfield(mapData,'mapAxes') & length(mapData.mapAxes)>=figureNo & mapData.mapAxes(figureNo)~=0);
    mapAxes = mapData.mapAxes(figureNo);
else
    figure(figureNo);
    mapAxes = 0;
end
[c,cd,cn] = plotDayNight(T,lat,lon,numPixels,alt,mapAxes);
mapData.dayNight = c;
set(figureNo,'UserData',mapData);



%% --- Executes on button press in land_mask.
function land_mask_Callback(hObject, eventdata, handles)
h = figure(str2num(get(handles.mod_fig_no,'string')));
figure(h);
load coast;
patchm(lat,long,'g');


%% --- Executes on button press in plot_ocean.
function plot_ocean_Callback(hObject, eventdata, handles)
h = figure(str2num(get(handles.mod_fig_no,'string')));
figure(h);
load oceanlo;
for ii = 1:length(oceanmask)
    patchm(oceanmask(ii).lat,oceanmask(ii).long,'c','edgecolor','none');
end


%% ---- lat1 ----
function lat1_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
update_azimuth(handles);
update_range(handles);
set(handles.coord1_choose,'Value',1);
guidata(handles.coord1_choose,handles);
function lat1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0')
guidata(hObject,handles);


%% --- lon1 ----
function lon1_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
update_azimuth(handles);
update_range(handles);
set(handles.coord1_choose,'value',1);
guidata(handles.coord1_choose,handles);
function lon1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0')
guidata(hObject,handles);



%% --- lat2 ----
function lat2_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
update_azimuth(handles);
update_range(handles);
set(handles.coord2_choose,'value',1);
guidata(handles.coord2_choose,handles);
function lat2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0')
guidata(hObject,handles);



%% ---- lon2 ----
function lon2_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
update_azimuth(handles);
update_range(handles);
set(handles.coord2_choose,'Value',1);
guidata(handles.coord2_choose,handles);
function lon2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0')
guidata(hObject,handles);



%% ---- azimuth_1_2 ----
function azimuth_1_2_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
update_coord2(handles);
function azimuth_1_2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0')
guidata(hObject,handles);


%% ---- range_1_2 ----
function range_1_2_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
update_coord2(handles);
function range_1_2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0')
guidata(hObject,handles);

%% update_azimuth
function update_azimuth(handles)
azimuth12 = azimuth(str2num(get(handles.lat1,'string')),...
    str2num(get(handles.lon1,'string')),...
    str2num(get(handles.lat2,'string')),...
    str2num(get(handles.lon2,'string')),almanac('earth','ellipsoid','degrees'),'degrees');
azimuth12 = mod(azimuth12 + 180,360) - 180; %Range: [-180,180];
if(azimuth12 > 90)
    clarifierString = ['= ' num2str(azimuth12-180) ' + 180'];
elseif(azimuth12 < -90)
    clarifierString = ['= ' num2str(azimuth12+180) ' - 180'];
else
    clarifierString = '';
end
set(handles.azimuth_clarifier,'string',clarifierString);
set(handles.azimuth_1_2,'string',num2str(azimuth12));
guidata(handles.azimuth_1_2,handles);

%% update_range
function update_range(handles);
range12 = distanceInKm(...
    str2num(get(handles.lat1,'string')),...
    str2num(get(handles.lon1,'string')),...
    str2num(get(handles.lat2,'string')),...
    str2num(get(handles.lon2,'string')));
set(handles.range_1_2,'string',num2str(range12));
guidata(handles.range_1_2,handles);

%% update_coord2
function update_coord2(handles);
azimuth12 = str2num(get(handles.azimuth_1_2,'string'));
range12 = str2num(get(handles.range_1_2,'string'));
lat1 = str2num(get(handles.lat1,'string'));
lon1 = str2num(get(handles.lon1,'string'));
[lat2, lon2] = reckon(lat1, lon1, distdim(range12,'km','degrees'), azimuth12, ...
    almanac('earth','ellipsoid','degrees'),'degrees');
set(handles.lat2,'string',num2str(lat2));
guidata(handles.lat2,handles);
set(handles.lon2,'string',num2str(lon2));
guidata(handles.lon2,handles);
set(handles.coord2_choose,'value',1);
guidata(handles.coord2_choose,handles);


%% --- Executes on button press in coord1_retrieve.
function coord1_retrieve_Callback(hObject, eventdata, handles)
h = figure(str2num(get(handles.mod_fig_no,'string')));
figure(h);
[lat1,lon1] = inputm(1);
set(handles.lat1,'string',num2str(lat1));
guidata(handles.lat1,handles);
set(handles.lon1,'string',num2str(lon1));
guidata(handles.lon1,handles);
update_azimuth(handles);
update_range(handles);
set(handles.coord1_choose,'value',1);
guidata(handles.coord1_choose,handles);

%% --- Executes on button press in coord2_retrieve.
function coord2_retrieve_Callback(hObject, eventdata, handles)
h = figure(str2num(get(handles.mod_fig_no,'string')));
figure(h);
[lat2,lon2] = inputm(1);
set(handles.lat2,'string',num2str(lat2));
guidata(handles.lat2,handles);
set(handles.lon2,'string',num2str(lon2));
guidata(handles.lon2,handles);
update_azimuth(handles);
update_range(handles);
set(handles.coord2_choose,'value',1);
guidata(handles.coord2_choose,handles);


%%  --- Executes on button press in plot_gcp.
function plot_gcp_Callback(hObject, eventdata, handles)
lat1 = str2num(get(handles.lat1,'string'));
lon1 = str2num(get(handles.lon1,'string'));
lat2 = str2num(get(handles.lat2,'string'));
lon2 = str2num(get(handles.lon2,'string'));
[lats,lons] = track2(lat1,lon1,lat2,lon2);
figureNo = str2num(get(handles.mod_fig_no,'string'));
figure(figureNo);
plotm(lats,lons,get(handles.line_color,'string'));
mapData = get(figureNo,'UserData');
if(isfield(mapData,'gcp'))
    gcpNum = length(mapData.gcp) + 1;
else
    gcpNum = 1;
end
mapData.gcp{gcpNum} = [lats(:)';lons(:)'];
set(figureNo,'UserData',mapData);


%% --- Executes on button press in testInputs.
function testInputs_Callback(hObject, eventdata, handles)
fprintf('upper_lon = %f\n',str2num(get(handles.upper_lon,'string')));






%% ---- coord1_choose ----
function coord1_choose_Callback(hObject, eventdata, handles)
index = get(hObject,'value');
coords = load_locations();
set(handles.lat1,'string',num2str(coords(index).lat));
guidata(handles.lat1,handles);
set(handles.lon1,'string',num2str(coords(index).lon));
guidata(handles.lon1,handles);
guidata(hObject,handles);
update_range(handles);
update_azimuth(handles);
function coord1_choose_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
coords = load_locations();
for ii = 1:length(coords)
    list_string{ii} = coords(ii).name;
end
set(hObject,'string',list_string);
guidata(hObject,handles);

%% ---- coord2_choose ----
function coord2_choose_Callback(hObject, eventdata, handles)
index = get(hObject,'value');
coords = load_locations();
set(handles.lat2,'string',num2str(coords(index).lat));
guidata(handles.lat2,handles);
set(handles.lon2,'string',num2str(coords(index).lon));
guidata(handles.lon2,handles);
guidata(hObject,handles);
update_range(handles);
update_azimuth(handles);
function coord2_choose_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
coords = load_locations();
for ii = 1:length(coords)
    list_string{ii} = coords(ii).name;
end
set(hObject,'string',list_string);
guidata(hObject,handles);

%% load_locations
function coords = load_locations();
fid = fopen('locations.txt');
C = textscan(fid,'%s%s%s%*[^\n]');
fclose(fid);
for ii = 1:length(C{1})
    eval(['coords(ii).name= ''' C{1}{ii} ''';']);
    eval(['coords(ii).lat=' C{2}{ii} ';']);
    eval(['coords(ii).lon=' C{3}{ii} ';']);
end


%% ---- line_color ----
function line_color_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function line_color_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','b');
guidata(hObject,handles);


%% text_insert
function text_insert_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function text_insert_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','');
guidata(hObject,handles);

%% text_color
function text_color_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function text_color_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','k');
guidata(hObject,handles);

%% Executes on button press in insert_text1
function insert_text1_Callback(hObject, eventdata, handles)
lat1 = str2num(get(handles.lat1,'string'));
lon1 = str2num(get(handles.lon1,'string'));
h = figure(str2num(get(handles.mod_fig_no,'string')));
figure(h);
textm(lat1,lon1,get(handles.text_insert,'string'),'color',get(handles.text_color,'string'));


%% Executes on button press in insert_text2
function insert_text2_Callback(hObject, eventdata, handles)
lat2 = str2num(get(handles.lat2,'string'));
lon2 = str2num(get(handles.lon2,'string'));
h = figure(str2num(get(handles.mod_fig_no,'string')));
figure(h);
textm(lat2,lon2,get(handles.text_insert,'string'),'color',get(handles.text_color,'string'));




%% atd [arrival time difference in ms]
function atd_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function atd_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0');  %[ms]
guidata(hObject,handles);


%% Executes on button press in plot_atd
function plot_atd_Callback(hObject, eventdata, handles)
figureNo = str2num(get(handles.mod_fig_no,'string'));
lat1 = str2num(get(handles.lat1,'string'));
lon1 = str2num(get(handles.lon1,'string'));
lat2 = str2num(get(handles.lat2,'string'));
lon2 = str2num(get(handles.lon2,'string'));
v_c = str2num(get(handles.percent_c,'string'));
adt = str2num(get(handles.atd,'string'))/1e3;    %[s]
mapData = get(figureNo,'UserData');
lats_lons = mapData.latLonRanges;
color = get(handles.line_color,'string');

mapData = get(figureNo,'UserData');
if(isfield(mapData,'mapAxes') & length(mapData.mapAxes)>=figureNo & mapData.mapAxes(figureNo)~=0);
    mapAxes = mapData.mapAxes(figureNo);
else
    figure(figureNo);
    mapAxes = 0;
end
c = plotATDGrid(lats_lons(1:2),lats_lons(3:4),lat1,lon1,lat2,lon2,v_c,mapAxes,adt,color);
if(isfield(mapData,'atdContours'))
    contourNum = length(mapData.atdContours) + 1;
else
    contourNum = 1;
end
mapData.atdContours{contourNum} = c;    %first row lat, second row lon
set(figureNo,'UserData',mapData);


%% Executes on button press in plot_atd_grid
function plot_atd_grid_Callback(hObject, eventdata, handles)
figureNo = str2num(get(handles.mod_fig_no,'string'));
lat1 = str2num(get(handles.lat1,'string'));
lon1 = str2num(get(handles.lon1,'string'));
lat2 = str2num(get(handles.lat2,'string'));
lon2 = str2num(get(handles.lon2,'string'));
v_c = str2num(get(handles.percent_c,'string'));
mapData = get(figureNo,'UserData');
lats_lons = mapData.latLonRanges;
if(isfield(mapData,'mapAxes') & length(mapData.mapAxes)>=figureNo & mapData.mapAxes(figureNo)~=0);
    mapAxes = mapData.mapAxes(figureNo);
else
    figure(figureNo);
    mapAxes = 0;
end
plotATDGrid(lats_lons(1:2),lats_lons(3:4),lat1,lon1,lat2,lon2,v_c,mapAxes);


%% percent_c 
function percent_c_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function percent_c_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','1');
guidata(hObject,handles);



%% circleDistances
function circleDistances_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function circleDistances_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','1e3,2e3,3e3');  %[km]
guidata(hObject,handles);



%% circleAzimuths
function circleAzimuths_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function circleAzimuths_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0,360');  %[deg]
guidata(hObject,handles);



%% Executes on button press in addCirclesCoord1
function addCirclesCoord1_Callback(hObject, eventdata, handles)
lat1 = str2num(get(handles.lat1,'string'));
lon1 = str2num(get(handles.lon1,'string'));
figureNo = str2num(get(handles.mod_fig_no,'string'));
figure(figureNo);
circleAzimuths = str2num(get(handles.circleAzimuths,'string'));
circleDistances = str2num(get(handles.circleDistances,'string'));
line_color = get(handles.line_color,'string');
addCirclesAndAzimuths(figureNo,lat1,lon1,circleDistances,circleAzimuths,[],[],line_color);

%% Executes on button press in addCirclesCoord2
function addCirclesCoord2_Callback(hObject, eventdata, handles)
lat2 = str2num(get(handles.lat2,'string'));
lon2 = str2num(get(handles.lon2,'string'));
figureNo = str2num(get(handles.mod_fig_no,'string'));
figure(figureNo);
circleAzimuths = str2num(get(handles.circleAzimuths,'string'));
circleDistances = str2num(get(handles.circleDistances,'string'));
line_color = get(handles.line_color,'string');
addCirclesAndAzimuths(figureNo,lat2,lon2,circleDistances,circleAzimuths,[],[],line_color);


%% GCPDistances
function GCPDistances_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function GCPDistances_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','1e3,3e3');  %[deg]
guidata(hObject,handles);


%% GCPAzimuths
function GCPAzimuths_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
function GCPAzimuths_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'string','0,90,180,270');  %[deg]
guidata(hObject,handles);



%% Executes on button press in emanateGCPCoord1
function emanateGCPCoord1_Callback(hObject, eventdata, handles)
lat1 = str2num(get(handles.lat1,'string'));
lon1 = str2num(get(handles.lon1,'string'));
figureNo = str2num(get(handles.mod_fig_no,'string'));
figure(figureNo);
GCPAzimuths = str2num(get(handles.GCPAzimuths,'string'));
GCPDistances = str2num(get(handles.GCPDistances,'string'));
line_color = get(handles.line_color,'string');
addCirclesAndAzimuths(figureNo,lat1,lon1,[],[],GCPAzimuths,GCPDistances,line_color);


%% Executes on button press in emanateGCPCoord2
function emanateGCPCoord2_Callback(hObject, eventdata, handles)
lat2 = str2num(get(handles.lat2,'string'));
lon2 = str2num(get(handles.lon2,'string'));
figureNo = str2num(get(handles.mod_fig_no,'string'));
figure(figureNo);
GCPAzimuths = str2num(get(handles.GCPAzimuths,'string'));
GCPDistances = str2num(get(handles.GCPDistances,'string'));
line_color = get(handles.line_color,'string');
addCirclesAndAzimuths(figureNo,lat2,lon2,[],[],GCPAzimuths,GCPDistances,line_color);

