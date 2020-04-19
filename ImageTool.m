function varargout = ImageTool(varargin)
% IMAGETOOL MATLAB code for ImageTool.fig
%      IMAGETOOL, by itself, creates a new IMAGETOOL or raises the existing
%      singleton*.
%
%      H = IMAGETOOL returns the handle to a new IMAGETOOL or the handle to
%      the existing singleton*.
%
%      IMAGETOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGETOOL.M with the given input arguments.
%
%      IMAGETOOL('Property','Value',...) creates a new IMAGETOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageTool

% Last Modified by GUIDE v2.5 19-Apr-2020 13:57:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageTool_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageTool_OutputFcn, ...
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
end

% --- Executes just before ImageTool is made visible.
function ImageTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageTool (see VARARGIN)

% Choose default command line output for ImageTool
handles.output = hObject;

% Null state
global state;
state = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

function initiate_app_state(origin,origin_path)
    global state;
    state = struct;
    state.origin_image = origin;
    state.result_image = origin;
    state.origin_path = origin_path;
    state.is_modified = false;
    state.history = {origin};
    state.history_idx = 1;
end

% --- Outputs from this function are returned to the command line.
function varargout = ImageTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function EditMenu_Callback(hObject, eventdata, handles)
% hObject    handle to EditMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function TransformMenu_Callback(hObject, eventdata, handles)
% hObject    handle to TransformMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

function submit_change(handles)
    global state;

    len = size(state.history,2);
    for i=state.history_idx+1:len
        state.history(state.history_idx+1)=[];
    end
    
    len=state.history_idx;
    state.history{len+1} = state.result_image;
    state.history_idx = len+1;
    state.is_modified = true;

    handles.Save.Enable=true;
    handles.Redo.Enable=false;
    handles.Undo.Enable=true;
end

function show_result(handles)
    global state;
    axes(handles.ResultAxes);
    imshow(state.result_image);
    
    [h,w,~]=size(state.origin_image);
    axes(handles.OriginAxes);
    xlabel(num2str(w)+"×"+num2str(h));
    
    [h,w,~]=size(state.result_image);
    axes(handles.ResultAxes);
    xlabel(num2str(w)+"×"+num2str(h));
end

% --------------------------------------------------------------------
function Translate_Callback(hObject, eventdata, handles)
% hObject    handle to Translate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state;
    prompt = ["X 轴像素移动量","Y 轴像素移动量"];
    answer = inputdlg(prompt,"平移变换",[1,35;1,35],["0","0"]);
    if isequal(answer,{})
        return
    end

    dx = str2double(answer{1});
    dy = str2double(answer{2});
    if isnan(dx) || isnan(dy) || floor(dx)~=dx || floor(dy)~=dy
        errordlg("无效数字");
        return
    end
    
    dx=floor(dx);
    dy=floor(dy);

    se = translate(strel(1),[dx,dy]);
    state.result_image = imdilate(state.result_image, se);

    submit_change(handles);
    show_result(handles);
end

% --------------------------------------------------------------------
function Reflect_Callback(hObject, eventdata, handles)
% hObject    handle to Reflect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    opt = questdlg("镜像方向","镜像","水平","垂直","水平");
    switch opt
        case "水平"
            direction = 1;
        case "垂直"
            direction = 2;
        otherwise
            return
    end
    
    global state;
    switch direction
        case 1
            state.result_image = fliplr(state.result_image);
        case 2
            state.result_image = flipud(state.result_image);
    end
    
    submit_change(handles);
    show_result(handles);
end

% --------------------------------------------------------------------
function Rotate_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    answer = inputdlg("旋转角度","旋转变换",[1,35],"0");
    if isequal(answer,{})
        return
    end

    angle = str2double(answer);
    if isnan(angle)
        errordlg("无效数字");
        return
    end
    
    global state;
    state.result_image = imrotate(state.result_image,angle);
    
    submit_change(handles);
    show_result(handles);
end

