%% This script reads all SarcTrack output and puts aggregates all statistics
% and traces into a new file. The original ouputs are then moved to a new 
% folder for deleting. It keeps only one frame per video
%  Requirements:
%    - SarcTrack output folders from pySarcTrack must be located in a folder
%     with NO other files or folders
%
%  Required functions:  
%    - ContrBeatSegmentation.m
%
function AggregateSarcTrack(~,~)
close all, clear all, clc
addpath (pwd);

fprintf(1,'>>> Select DATA directory for pySarcTrack output folders\n' )
Maindatapath = uigetdir('D:/','Select DATA directory for files');
Maindatapath = ([Maindatapath '/']);
cd (Maindatapath);
fprintf(1,'\n')  %%% Next line  %%%
% Find files to convert
FilePattern = fullfile(Maindatapath);
fileList = dir(FilePattern);
ConvFactor = 0.07;
TimFactor = 1000 * 0.01;

Nums = size (fileList,1);
Nums = Nums - 3;
fprintf (1, '>>> Number of files to process:%s\n'), disp (Nums)
listing = dir (Maindatapath);
cd (Maindatapath);
mkdir 'Unprocessed Files';
ErrFoldLocation = [Maindatapath,'Unprocessed Files'];
mkdir Processed
ProcessedLocation = [Maindatapath,'Processed'];
cd (Maindatapath);

%% move folders without the correct number of files to 'UnprocessedFolders'
TotalFileNumber = ((length(listing)-3));
for i = 4:(length(listing));
disp(">>> Filering folers...: Processing file:  " + (i-3) + "  of  " + (length(listing)-3 ))

listingPF = ([Maindatapath,listing(i).name]);
if size(dir(listingPF),1) <9
    cd (Maindatapath)
movefile  (listing(i).name, ErrFoldLocation, 'f')
else 
end
end
NumberFilesMoved = (length(dir(ErrFoldLocation))-2);
disp(">>> Number of files filtered:    " +  (length(listing)-3 ) +...
    "  |  Files eliminated:   "  + NumberFilesMoved )
pause(3)
%%
%% Read and tabulate average stats 
listing = dir (Maindatapath);
cd (Maindatapath);
WholeTraces = [];
for i = 4:(length(listing)-2);
disp(">>> Processing file  " + (i-3) + " of  " + (length(listing)-5 ) + "  |  Directory name: " + (listing(i).name ))

listingFA = ([Maindatapath,listing(i).name]);
cd(listingFA)
SCF = dir('DWDists*');
PFF = dir('DWPrdFrq*');
if size (SCF,1) >0
SarcContrFile =SCF.name;
end
if size(PFF,1) >0
    PerFreqFile = PFF.name;
end
SF = dir('DWStats*');
if size (SF) >0
StatsFile = SF.name;
end

if size(PFF,1) >0
    DistsFile = SCF.name;
end
Contr = readmatrix (DistsFile);
AvgContrTrace = mean (Contr,2);
WholeTraces{i-3} = AvgContrTrace;
Traces(:,i-3) = AvgContrTrace(1:100,1);
Filenames(i-3,:) = (convertCharsToStrings(listing(i).name));

if exist (StatsFile) >0; %exist(fullfileName , 'file')
  Stats = readmatrix(StatsFile);
  AvS = mean(Stats,1);
end

if exist (StatsFile) >0
  AvgStats(i-3,:) = AvS;

if size(PFF,1) >0
    PFFile = PFF.name;
end
PF = readmatrix (PFFile);
PerFreqData(i-3,:) = PF;

%Traces(:,i-3) = AvgContrTrace(1:150,1);
cd (Maindatapath)
movefile  (listing(i).name, ProcessedLocation);

end
end

