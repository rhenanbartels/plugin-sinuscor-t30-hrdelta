function SinusCorPlugin()
hf = figure('Tag',mfilename,...
    'MenuBar','None',...
    'IntegerHandle','off',...
    'Resize','off',...
    'NumberTitle','off',...
    'Name',sprintf('SinusCor Plugin - T30 and HR delta'),...
    'Visible','on',...
    'Position',[180,50,850,600] ,...
    'Tag','mainfig',...
    'Color',[0.047,0.047,0.047]);

ha1 = axes('Parent',hf,...
    'HandleVisibility','callback',...
    'Unit','normalized',...
    'OuterPosition',[0.0 0.35 1 0.54],...
    'Visible','On',...
    'Color',[0,0,0],...
    'Xlim',[0 10],...
    'YLim',[-1 1],...
    'Tag','plotAxes1');

box(ha1,'on');
grid(ha1, 'on');
set(ha1,'XColor',[1,1,1]);
set(ha1,'YColor',[1,1,1]);

hhpd = uimenu('Parent',hf,...
    'Label','File',...
    'Tag','filemenu');

uimenu('Parent',hhpd,...
    'Label','Open RRi',...
    'Callback',@openRRi,...
    'Tag','openRRi',...
    'Enable','On',...
    'Acc', 'O');

uicontrol('Parent',hf,...
    'Units', 'Normalized',...
    'String','Set line',...
    'FontWeight','Bold',...
    'BackGroundColor',[0.334,0.334,0.334],...
    'Position',[0.025, 0.01, 0.055, 0.05],...
    'Tag','btnsetline',...
    'Visible','On',...
    'Enable', 'Off',...
    'CallBack', @placeLine);

uicontrol('Parent',hf,...
    'Units', 'Normalized',...
    'String','Analyze',...
    'FontWeight','Bold',...
    'BackGroundColor',[0.334,0.334,0.334],...
    'Position',[0.085, 0.01, 0.055, 0.05],...
    'Tag','btnanalysis',...
    'Visible','On',...
    'Enable', 'Off',...
    'CallBack', @analyze);

hhf = uimenu('Parent',hf,...
    'Label','Figure',...
    'Tag','figmenu');

uimenu('Parent',hhf,...
    'Label','Zoom On',...
    'Callback','zoom on',...
    'Tag','openRRi',...
    'Enable','On',...
    'Acc', 'Z');

uimenu('Parent',hhf,...
    'Label','Zoom Off',...
    'Callback','zoom off',...
    'Tag','openRRi',...
    'Enable','On',...
    'Acc', 'X');

ad.handles = guihandles(hf);

% Save the application data
guidata(hf,ad)

end

function analyze(hObject, eventdata)
ad = guidata(hObject);
result_t30 = t30(ad.handles.line_1, ad.var.rri);
end

function placeLine(hObject, eventdata)
plotLine(hObject, eventdata);
end

function openRRi(hObject, eventdata)
ad = guidata(hObject);
[Name, PathName] = uigetfile(...
    {'*.txt','RRi Files (*.txt)'},...
    'Choose a RRi File');

if Name
    try
        rri = load([PathName Name]);
    catch err
        if strcmp(err.identifier, 'MATLAB:load:unknownText')
            errordlg(err.message, 'File Error','modal')
        end
        return
    end
    
    rri(rri == 0) = [];
    ad.var.rri = rri;
    if mean(ad.var.rri) < 50
        ad.var.rri = ad.var.rri * 1000;
    end
    set(ad.handles.btnsetline, 'Enable', 'On');
    set(ad.handles.btnanalysis, 'Enable', 'Off');
    ad.var.rriOriginal = ad.var.rri;
    cla(ad.handles.plotAxes1);
    if isfield(ad.handles, 'line_1')
        ad.handles = rmfield(ad.handles, 'line_1');
    end
    guidata(hObject,ad);
    makePlots(hObject, eventdata);
    
end
end

function makePlots(hObject,eventdata)
%get the application data
ad = guidata(hObject);
axes(ad.handles.plotAxes1)
time = cumsum(ad.var.rri)/1000;
time = time - time(1);
plot(time, ad.var.rri, 'g.-');
set(gca, 'Color',[0,0,0]);
box(gca, 'on');
grid(gca,'on');
set(gca, 'XColor',[1,1,1]);
set(gca, 'YColor',[1,1,1]);
title(gca, 'Tachogram','Color',[1,1,1])
xlabel(gca,'Time (s)');
ylabel(gca, 'RRi (ms)', 'Color', [1 1 1]);
axis(gca, 'tight');
end

function plotLine(hObject,eventdata)

ad = guidata(hObject);
if isfield(ad.handles, 'line_1')
    return
end
y_lim = get(ad.handles.plotAxes1, 'ylim');

t1 = 600;
color = 'r';
l1 = line([t1, t1], [y_lim(1), y_lim(2)], 'Color', color,...
    'Linewidth', 3, 'ButtonDownFcn', @l1_fcn, 'Tag', 'line-axes');

ad.handles.line_1 = l1;

    function move_line(hObject, eventdata, l)
        ad = guidata(hObject);
        current_point = get(ad.handles.plotAxes1, 'CurrentPoint');
        
        current_line_position = get(l, 'xdata');
        
        x_lim = get(gca, 'xlim');
        
        if current_line_position(1) >= x_lim(1) &&...
                current_line_position(1) <= x_lim(2)
            
            set(l, 'xdata', [current_point(1), current_point(1)])
            
        end
        
        current_line_position = get(l, 'xdata');
        if current_line_position(1) < x_lim(1)
            set(l, 'xdata', [0, 0])
        elseif current_line_position(1) > x_lim(2)
            set(l, 'xdata', [3, 3])
        end
        
        guidata(hObject,ad);
    end

    function l1_fcn(hObject, eventdata)
        handles = guidata(hObject);
        
        l1 = findobj(ad.handles.mainfig, 'tag', 'line-axes');
        
        set(ad.handles.mainfig, 'WindowButtonMotionFcn', {@move_line, l1});
        set(ad.handles.mainfig, 'WindowButtonUpFcn', @drop_line)
        
    end
    function drop_line(hObject, eventdata)
        set(ad.handles.mainfig, 'WindowButtonMotionFcn', '');
    end
set(ad.handles.btnanalysis, 'Enable', 'On');
guidata(hObject,ad);
end


function result = t30(line_1, rri)
time = cumsum(rri)/1000;
time = time - time(1);
line_time = line_1.XData(1);
end_time = line_time + 30;

rri_t30 = rri(time >= line_time & time <= end_time);
time_t30 = time(time >= line_time & time <= end_time);
ln_rri_t30 = log(rri_t30);
t30_fit = polyfit(time_t30, ln_rri_t30, 1);
regular_fit = polyfit(time_t30, rri_t30, 1);
% https://pubmed.ncbi.nlm.nih.gov/7930286/
result = - 1 / t30_fit(1);  % negative reciprocal of the slope of the regression line
hold on
fit_curve = regular_fit(1) * time_t30 + regular_fit(2);
plot(time_t30, fit_curve, 'b', 'LineWidth', 3);
end