% --------------------------------------------------------------------
function Scale_Callback(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
    global state;
    [h,w,~] = size(state.result_image);
    
    prompt = ["宽度","高度"];
    answer = inputdlg(prompt,"缩放变换",[1,35],{num2str(w);num2str(h)});
    if isequal(answer,{})
        return
    end

    w = str2double(answer{1});
    h = str2double(answer{2});
    if isnan(w) || isnan(h)
        errordlg("无效数字");
        return
    end

    state.result_image = imresize(state.result_image,[h,w]);

    submit_change(handles);
    show_result(handles);
end

% --------------------------------------------------------------------
function Crop_Callback(hObject, eventdata, handles)
% hObject    handle to Crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state; 
    lock_edit(handles);
    
    ret = imcrop(handles.ResultAxes);
    if isequal(ret,[])
        unlock_edit();
        return;
    end

    state.result_image=ret;
    submit_change(handles);
    show_result(handles);
    unlock_edit(handles);
end

% --------------------------------------------------------------------
function Undo_Callback(hObject, eventdata, handles)
% hObject    handle to Undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state;

    assert(state.history_idx>1);
    
    state.history_idx = state.history_idx - 1;
    if state.history_idx==1
        handles.Undo.Enable=false;
    end

    state.result_image = state.history{state.history_idx};
    state.is_modified=true;
    show_result(handles);

    handles.Save.Enable=true;
    handles.Redo.Enable=true;
end

% --------------------------------------------------------------------
function Redo_Callback(hObject, eventdata, handles)
% hObject    handle to Redo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state;
    len = size(state.history,2);
    assert(state.history_idx<len);
    
    state.history_idx = state.history_idx + 1;
    if state.history_idx==len
        handles.Redo.Enable=false;
    end

    state.result_image = state.history{state.history_idx};
    state.is_modified=true;

    show_result(handles);
    handles.Save.Enable=true;
    handles.Undo.Enable=true;
end

% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state;
    if ~isequal(state, 0)
        Close_Callback(hObject,eventdata,handles)
        if ~isequal(state, 0)
            return
        end
    end

    [file, path] = uigetfile(["*.tif";"*.png";"*.jpg"]);
    if isequal(file,0)
        return % canceled
    end

    % try open file
    origin_path = fullfile(path,file);
    try
        origin = imread(origin_path);
    catch me
        errordlg("打开失败")
        rethrow(me)
    end

    initiate_app_state(origin,origin_path);

    % sync associated gui state
    handles.SaveAs.Enable = true;
    handles.EditMenu.Enable = true;
    handles.Close.Enable = true;
    handles.TransformMenu.Enable = true;
    handles.OriginTitle.Visible = true;
    handles.ResultTitle.Visible = true;

    % show image
    origin_axes = handles.OriginAxes;
    result_axes = handles.ResultAxes;

    axes(origin_axes);
    imshow(origin);
    axes(result_axes);
    imshow(origin);
    
    [h,w,~]=size(state.origin_image);
    axes(handles.OriginAxes);
    xlabel(num2str(w)+"×"+num2str(h));

    [h,w,~]=size(state.result_image);
    axes(handles.ResultAxes);
    xlabel(num2str(w)+"×"+num2str(h));
end

% --------------------------------------------------------------------
function SaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file, path] = uiputfile(["*.tif";"*.png";"*.jpg"]);
    if isequal(file,0)
        return
    end
    global state;
    try
        imwrite(state.result_image, fullfile(path,file));
    catch me
        errordlg("另存为失败")
        rethrow(me)
    end
end

% --------------------------------------------------------------------
function AffineTransform_Callback(hObject, eventdata, handles)
% hObject    handle to AffineTransform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state;
    
    answer = inputdlg("变换矩阵(3x3)"," 仿射变换",[1,50],"");
    if isequal(answer,{})
        return
    end

    try
        mat = str2num(answer{1});
        mat = reshape(mat,3,3);
        tf = maketform("affine",mat);

        [h,w,~] = size(state.result_image);
        xd = [1, w];
        yd = [1, h];
        ret = imtransform(state.result_image,tf,"XData",xd,"YData",yd);
    catch me
        errordlg("变换失败");
        rethrow(me);
    end
    
    state.result_image=ret;
    submit_change(handles);
    show_result(handles);
end

% --------------------------------------------------------------------
function ProjectionTransform_Callback(hObject, eventdata, handles)
% hObject    handle to ProjectionTransform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state;
    
    answer = inputdlg("变换矩阵(3x3)"," 投影变换",[1,50],"");
    if isequal(answer,{})
        return
    end

    try
        mat = str2num(answer{1});
        mat = reshape(mat,3,3);
        tf = maketform("projective",mat);
        disp(tf);
        
        [h,w,~] = size(state.result_image);
        xd = [1, w];
        yd = [1, h];
        ret = imtransform(state.result_image,tf,"XData",xd,"YData",yd);
    catch me
        errordlg("变换失败");
        rethrow(me);
    end

    state.result_image=ret;
    submit_change(handles);
    show_result(handles);
end

% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state;
    try
        imwrite(state.result_image, state.origin_path);
    catch me
        errordlg("保存失败");
        rethrow(me)
    end
    state.is_modified = false;
    handles.Save.Enable=false;
end

% --------------------------------------------------------------------
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global state;
    if state.is_modified
        opt = questdlg("您还未保存","关闭","强制关闭","取消","取消");
        switch opt
            case "强制关闭"
                % continue
            case "取消"
                return
            otherwise
                return
        end
    end

    % clear app state
    state = 0;

    reset_gui_state(handles);

    delete(allchild(handles.OriginAxes));
    delete(allchild(handles.ResultAxes));
    delete(handles.OriginAxes.XLabel);
    delete(handles.ResultAxes.XLabel);
end


% --------------------------------------------------------------------
function AboutMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AboutMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    msgbox([...
        "仓库: https://github.com/Nugine/ImageTool";...
        "日期: 2020 年 4 月 19 日"...
    ],"关于");
end

function lock_edit(handles)
    handles.EditMenu.Enable = false;
    handles.TransformMenu.Enable = false;
end

function unlock_edit(handles)
    handles.EditMenu.Enable = true;
    handles.TransformMenu.Enable = true;
end

function reset_gui_state(handles)
    handles.Save.Enable = false;
    handles.SaveAs.Enable = false;
    handles.Close.Enable = false;
    handles.EditMenu.Enable = false;
    handles.Undo.Enable = false;
    handles.Redo.Enable = false;
    handles.TransformMenu.Enable = false;
    handles.OriginTitle.Visible = false;
    handles.ResultTitle.Visible = false;
end