%% move all but one labelled frame per video to "Excess Frames" folder 
% listing = dir (ProcessedLocation);
% TotalFileNumber = ((length(listing)-3));
% cd (ProcessedLocation)
% folderlist = dir;
% for item = 4:length(folderlist);
%    sample_name{item} = folderlist(item).name;
% end;
% 
% for i = 3:(length(listing));
%     fprintf (1, '>>> Moving excess frames...%s\n'), 
%     disp("  Processing directory  " + (i-2) + " of " + (length(listing)-2) )
% listingFA = ([Maindatapath,'/',folderlist(i).name]);
% skipr = strcmp(folderlist(i).name, 'Excess Frames');
% if skipr == 1
% end
% 
% cd(listingFA)
% FD = dir;
% for item = 4:length(FD);
%    sample_contents{item} = FD(item).name;
% end;
% 
% 
% 
% % strfind({sample_contents, 'histogram.png')
% % index = find([sample_contents{:}] == 'histogram.png')
% 
% findframesdirectory = strcmp(sample_contents, 'frames_annotated');
% FDir = find(findframesdirectory);
% if sum (findframesdirectory) >0
% 
% 
% cd("frames_annotated/")
% movefile ("Frame003.png", listingFA)
% cd(listingFA)
% newname = strcat(listing(i).name, "_frames_annotated");
% movefile ('frames_annotated', newname )
% movefile (newname, EFdir)
% cd (ProcessedLocation)
% else
% end
% end
% disp ('>>> Successfully moved excess frames')
% 


%%
%% Average traces and invert to enhance signal





% for i = 3:(length(listing)-2)
% AvgContrTrace
% 
% 
% 
% 
% end
%%


%%
% fig = imread(contraction.png);
% figure, imshow (fig)
% 
% answer = questdlg('Analyse current trace?', ...
% 	'Trace acceptable?', ...
% 	'Yes','No','Yes');
% % Handle response
% switch answer
%     case 'Yes'
%%

%Make TABLE for avg traces 
ConvTraces = ConvFactor .* Traces;
TraceFile = vertcat((Filenames'), (Traces));
 
%Make TABLE for avg stats
ATC = AvgStats(:,1);
ATR = AvgStats(:,2);
Contraction_Duration = (ATC+ATR);
AvgStatsTotalDuration = table(Contraction_Duration .* TimFactor);

% AvgStatstime = ((AvgStats(:,1:3) .* TimFactor));
% AvgStatsSpace = (AvgStats(:,4:8) .* ConvFactor);


AvgStatsTime1 = ((AvgStats(:,1) .* TimFactor));
AvgStatsTime2 = ((AvgStats(:,2) .* TimFactor));
AvgStatsTime3 = ((AvgStats(:,3) .* TimFactor));
AvgStatsSpace4 = (AvgStats(:,4) .* ConvFactor);
AvgStatsSpace5 = (AvgStats(:,5) .* ConvFactor);
AvgStatsSpace6 = (AvgStats(:,6) .* ConvFactor);
AvgStatsSpace7 = (AvgStats(:,7) .* ConvFactor);
AvgStatsSpace8 = (AvgStats(:,8) .* ConvFactor);

MaxRelax = (AvgStats(:,7));
MaxContr = (AvgStats(:,6));
PercContractility_fit = table((MaxRelax - MaxContr)./ MaxRelax.*100);
PercContractility_fit.Properties.VariableNames = ["Var2"];
MaxRelaxUF = (AvgStats(:,5));
MaxContrUF = (AvgStats(:,4));
PercContractility_UF = ((MaxRelaxUF - MaxContrUF)./ MaxRelaxUF.*100);
VelContr = table((MaxRelax - MaxContr)./ (AvgStatsTime1)*1000);
VelContr.Properties.VariableNames = ("Contraction Velocity(um/sec)");

VelRelax = table((MaxContr - MaxRelax)./ (AvgStatsTime2)*-1000);
VelRelax.Properties.VariableNames = ("Relaxation Velocity(um/sec)");

PeriodNo = PerFreqData(:,1);
NumberFittedTraces = table(size(AvgContrTrace,1) ./ PeriodNo);
NumberFittedTraces.Properties.VariableNames = ("No. ofTraces Fitted");


StatsNameList = table(Filenames);
StatTable = horzcat(StatsNameList, NumberFittedTraces, AvgStatsTotalDuration, table(AvgStatsTime1), ...
    table(AvgStatsTime2), table(AvgStatsTime3), table(AvgStatsSpace4), table(AvgStatsSpace5), ...
    table(AvgStatsSpace6), table(AvgStatsSpace7), table(AvgStatsSpace8), VelContr, VelRelax, ...
    PercContractility_fit);

% 
% StatTable.Properties.VariableNames = ["File name", "No. ofTraces Fitted", "Contraction Duration (msec)", "Contraction Time(msec)", "Relaxation Time(msec)",...
%     "Offset from avg" ,"Min Sarc Dist" ,"Max Sarc Dist" ,"Min Sarc Dist Fitted",...
%     "Max Sarc Dist Fitted","RNSE","Contraction Velocity(um/sec)", "Relaxation Velocity(um/sec)", "Percentage Contraction Fitted"];

StatsTable = horzcat(StatTable, array2table(PercContractility_UF) );

StatsTable.Properties.VariableNames = ["File name", "No. ofTraces Fitted", "Total Contraction Duration (msec)", "Time to max contraction(msec)", "Time to relaxation(msec)",...
    "Offset from avg" ,"Min Z-disk Dist" ,"Max Z-disk Dist" ,"Min Z-disk Dist Fitted",...
    "Max Z-disk Dist Fitted","RNSE","Contraction Velocity(um/sec)", "Relaxation Velocity(um/sec)", "Percentage Contraction Fitted", "Percentage Contraction unfitted"];
cd (Maindatapath);
writetable(StatsTable, 'Aggregated_Stats.xlsx')
writematrix(TraceFile, 'Contractility_Traces.xlsx')
disp ('Done! all files aggregated!')

end
