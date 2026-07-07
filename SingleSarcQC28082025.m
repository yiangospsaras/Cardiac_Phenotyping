clc
clear all
close all
ConvFactor = 0.07; % Spatial resolution of video to calculate physical distances
TimFactor = (1000 * 0.01); % Frame speed of video to calculate timing parameters
disp('Quality control for SarcTrack based on contractility model fitting')
fprintf(1,'<strong>>>> Select DATA directory</strong>\t' )
Maindatapath = uigetdir('D:/','Select DATA directory for files');
Maindatapath = ([Maindatapath '/']);
cd (Maindatapath);
fprintf(1,'\n') %%% Next line %%%
% Find files to convert
FilePattern = fullfile(Maindatapath);
fileList = dir(FilePattern);
Nums = size (fileList,1);
Nums = Nums;
fprintf (1, '<strong>>>> Number of directories found:</strong>%s\n'), disp (Nums-2)
listing = dir (Maindatapath);
cd (Maindatapath);
SampleData = [];
tic
for i = 3:(length(listing));
clear SCF SF PFF PFFile
disp("<strong>>>> Processing file " + (i-2) + " of " + (length(listing)-2 ) + ...
" | File name: </strong>" + (listing(i).name ))
listingFA = ([Maindatapath,listing(i).name]);
if isfolder(listingFA)==1
cd(listing(i).name)
SCF = dir('DWDists*');
SF = dir('DWStats*');
PFF = dir('DWPrdFrq*');
if size(PFF,1) >0 %Loop for the presence of period/frequency file
PerFreqFile = PFF.name;
PFFile = PFF.name;
%% if size (SF) >0 %%% Eliminated under the assumption that if Dists file
% exists, there will be a stats file. Stats file reading embedded in the
% dists file for loop
% StatsFile = SF.name;
% end
%%
if size(SCF,1) >0 %Loop for the existence of sarcomeric distance file
DistsFile = SCF.name;
StatsFile = SF.name;
PF = readmatrix (PFFile);
PerFreqData = PF;
PeriodNo(i-2) = PerFreqData(:,1);
STAg = readtable(DistsFile, 'VariableNamingRule', 'preserve' );
STFl = readmatrix(StatsFile);
%Mn = mean(STAg,2);
% for w = 1: size (file)
% Filter by fitting of sine waveform
%figure
clear R
for (track = 1:size(STAg,2))
trace = STAg{:,track};
SIZ = size(trace,1);
if SIZ ==500
Traces(:,track) = trace(1:500);
else
XTR = 500-SIZ;
ADDON = (ones(XTR,1).* mean(trace));
traceR = vertcat(trace, ADDON);
Traces(:,track) = traceR;
end
X = 1:length(trace);
mdl = fittype('a*sin(b*x+c)','indep','x');
Ynorm1 = movmean(trace,3)-min(movmean(trace,3));
Ynorm2 = Ynorm1/ max(Ynorm1);
[Fitc,gof] = fit(X', Ynorm2, 'sin3') ;
Golfy(:,track) = gof.rsquare;
FitC = fit(X',Ynorm2,mdl,'start',[rand(),1/(5/60/(2*pi)),rand()]);
% figure
% plot(Ynorm2, 'LineWidth', 2)
% hold on
% plot (Fitc)
%clear Tracks
% Tracks = zeros(size(STAg,1), size(STAg,2)) ;
%clear KeepTrack
prog = (track / size(STAg,2))*100;
progg = num2str(round(prog,2));
% fileno= num2str(i -2);
% totalfileno= num2str((length(listing)-2 ));
% REP = horzcat("File ", fileno,"of ",totalfileno)
% fprintf(1, 'Computation Progress: %3d%%\n')
% fprintf(1, '\b\b\b\b%3.0f%%',prog); pause(0.001)
if exist('R') % This loop displays rolling progress by deleting previous printed message
fprintf(repmat('\b',1,(mssg-17)));
end
if gof.rsquare >0.45
mssg = fprintf(">>> File "+(i-2)+" of "+(length(listing)-2 )+" | Progress: " + (progg) + "%%"+" | Track: " + (track) + " of " + size(STAg,2) + "<strong> : Kept</strong>" +"\t");
R = 1;
KeepTrack(:,track) = 1;
else
% Tracks(:,track) = (zeros(1,(size (Tracks,1))))';
KeepTrack(:,track) = 0;
mssg = fprintf(">>> File "+(i-2)+" of "+(length(listing)-2 )+" | Progress: " + (progg) + "%%"+" | Track: " + (track) + " of " + size(STAg,2) + "<strong> : Removed</strong>" +"\t");
R = 1;
end
clear SZad;
goodTrack(:,track) = track ;
%plot(Ynorm2, 'LineWidth', 2)
%hold on
%plot (Fitc)
Stat(track,:) = STFl(track,:);
end
fprintf('\n')
clear KT
KT = logical(KeepTrack);
Tracks = Traces(:,KT);
ClearedTracks = Tracks;
SampleData(i-2).UnfilteredTracks = Traces;
ClearedTracks(:,all(ClearedTracks == 0))=[];
SampleData(i-2).FilteredTracks = ClearedTracks;
clear Tracks ClearTracks KeepTrack KT
SampleData(i-2).NumberGoodTracks = size(SampleData(i-2).FilteredTracks,2);
SampleData(i-2).NumberBadTracks = (size(SampleData(i-2).UnfilteredTracks,2)-SampleData(i-2).NumberGoodTracks);
SampleData(i-2).AverageTraceFiltered = mean((SampleData(i-2).FilteredTracks),2);
SampleData(i-2).AverageTraceUnfiltered = mean((SampleData(i-2).UnfilteredTracks),2);
STTT = Stat;
Lght = (size(Traces,2));
Stat(Stat==0) = [];
Stat(:,all(Stat == 0))=[];
STTT(~any(STTT,2),:)=[];
for cm = 1: size (STTT,2)
mn(:,cm) = double(mean(nonzeros(STTT(:,cm))));
end
SampleData(i-2).Name = cellstr(listing(i).name);
SampleData(i-2).ContractionTime = mn(1);
SampleData(i-2).RelaxationTime = mn(2);
SampleData(i-2).OffsetfromAVG = mn(3);
SampleData(i-2).MinSarcDist = mn(4);
SampleData(i-2).MaxSarcDist = mn(5);
SampleData(i-2).MinSarcDistFitted = mn(6);
SampleData(i-2).MaxSarcDistFitted = mn(7);
SampleData(i-2).RNSE = mn(8);
% % Filter by deviation from mean
% for Tr = 1:size(Tracks,2)
% trace = Tracks(:,Tr);
% mt = mean (trace);
% mot = trace - mt;
%
% figure, plot (movmean(trace,3))
% yline(mt)
% hold on
% plot (mot)
%
% end
%
% figure,
% subplot(2,1,1),
% plot (STAg{:,:})
% hold on, plot (Mn{:,:}, 'LineWidth', 3, "Color",'k' ), title ("Original average")
%
% subplot(2,1,2),
% plot (Tracks)
% hold on, plot (mean(Tracks,2),'LineWidth', 3, "Color",'k' ), title ("Filtered average")
% end
cd (Maindatapath)
clear Tracks Traces Stat STTT SCF SF CFF STAg STFL stat KT
else
fprintf (1, '>>>>> Sarcomere traces file missing (cannot perform filtering), file skipped: %.f'), disp (listing(i).name )
cd (Maindatapath)
clear mssg
R = 1;
end
else
end
else
end
cd (Maindatapath)
end
cd (Maindatapath)
%% Data streamlining to avoid errors from blanks in SampleData struct
for Str = 1:length(SampleData)
if isempty (SampleData(Str).UnfilteredTracks);
SampleData(Str).UnfilteredTracks = zeros(Lght,1);
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).FilteredTracks);
SampleData(Str).FilteredTracks = zeros(Lght,1);
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).NumberBadTracks);
SampleData(Str).NumberBadTracks = 1;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).NumberGoodTracks);
SampleData(Str).NumberGoodTracks = 1;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).AverageTraceFiltered);
SampleData(Str).AverageTraceFiltered = zeros(Lght,1);
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).AverageTraceUnfiltered);
SampleData(Str).AverageTraceUnfiltered = zeros(Lght,1);
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).AverageTraceUnfiltered);
SampleData(Str).AverageTraceUnfiltered = zeros(Lght,1);
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).Name);
SampleData(Str).Name = 'ERROR';
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).ContractionTime);
SampleData(Str).ContractionTime = 0;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).RelaxationTime);
SampleData(Str).RelaxationTime = 0;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).OffsetfromAVG);
SampleData(Str).OffsetfromAVG = 0;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).OffsetfromAVG);
SampleData(Str).OffsetfromAVG = 0;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).MinSarcDist);
SampleData(Str).MinSarcDist = 0;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).MaxSarcDist);
SampleData(Str).MaxSarcDist = 0;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).MinSarcDistFitted);
SampleData(Str).MinSarcDistFitted = 0;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).MaxSarcDistFitted);
SampleData(Str).MaxSarcDistFitted = 0;
else
end
end
for Str = 1:length(SampleData)
if isempty (SampleData(Str).RNSE);
SampleData(Str).RNSE = 0;
else
end
end
%%Collect all statistics
TotalContractionDuration = (vertcat(SampleData.ContractionTime) .* TimFactor) + ...
(vertcat(SampleData.RelaxationTime) .* TimFactor);
ContractionVelocity = (((vertcat(SampleData.MaxSarcDistFitted) .* ConvFactor) - ...
(vertcat(SampleData.MinSarcDistFitted) .* ConvFactor)) ./ (vertcat(SampleData.ContractionTime) * TimFactor))*1000;
RelaxationVelocity = (((vertcat(SampleData.MaxSarcDistFitted) .* ConvFactor) - ...
(vertcat(SampleData.MinSarcDistFitted) .* ConvFactor)) ./ (vertcat(SampleData.RelaxationTime) .* TimFactor))*1000;
PercentageContractionUnfitted = ((vertcat(SampleData.MaxSarcDist) .* ConvFactor) - ...
(vertcat(SampleData.MinSarcDist) .* ConvFactor)) ./ (vertcat(SampleData.MaxSarcDist) .* ConvFactor)*100;
PercentageContractionFitted = ((vertcat(SampleData.MaxSarcDistFitted) .* ConvFactor) - ...
(vertcat(SampleData.MinSarcDistFitted) .* ConvFactor)) ./ (vertcat(SampleData.MaxSarcDistFitted) .* ConvFactor)*100;
%%
for b = 1:length(SampleData)
NumGoodTraces(:,b) = SampleData(b).NumberGoodTracks;
NumBadTraces(:,b) = SampleData(b).NumberBadTracks;
PercentageGoodTraces(:,b) = ((NumGoodTraces(b) / (NumGoodTraces(b) + NumBadTraces(b)))*100);
end
%% Collect cleared Traces
for a = 1:length(SampleData)
H = strcmp((SampleData(a).Name), 'ERROR');
if H ==0
QCedTRACESAvg(:,a) = ((SampleData(a).AverageTraceFiltered(1:500)));
AllTRACESavg(:,a) = ((SampleData(a).AverageTraceUnfiltered(1:500)));
else
end
clear H
end
NumberFittedTraces = (size(QCedTRACESAvg,1)) ./ PeriodNo;
StatsTBL = table(vertcat(SampleData.Name), ...
NumberFittedTraces', NumGoodTraces', NumBadTraces', ...
PercentageGoodTraces',...
TotalContractionDuration, ...
vertcat(SampleData.ContractionTime) .* TimFactor, ...
vertcat(SampleData.RelaxationTime) .* TimFactor, ...
vertcat(SampleData.OffsetfromAVG) .* TimFactor, ...
vertcat(SampleData.MinSarcDist) .* ConvFactor, ...
vertcat(SampleData.MaxSarcDist) .* ConvFactor, ...
PercentageContractionUnfitted, ...
vertcat(SampleData.MinSarcDistFitted) .* ConvFactor, ...
vertcat(SampleData.MaxSarcDistFitted) .* ConvFactor, ...
PercentageContractionFitted, ...
vertcat(SampleData.RNSE), ...
ContractionVelocity, RelaxationVelocity);
StatsTBL.Properties.VariableNames = ["File name", "Number of Traces fitted", ...
"Number of pacing sarcomeres", ...
"Number of non-pacing sarcomeres" , "Percentage Pacing sarcomeres", ...
"Total Contraction Duration (msec)", ...
"Time to max contraction (msec)", "Time to Relaxation (msec)", ...
"Offset from avg", "Min Sarcomere Dist (um)", "Max Sarcomere Dist (um)", ...
"Percentage Contraction Unfitted", "Fitted Min Sarcomere Dist", ...
"Fitted Max Sarcomere Dist", "Percentage Contraction Fitted", "RNSE", ...
"Contraction Velocity (um/sec) ", "Relaxation Velocity (um/sec)"];
%% Cleared Traces conversion
ConvQCedTRACESAvg = ConvFactor .* QCedTRACESAvg;
ConvQCedTRACESAvgTBL = vertcat({SampleData.Name}, num2cell(ConvQCedTRACESAvg));
FilteredTracesTBL = table(ConvQCedTRACESAvgTBL);
ConvAllTRACESAvg = ConvFactor .* AllTRACESavg;
ConvAllTRACESAvgTBL = vertcat({SampleData.Name}, num2cell(ConvAllTRACESAvg));
UnfilteredTracesTBL = table(ConvAllTRACESAvgTBL);
%% Output tables
mkdir("FirstQC")
QCPath =([Maindatapath 'FirstQC']);
cd (QCPath);
writetable(StatsTBL, "QC'ed_Stats.xlsx")
writetable(FilteredTracesTBL, "QC'ed_Traces.xlsx")
writetable(UnfilteredTracesTBL, "Pre_QC_Traces.xlsx")
fprintf (1, '<strong>>>>>> First round of QC complete.</strong>%\n')
disp(" ")
disp (">>>>> Individual Sarcomeres QC'ed based on fitting model.")
disp (">>>>> Units converted to real time and distance. ")
disp (">>>>> Files saved in the following directory:")
disp (QCPath)
%% Second QC based on number of contraction number fitted
fprintf (1, '<strong>>>>>> Second quality control based on number of contractions fitted by model</strong>%\n')
disp(" ")
mssg = fprintf(1,'>>> Finding data.\n' );
pause (0.5)
fprintf(repmat('\b',1,(mssg)));
mssg1 = fprintf(1,'>>> Finding data..\n' );
pause (0.5)
fprintf(repmat('\b',1,(mssg1)));
mssg2 = fprintf(1,'>>> Finding data...\n' );
pause (0.5)
fprintf(repmat('\b',1,(mssg2)));
mssg3 = fprintf(1,'>>> Finding data....\n' );
pause (0.5)
fprintf(repmat('\b',1,(mssg3)));
mssg4 = fprintf(1,'>>> Finding data.....\n' );
pause (0.5)
fprintf(repmat('\b',1,(mssg4)));
fprintf(1,'>>> Finding data......\n' );
QCFiledir = dir("QC'ed_Stats.xlsx");
QCF = readtable(QCFiledir.name);
FittedTraceNum = QCF{:,2};
prompt = {'\bf \fontsize{12} Please enter expected number of traces:',...
};
dlgtitle = 'Quality control parameters';
dims = [1 88];
definput = {'','', '', '','','','','',''};
opts.Interpreter = 'tex';
answers = inputdlg(prompt,dlgtitle,dims,definput, opts);
ExpectedTraces = str2num(answers{1,1});
ExpectedPlus = ExpectedTraces* 1.1;
ExpectedMinus = ExpectedTraces* 0.9;
% filter data based on number of fitted traces
UnderPlus = (FittedTraceNum < ExpectedPlus );
Oneparam = QCF(UnderPlus,:);
FilterOver = Oneparam(:,2);
FO = table2array(FilterOver);
OverMinus = (FO > ExpectedMinus);
Filtered = Oneparam(OverMinus,:);
FO = table2array(FilterOver);
OverMinus = (FO > ExpectedMinus);
Filtered = Oneparam(OverMinus,:);
cd (Maindatapath)
mkdir('Final QC')
FQCPath =([Maindatapath 'Final QC']);
cd (FQCPath);
%Output QC'ed files
writetable(Filtered, "Final QCed Stats.xlsx")
disp ('Data cleaned and stored in original directory')


