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
ad.handles = guihandles(hf);

% Save the application data
guidata(hf,ad)

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
    ad.var.rriOriginal = ad.var.rri;
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
plot(time, ad.var.rri, 'g');
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

