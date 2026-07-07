

close all, clear all, clc
addpath (pwd);
%% Browse to files
fprintf(1,'<strong>>>> Select DATA directory for files</strong>\n' )
Maindatapath = uigetdir('/');
Maindatapath = ([Maindatapath '/']);
cd (Maindatapath);
%% Browse to bioformats
%fprintf(1,'<strong>>>> Select bioformats directory</strong>\n' )
%bioformats_path = uigetdir('D:/','Select bioformats directory');
bioformats_path = '/Users/yiangospsaras/Documents/MATLAB/bfmatlab';
bioformats_paths = [bioformats_path, '/'];
addpath(bioformats_paths);

%% Select which vids are saved calcium or contractility 
figure = dialog('position', [900 500 500 300], 'Name', '                 Please select required output');

uicontrol('Parent', figure, 'Style', 'text', 'Position', [140 35 200 250], ...
      'String',['Select the required output'])
uicontrol('Parent', figure, 'Style', 'text', 'Position', [30 45 430 30], ...
      'String','Note: Contractility tifs will be saved as an intermediate to avis and will be marked for deletion if not required ')

handles.label = {'Calcium' 'Contractility'};
 handles.push = uicontrol(figure, 'style', 'pushbutton','Units','pixels',...
     'position', [130 20 240 18], 'String','OK');
 
handles.h_checkbox(1) = uicontrol(figure,'Style','checkbox','String', ...
    ('  Dual channel Calcium only (TIF)'),'Position', [40 220 200 45]);
handles.h_checkbox(2) = uicontrol(figure,'Style','checkbox','String', ...
    ('  Dual channel Contractility only (AVI)'),'Position', [270 220 280 45]);
handles.h_checkbox(3) = uicontrol(figure,'Style','checkbox','String', ...
    ("  Dual channel Contractity only (TIF)"),'Position', [ 40 190 240 45]);
handles.h_checkbox(4) = uicontrol(figure,'Style','checkbox','String', ...
    ('  General TIF -> AVI'),'Position', [40 160 200 45]);
handles.h_checkbox(5) = uicontrol(figure,'Style','checkbox','String', ...
    ('  Dual Channel (both AVI)'),'Position', [270 190 180 45]);
handles.h_checkbox(6) = uicontrol(figure,'Style','checkbox','String', ...
    ('  Single Channel AVI'),'Position', [270 160 240 45]);
handles.h_checkbox(7) = uicontrol(figure,'Style','checkbox','String', ...
    ('  Dual Channel (both TIF)'),'Position', [40 130 240 45]);
handles.h_checkbox(8) = uicontrol(figure,'Style','checkbox','String', ...
    ('  Single Channel TIF'),'Position', [270 130 240 45]);
handles.h_checkbox(9) = uicontrol(figure,'Style','checkbox','String', ...
    ('  Single Channel Calcium AVI'),'Position', [40 100 240 45]);

set(handles.push, 'callback', @enter_call);
guidata(figure,handles);
pause(10)
%%
%% Input file format
if DoWhat{4,1} ~=1
prompt = {'\bf \fontsize{12} Please enter the format of your videos (eg .avi):',...
    };
dlgtitle = 'Video format';
dims = [1 88];
definput = {'.nd2'};
opts.Interpreter = 'tex';
prt = inputdlg(prompt,dlgtitle,dims,definput, opts);

frmt = char (prt{1,1} );
frmt = frmt(1:end);
fprintf(1,'\n') 



%% Find files to convert
FilePattern = fullfile(Maindatapath,['*',frmt]);
fileList = dir(FilePattern);

Nums = size (fileList,1);
fprintf (1, '<strong>>>> Number of files to convert:</strong>%s\n'), disp (Nums)
end


%% Calcium TIF
%% Save calcium TIF
if DoWhat{1,1} ==1 
fprintf(1,'\n')
fprintf (1, '<strong>>>> Extracting calcium from dual channel videos as TIF </strong>%s'),  fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

    mkdir ('Calcium')
    for fn = 1:Nums