%% Plot data to visualise spread
f = figure;
f.Position = [100 100 525 500];
%Figure 1
subplot(1,2,1)
a = 1;
b = 2;
n = length (FittedTraceNum);
J = a + (b-a).*rand(n,1);
scatter(J, QCF{:,2}, 'MarkerEdgeColor',[0 0 0.7410],...
'MarkerFaceColor',[0 0.4470 0.7410],...
'LineWidth',0.5), xlim([0 5.5])
ax = gca;
set(gca,'XTick',[]);
ax.FontSize = 11;
caption = sprintf('Number of contractions detected\n before and after filtering\n');
ttl = title (caption);
fontsize(ttl,12,'points');
hold on
yline(0)
ymax = ExpectedPlus;
ymin = ExpectedMinus;
yline([ymax ymin],':',{'Max','Min'})
yline(ExpectedTraces, '--')
c = 3.5;
d = 4.5;
e = length (Filtered{:,2});
K = c + (d-c).*rand(e,1);
hold on
scatter(K, Filtered{:,2}, 'MarkerEdgeColor',[0.7 0 0],...
'MarkerFaceColor',[0.7500 0.3250 0.0980],...
'LineWidth',0.25)
L1 = scatter(nan, nan, 'MarkerEdgeColor',[0 0 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410], 'LineWidth',0.5);
L2 = scatter(nan, nan, 'MarkerEdgeColor',[0.7 0 0], 'MarkerFaceColor', [0.7500 0.3250 0.0980], 'LineWidth',0.25);
gravstr1 = sprintf('Original sample size: %.f',n);
gravstr2 = sprintf('Sample size after QC: %.f',e);
%Figure 2
subplot(1,2,2)
a = 1;
b = 2;
n = length (FittedTraceNum);
J = a + (b-a).*rand(n,1);
scatter(J, QCF{:,6}, 'MarkerEdgeColor',[0 0 0.7410],...
'MarkerFaceColor',[0 0.4470 0.7410],...
'LineWidth',0.5), xlim([0 5.5])
ax = gca;
set(gca,'XTick',[]);
ax.FontSize = 11;
caption = sprintf('Contraction duration\n before and after filtering\n ');
ttl = title (caption);
fontsize(ttl,12,'points');
hold on
yline(0)
yline(1000)
c = 3.5;
d = 4.5;
e = length (Filtered{:,2});
K = c + (d-c).*rand(e,1);
hold on
scatter(K, Filtered{:,6}, 'MarkerEdgeColor',[0.7 0 0],...
'MarkerFaceColor',[0.7500 0.3250 0.0980],...
'LineWidth',0.25)
L1 = scatter(nan, nan, 'MarkerEdgeColor',[0 0 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410], 'LineWidth',0.5);
L2 = scatter(nan, nan, 'MarkerEdgeColor',[0.7 0 0], 'MarkerFaceColor', [0.7500 0.3250 0.0980], 'LineWidth',0.25);
gravstr1 = sprintf('Original sample size: %.f',n);
gravstr2 = sprintf('Sample size after QC: %.f',e);
lgd = legend([L1, L2], {gravstr1, gravstr2}, 'Location', 'southoutside');
fontsize(lgd,11,'points');
toc
% %
% % Pass to CalTrack-style analysis% end
%
% AcquisitionFrequency = 100;
% PacingFrequency = 1;
% N = 1;
% M = 0;
% cutoff = 40;
% cutoff = (1/PacingFrequency)-(cutoff/100)*(1/PacingFrequency);
% param_single_beat = 'n';
% conversion = 'n';
% segmentation = 'n';
% quantitative_data = 'n';
%
% % DataAnalysis by averaging. Derived from DataAnalysis.m function
%
% disp('Analysing data');
% disp('Beat Segmentation');
%
% Y = (mean(Tracks,2)*-1); %inverted %Will need to be changed as it's meant to be a matrix
%
% Names = NAME;
% single_traces = struct.empty;
% skipped = struct.empty;
% extra_beat = struct.empty;
% errors = struct.empty;
%
% k = 1;
% m = 1;
% z = 1;
% e = 1;
%
% CL = 1/PacingFrequency;
% offset_time = 0.1*CL;
%
% for i = 1:length(Y)
%
% if AcquisitionFrequency>100
% y_original = Y{i};
% DT = round((1/100)*AcquisitionFrequency);
% y1 = movmean(y_original,24); % y1 = movmean(Y{i},24);
% y = y1(1:DT:end);
% AF = 1/((1/AcquisitionFrequency)*DT);
% else
% y = Y; %Y{i}
% y_original = y;
% DT = round((1/100)*AcquisitionFrequency);
% y1 = movmean(y_original,10); % y1 = movmean(Y{i},24);
% y = y1(1:DT:end);
%
% AF = AcquisitionFrequency;
% DT = 1;
% end
%
% offset = ceil(offset_time*AF);
%
% skip = 0;
%
% y_diff = movmean(diff(y),50); % was 8
%
% [~,~,~,pr] = findpeaks(y);
% [peaks,location,~,~] = findpeaks(y_diff,'MinPeakWidth',(0.25*(AcquisitionFrequency/PacingFrequency))); %(y,'MinPeakProminence',0.5*max(pr)
%
% [~,~,~,pr2] = findpeaks(y);
% [peaks2,location2,~,~] = findpeaks(y,'MinPeakWidth',(0.25*(AcquisitionFrequency/PacingFrequency))); %'MinPeakProminence',0.5*max(pr2)
%
% peaks_time = location2/AF;
% peaks_period = (diff(peaks_time));
% is_extra_beat = find(peaks_period<cutoff);
%
% % if (length(peaks)-length(peaks2))>1
% %
% % disp('>>>>>> noisy signal detected and excluded.')
% % skip = 1;
% % skipped(k).data = y_original;
% % skipped(k).name = Names; %Names{i,1}
% % skipped(k).id = i;
% % k=k+1;
% %
% % elseif isempty(is_extra_beat) == 0
% %
% % disp('>>>>>> extra beat(s) detected and excluded.')
% % extra_beat(m).data = y_original;
% % extra_beat(m).name = Names; %Names{i,1}
% % extra_beat(m).id = i;
% % extra_beat(m).BBdistance = mean(peaks_period);
% % extra_beat(m).Nperiod = length(peaks_period);
% % m=m+1;
% % skip = 1;
% %
% % end
%
% if skip == 0
%
% try
%
% single_traces(z).name = Names{i,1};
%
% for j = 1:length(peaks)-1
%
% if (location(j)-offset)>=1
%
% ID1 = location(j)-offset;
% ID2 = location(j+1)-offset;
% id1 = ID1+(ID1-1)*(DT-1);
% id2 = ID2+(ID2-1)*(DT-1);
% temp = y_original ( id1 : id2 );
%
% else
%
% ID1 = location(j)-(location(j)-1);
% ID2 = location(j+1)-(location(j)-1);
% id1 = ID1+(ID1-1)*(DT-1);
% id2 = ID2+(ID2-1)*(DT-1);
% temp = y_original( id1 : id2 );
%
% end
%
% single_traces(z).data(j).beats = temp;
%
% end
%
% j = j+1;
% ID1 = location(j)-offset ;
% id1 = ID1+(ID1-1)*(DT-1);
% temp2 = y_original(id1 : end);
% temp22 = y(ID1 : end);
%
% temp33 = [temp22; temp22(1)];
% temp3 = [temp2; temp2(1)];
%
% [~,~,~,pr_temp] = findpeaks(temp33);
% [pp_temp,ll_temp,~,~] = findpeaks(temp33,'MinPeakWidth',0.25*(AcquisitionFrequency/PacingFrequency));
%
% if (AcquisitionFrequency>100 || param_single_beat == 'y')
% %
% else
%
% if length(pp_temp)>1
% ID = (ll_temp(2)-offset);
% id = ID+(ID-1)*(DT-1);
% single_traces(z).data(j).beats = temp3(1:id);
% elseif (temp2(end)<temp2(1))
% single_traces(z).data(j).beats = temp2;
% end
%
% end
%
% single_traces(z).Nbeats = length(single_traces(z).data);
%
% len=0;
% for j=1:length(single_traces(z).data)
% len = len +length(single_traces(z).data(j).beats);
% end
% single_traces(z).time = len/AcquisitionFrequency;
% single_traces(z).BR = single_traces(z).Nbeats/single_traces(z).time;
% single_traces(z).BBdistance = mean(peaks_period);
% single_traces(z).Nperiod = length(peaks_period);
% single_traces(z).original = y_original;
% z=z+1;
%
% catch
% disp('>>>>>> error occurred in beat segmentation.')
% errors(e).data = y_original;
% errors(e).name = Names; % Names{i,1}
% e = e+1;
% end
%
% end
%
% end
%
% % function selected_traces = select_traces(data, noise_level)
% % % SELECT_TRACES selects traces with repeated low-signal dips, return to baseline, and high noise.
% % %
% % % Inputs:
% % % data - Matrix of traces (each row is a trace, sampled at 100 Hz)
% % % threshold - Signal dip threshold (values below this indicate a dip)
% % % min_duration - Minimum duration of dip (in samples)
% % % noise_level - Minimum standard deviation of noise to be considered high noise
% % %
% % % Output:
% % % selected_traces - Logical array indicating which traces meet the criteria
% %
% %
% % min_duration = 0.02(size(data,2))
% % threshold = = mean() <<<<<<<<------------------------
% %
% % num_traces = size(data, 1);
% % selected_traces = false(num_traces, 1);
% %
% % for i = 1:num_traces
% % trace = data(i, :);
% %
% % % Detect dips below threshold
% % dips = trace < threshold;
% %
% % % Find consecutive dips
% % dip_starts = find(diff([0 dips]) == 1);
% % dip_ends = find(diff([dips 0]) == -1);
% %
% % % Ensure valid dip durations
% % dip_durations = dip_ends - dip_starts + 1;
% % valid_dips = sum(dip_durations >= min_duration);
% %
% % % Check noise level
% % noise_std = std(trace);
% %
% % % Select trace if it meets criteria
% % if valid_dips > 1 && noise_std >= noise_level
% % selected_traces(i) = true;
% % end
% % end
% % end
%
% f = figure;
% f.Position = [100 100 750 500];
% subplot (3,1,1)
% plot (Mn{:,:}, 'LineWidth', 2.5)
% caption = sprintf('Average contraction trace');
% ttl = title (caption);
% fontsize(ttl,12,'points');
%
% subplot (3,1,2)
% caption = sprintf('All contraction traces');
% ttl = title (caption);
% fontsize(ttl,12,'points');
%
% plot (STAg{:,:})% subplot(3,1,3), plot (STAg{:,1})
% caption = sprintf('Individual contraction trace');
% ttl = title (caption);
% fontsize(ttl,12,'points');