d = squeeze(bfopen(fileList(fn).name));
for e = 1:size(d{1,1},1)
    fe(:,:,e) = d{1,1}{e,1};
end
de = uint8(255*scaleMinMax(double(fe)));

Cakeep = (2:2:size(de,3));
Calcium = de(:,:,Cakeep);
Calc = squeeze((Calcium));
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de

  fprintf (1, '<strong>>>> Saving calcium tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Calc,3)
  outfile = fullfile(Maindatapath,'/Calcium/',sprintf('%sCalcium.tif',name));
  imwrite(Calc(:, :, K),outfile , 'WriteMode', 'append');
  end
end
end



%% Contractility AVI
if DoWhat{2,1} ==1 
fprintf(1,'\n')
fprintf (1, '<strong>>>> Extracting sarcomeres from dual channel videos as AVI </strong>%s'),  fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

%% First make sarcomere TIF
mkdir ('Converted Files')
for fn = 1:Nums
d = squeeze(bfopen(fileList(fn).name));
for e = 1:size(d{1,1},1)
    fe(:,:,e) = d{1,1}{e,1};
end
de = uint8(255*scaleMinMax(double(fe)));

Sakeep = (1:2:size(de,3));
Sarcomeres = de(:,:,Sakeep); 
Sarc = squeeze(Sarcomeres);
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de

  fprintf (1, '<strong>>>> Saving tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Sarc,3)
  outfile = fullfile(Maindatapath,'/Converted Files/',sprintf('%sSarcomeres.tif',name));
  imwrite(Sarc(:, :, K),outfile , 'WriteMode', 'append');
  end
end

%% Read sarcomere .tifs
cd ([Maindatapath, '/Converted Files/']);

FilePatternSarc = fullfile(Maindatapath,'/Converted Files/',['*','.tif']);
fileListSarc = dir(FilePatternSarc);

NumsSarc = length (fileListSarc);
fprintf (1, '<strong>>>> Number of files to convert:</strong>%s\n'), disp (Nums)

for fn = 1:NumsSarc
  de = squeeze(bfopen(fileListSarc(fn).name));

for ked = 1:length (de{1,1})
kedi(:,:,ked) = de {1,1}{ked,1};
end

  Sarc = kedi;
  ComSarc(:,:,1,:) = Sarc ;

%% Convert sarcomere .tifs & save as AVI

  [filepath,name,ext] = fileparts(fileListSarc(fn).name);
  v = VideoWriter(sprintf('%s.avi',name),['Uncompressed AVI']);
  open(v)
  writeVideo(v,ComSarc)
  close(v)
  clear ('ComSarc', 'Sarc', 'de');
end

fprintf(1,'\n')
fprintf (1, '<strong>>>> Done! Number of videos converted:</strong>%s'), disp (Nums), fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')
% 
end


%% Contractility TIF
%% Save Sarcomere TIF
if DoWhat{3,1} ==1 
fprintf(1,'\n')
fprintf (1, '<strong>>>> Extracting sarcomeres from dual channel videos as TIF </strong>%s'),  fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

mkdir ('Sarcomeres')
    for fn = 1:Nums
d = squeeze(bfopen(fileList(fn).name));
for e = 1:size(d{1,1},1)
    fe(:,:,e) = d{1,1}{e,1};
end
de = uint8(255*scaleMinMax(double(fe)));

Sakeep = (1:2:size(de,3));

Sarcomeres = de(:,:,Sakeep); 
Sarc = squeeze(Sarcomeres);
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de

  fprintf (1, '<strong>>>> Saving sarcomere tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Sarc,3)
  outfile = fullfile(Maindatapath,'/Sarcomeres/',sprintf('%sSarcomeres.tif',name));
  imwrite(Sarc(:, :, K),outfile , 'WriteMode', 'append');
  end
    end
fprintf (1, '<strong>>>> Done! Number of videos converted:</strong>%s'), disp (Nums), fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

end


%% TIF -> AVI
%% Convert TIF to AVI
if DoWhat{4,1} ==1 
fprintf(1,'\n')
fprintf (1, '<strong>>>> Converting single channel TIFs to  AVIs </strong>%s'),  fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

cd ([Maindatapath]);

FilePatternSarc = fullfile(Maindatapath,['*','.tif']);
fileListSarc = dir(FilePatternSarc);
Nums = length (fileListSarc);
for fn = 1:length (fileListSarc)
  de = squeeze(bfopen(fileListSarc(fn).name));

for ked = 1:length (de{1,1})
kedi(:,:,ked) = de {1,1}{ked,1};
end

  Sarc = kedi;
  ComSarc(:,:,1,:) = Sarc ;

%% Convert sarcomere .tifs & save as AVI
  [filepath,name,ext] = fileparts(fileListSarc(fn).name);
  v = VideoWriter(sprintf('%s.avi',name),['Uncompressed AVI']);
  open(v)
  writeVideo(v,ComSarc)
  close(v)
  clear ('ComSarc', 'Sarc', 'de');
end

fprintf(1,'\n')
fprintf (1, '<strong>>>> Done! Number of videos converted:</strong>%s'), disp (Nums), fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')
end



%%DUAL CHANNEL AVI
if DoWhat{5,1} ==1 
fprintf(1,'\n')
fprintf (1, '<strong>>>> Converting dual channel video to separate AVIs </strong>%s'),  fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

%% First make sarcomere TIF
mkdir ('Sarcomeres')
for fn = 1:Nums
d = squeeze(bfopen(fileList(fn).name));
for e = 1:size(d{1,1},1)
    fe(:,:,e) = d{1,1}{e,1};
end
de = uint8(255*scaleMinMax(double(fe)));

Sakeep = (1:2:size(de,3));

Sarcomeres = de(:,:,Sakeep); 
Sarc = squeeze(Sarcomeres);
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de

  fprintf (1, '<strong>>>> Saving sarcomere tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Calc,3)
  outfile = fullfile(Maindatapath,'/Sarcomeres/',sprintf('%sSarcomeres.tif',name));
  imwrite(Sarc(:, :, K),outfile , 'WriteMode', 'append');
  end
end

%% Read sarcomere .tifs
cd ([Maindatapath, '/Sarcomeres/']);

FilePatternSarc = fullfile(Maindatapath,'/Sarcomeres/',['*','.tif']);
fileListSarc = dir(FilePatternSarc);

NumsSarc = length (fileListSarc);
fprintf (1, '<strong>>>> Number of files to convert:</strong>%s\n'), disp (Nums)

for fn = 1:NumsSarc
  de = squeeze(mybfopen(fileListSarc(fn).name));

  
for ked = 1:length (de{1,1})
kedi(:,:,ked) = de {1,1}{ked,1};
end

  Sarc = kedi;
  ComSarc(:,:,1,:) = Sarc ;
  

%% Convert sarcomere .tifs & save as AVI
  [filepath,name,ext] = fileparts(fileListSarc(fn).name);
  v = VideoWriter(sprintf('%s.avi',name),['Uncompressed AVI']);
  open(v)
  writeVideo(v,ComSarc)
  close(v)
  clear ('ComSarc', 'Sarc', 'de');
end

fprintf(1,'\n')
fprintf (1, '<strong>>>> Done! Number of videos converted:</strong>%s'), disp (Nums), fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')
% 

mkdir ('Calcium')
for fn = 1:Nums
d = squeeze(bfopen(fileList(fn).name));
for e = 1:size(d{1,1},1)
    fe(:,:,e) = d{1,1}{e,1};
end
de = uint8(255*scaleMinMax(double(fe)));

Cakeep = (2:2:size(de,3));

Calcium = de(:,:,Cakeep);
Calc = squeeze((Calcium));
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de

  fprintf (1, '<strong>>>> Saving calcium tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Calc,3)
  outfile = fullfile(Maindatapath,'/Calcium/',sprintf('%sCalcium.tif',name));
  imwrite(Calc(:, :, K),outfile , 'WriteMode', 'append');
  end
end

%% Read calcium .tifs
cd ([Maindatapath, '/Calcium/']);

FilePatternSarc = fullfile(Maindatapath,'/Sarcomeres/',['*','.tif']);
fileListSarc = dir(FilePatternSarc);

NumsSarc = length (fileListSarc);
fprintf (1, '<strong>>>> Number of files to convert:</strong>%s\n'), disp (Nums)

for fn = 1:NumsSarc
  de = squeeze(mybfopen(fileListSarc(fn).name));

for ked = 1:length (de{1,1})
kedi(:,:,ked) = de {1,1}{ked,1};
end

  Sarc = kedi;
  ComSarc(:,:,1,:) = Sarc ;

%% Convert calcium .tifs & save as AVI
  [filepath,name,ext] = fileparts(fileListSarc(fn).name);
  v = VideoWriter(sprintf('%s.avi',name),['Uncompressed AVI']);
  open(v)
  writeVideo(v,ComSarc)
  close(v)
  clear ('ComSarc', 'Sarc', 'de');
end

fprintf(1,'\n')
fprintf (1, '<strong>>>> Done! Number of videos converted:</strong>%s'), disp (Nums), fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

end


if DoWhat{6,1} ==1 
fprintf(1,'\n')
fprintf (1, '<strong>>>> Converting single channel videos as AVI </strong>%s'),  fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

%% First make TIF
mkdir ('AVIs')
for fn = 1:Nums
da = squeeze(squeeze(bfopen(fileList(fn).name)));
for k = 1:length(da{1,1})
    fe(:,:,k) = da{1,1}{k,1};
end

de = uint8(255*scaleMinMax(double(fe)));

Sarc = squeeze(de);
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de

  fprintf (1, '<strong>>>> Saving tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Sarc,3)
  outfile = fullfile(Maindatapath,'/AVIs/',sprintf('%s.tif',name));
  imwrite(Sarc(:, :, K),outfile , 'WriteMode', 'append');
  end
end

%% Find TIFs
cd ([Maindatapath, '/AVIs/']);

FilePatternSarc = fullfile(Maindatapath,'/AVIs/',['*','.tif']);
fileListSarc = dir(FilePatternSarc);

NumsSarc = length (fileListSarc);
fprintf (1, '<strong>>>> Number of files to convert:</strong>%s\n'), disp (Nums)

for fn = 1:NumsSarc
  de = squeeze(bfopen(fileListSarc(fn).name));
  
for ked = 1:length (de{1,1})
kedi(:,:,ked) = de {1,1}{ked,1};
end

  Sarc = kedi;
  ComSarc(:,:,1,:) = Sarc ;

%% Convert .tifs & save as AVI
  [filepath,name,ext] = fileparts(fileListSarc(fn).name);
  v = VideoWriter(sprintf('%s.avi',name),['Uncompressed AVI']);
  open(v)
  writeVideo(v,ComSarc)
  close(v)
  clear ('ComSarc', 'Sarc', 'de');
end

fprintf(1,'\n')
fprintf (1, '<strong>>>> Done! Number of videos converted:</strong>%s'), disp (Nums), fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')
end


%% Dual Channel to TIF
if DoWhat{7,1} ==1 

fprintf(1,'\n')
fprintf (1, '<strong>>>> Converting dual channel videos to individual TIFs </strong>%s'),  fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

  mkdir('Calcium')
  mkdir('Sarcomeres')
for fn = 1:Nums
d = squeeze(bfopen(fileList(fn).name));
for e = 1:size(d{1,1},1)
    fe(:,:,e) = d{1,1}{e,1};
end
de = uint8(255*scaleMinMax(double(fe)));

Cakeep = (2:2:size(de,3));
Sakeep = (1:2:size(de,3));

Calcium = de(:,:,Cakeep);
Calc = squeeze((Calcium));
Sarcomeres = de(:,:,Sakeep); 
Sarc = squeeze(Sarcomeres);
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de
%% Save Calcium as tif
  fprintf (1, '<strong>>>> Saving calcium tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Calc,3)
  outfile = fullfile(Maindatapath,'/Calcium/',sprintf('%sCalcium.tif',name));
  imwrite(Calc(:, :, K),outfile , 'WriteMode', 'append');
  end

%% Save Sarcomeres as tif
  fprintf (1, '<strong>>>> Saving sarcomere tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Sarc,3)
  outfile = fullfile(Maindatapath,'/Sarcomeres/',sprintf('%sSarcomeres.tif',name)); 
  imwrite(Sarc(:, :, K),outfile, 'WriteMode', 'append');
  end
end
end


%% Single Channel to TIF
if DoWhat{8,1} ==1 
fprintf(1,'\n')
fprintf (1, '<strong>>>> Converting single channel videos to TIF </strong>%s'),  fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')

%% First make TIF
mkdir ('TIFs')
for fn = 1:Nums
d = squeeze(bfopen(fileList(fn).name));
for e = 1:size(d{1,1},1)
    fe(:,:,e) = imresize(d{1,1}{e,1},0.5);
end
de = uint8(255*scaleMinMax(double(fe)));

Sarc = squeeze(de);
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de

  fprintf (1, '<strong>>>> Saving tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Sarc,3)
  outfile = fullfile(Maindatapath,'/TIFs/',sprintf('%s.tif',name));
  imwrite(Sarc(:, :, K),outfile , 'WriteMode', 'append');
  end
end
end


%% First save Calcium as tif
%% First make Calcium TIF
if DoWhat{9,1} ==1 
mkdir ('Calcium')
for fn = 1:Nums
d = squeeze(bfopen(fileList(fn).name));
for e = 1:size(d{1,1},1)
    fe(:,:,e) = d{1,1}{e,1};
end
de = uint8(255*scaleMinMax(double(fe)));

Cakeep = (2:2:size(de,3));

Calcium = de(:,:,Cakeep);
Calc = squeeze((Calcium));
 
[filepath,name,ext] = fileparts(fileList(fn).name);
clear fe de

  fprintf (1, '<strong>>>> Saving calcium tif...:</strong>%s\n'), disp (fn)
  for K=1:size(Calc,3)
  outfile = fullfile(Maindatapath,'/Calcium/',sprintf('%sCalcium.tif',name));
  imwrite(Calc(:, :, K),outfile , 'WriteMode', 'append');
  end
end

%% Read calcium .tifs
cd ([Maindatapath, '/Calcium/']);

FilePatternSarc = fullfile(Maindatapath,'/Calcium/',['*','.tif']);
fileListSarc = dir(FilePatternSarc);

NumsSarc = length (fileListSarc);
fprintf (1, '<strong>>>> Number of files to convert:</strong>%s\n'), disp (Nums)

for fn = 1:NumsSarc
  de = squeeze(bfopen(fileListSarc(fn).name));

for ked = 1:length (de{1,1})
kedi(:,:,ked) = de {1,1}{ked,1};
end

  Sarc = kedi;
  ComSarc(:,:,1,:) = Sarc ;
%% Convert calcium .tifs & save as AVI
  [filepath,name,ext] = fileparts(fileListSarc(fn).name);
  v = VideoWriter(sprintf('%s.avi',name),['Uncompressed AVI']);
  open(v)
  writeVideo(v,ComSarc)
  close(v)
  %clear ('ComSarc', 'Sarc', 'de');
end

fprintf(1,'\n')
fprintf (1, '<strong>>>> Done! Number of videos converted:</strong>%s'), disp (Nums), fprintf(1,'\n')  %%% Next line  %%%
fprintf(1,'\n')
% 
end





function enter_call(hObject, eventdata, handles)
handles = guidata(hObject);
checkboxValues = get(handles.h_checkbox, 'Value');
assignin('base','DoWhat', checkboxValues);
close(gcf)
end