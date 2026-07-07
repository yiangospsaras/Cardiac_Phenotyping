function SimulateTrace(~,~)
close all
clear all
clc
%This script generates simulated contractile traces
% Custom functions required: 
% SimParameters.m  


    disp('Generating simulated Trace based on defined parameters')
    
  prompt = {'\bf \fontsize{12} Please enter contraction time (ms):'...
        '\bf \fontsize{12} Please enter relaxation time (ms):'...
        '\bf \fontsize{12} Please enter the relaxed sarcomere length (µm):'...
        '\bf \fontsize{12} Please enter the contraced sarcomere length (µm):'...
        '\bf \fontsize{12} Please enter the trace period in msec  (µm):'...
    };

    dlgtitle = 'Analysis parameters';
    dims = [1 88];
    definput = {'','','','','',''};
    opts.Interpreter = 'tex';
    answers = inputdlg(prompt,dlgtitle,dims,definput, opts);

    addon = 5 ;
    TraceLength = (str2num(answers{5,1})) + 4  ;%str2num(answers{1,1});
    AcquisitionFrequency = 10 ;%(msec) % (1 / (str2num(answers{2,1}))*1000);
    ContrT =  str2num(answers{1,1});
    ContrT = AcquisitionFrequency * (round(ContrT/AcquisitionFrequency)+addon);
    RlxT = str2num(answers{2,1});
    RlxT = AcquisitionFrequency * round(RlxT/AcquisitionFrequency);
    Baseline = str2num(answers{3,1});
    MaxContr = str2num(answers{4,1});
    
    %MxContr = Baseline * ((100-MaxContr)/100);
    
    Contr = Baseline - MaxContr;
    TotalTrace = ContrT+RlxT - (addon*AcquisitionFrequency);
    
    PacingFrequency = 1 / (TraceLength/1000);
    global PacingFrequency
    global Baseline
    global AcquisitionFrequency
    
    
    %Contractile part of the Trace. Contraction is rapid therefore slope
    %gentleness is controlled based on timings
    
    if ContrT == 100
    Cx = 0:AcquisitionFrequency:ContrT;
    Cc = 0.9*(median (Cx));   % later on this should be changed to T50on
    CTr = Contr./(1+exp(-0.8.*(Cx-Cc))); % genlteness of slope
    figure, subplot (3,1,1), plot(Cx,-CTr, 'Linewidth', 2)
            title( 'Contraction Phase')
    else
        if ContrT < 100
    Cx = 0:AcquisitionFrequency:ContrT;
    Cc = 0.9*(median (Cx));   % later on this should be changed to T50on
    CTr = Contr./(1+exp(-0.5.*(Cx-Cc))); % genlteness of slope -0.065
    hold on, subplot (3,1,1), plot(Cx,-CTr, 'Linewidth', 2)
            title( 'Contraction Phase')
    else
        if ContrT > 100
    Cx = 0:AcquisitionFrequency:ContrT;
    Cc = 0.9*(median (Cx));   % later on this should be changed to T50on
    CTr = Contr./(1+exp(-0.03.*(Cx-Cc))); % genlteness of slope -.0.035       For quick downstroke value should be closer to 0.2
    hold on, subplot (3,1,1), plot(Cx,-CTr, 'Linewidth', 2)
            title( 'Contraction Phase')
        end
        end
    end
    
    %Relaxation part of the Trace
    Rx = (ContrT-((addon+2)*AcquisitionFrequency)):AcquisitionFrequency:TotalTrace;
    Rc = 0.95*(median (Rx));   % later on this should be changed to T50on
    RTr = Contr./(1+exp(-0.03.*(Rx-Rc))); % genlteness of slope
    hold on, subplot(3,1,2), plot(Rx,RTr, 'Linewidth', 2), title ('Relaxation Phase')

 
    Cp = mean(CTr);
    for l = 1:length (CTr)
    pt(l,:) = (CTr(l))- 2*(CTr(l)-Cp);
    end
    pt = pt (1:(end-2));
    pt = pt-min(pt);
    pt = pt/max(pt);
    
    RTr = RTr(1:end-2);
    RTr = (RTr-min(RTr))';
    RTr = RTr/max(RTr);
    pt = pt (1:(end-3));
    RTr = RTr(2:(end));
    TRC = vertcat(pt, RTr);
    
    TL = length(TRC);
    DesLength = TraceLength / AcquisitionFrequency;
 if DesLength > TL
     DF = DesLength - TL;
%       = (1:2) * 0.001*Interval
     Start = ones(1,1) * TRC(1);
    
     End =  ones(floor(DF-1),1) * TRC(TL);
%     (35:(35 + DF-2))* 0.001*Interval
 else
     disp('Trace timings appear longer than the desired trace length')
 end
 
 Trace = vertcat(Start, TRC, End);
 Time = 0.001*(AcquisitionFrequency *(1:length(Trace)));
% figure, plot (Time,Trace,'Linewidth', 2)
             
%     serpentine curve 
%     y1 = (a *b* x)
%     y2 = ((x.^2) + (a^2))
%      y = (a *b* x) ./ ((x.^2) + (a^2));
%      figure, plot (y)

% Adjust the contracted sarcomeric length by first adjusting the range of
% the curve
RangeSF = (Baseline - MaxContr); % define a scaling factor to set the range of y values 
SFTrace = Trace * RangeSF;
%figure, plot(Time, SFTrace)


% Adjust the baseline to match relaxed sarcomeric length
if Baseline == 1
    BAtrace = SFTrace;
else if Baseline < 1
        BAtrace = SFTrace - (1 - Baseline);
    else if Baseline > 1
            BAtrace = SFTrace - (SFTrace(1) - Baseline);
        end
    end
end
hold on, subplot(3,1,3), plot (Time, BAtrace, 'Linewidth', 4), title ('Complete Simulated Contraction trace')


%% QC - measuring parameters to confirm matching to original parameters


[SarcomerePeak, CTD, CTD90, CTD50, CTD10, Time_C_peak, T_C_relax, ...
    AvgCalciumTrace, DoverD0, yAVGCalciumTrace_baseline, ...
    Time_to_90a, Time_to_50a, Time_to_10a, Time_to_10Relax, ...
    Time_to_50Relax, Time_to_90Relax, CalciumMagnitude,CalciumTDPre,...
    CalciumTDPost] = SimParameters(BAtrace,(1000/AcquisitionFrequency));


ContrSarcDist = - SarcomerePeak;
ShorteningDuration = CTD;
Time_to_contr = Time_C_peak (1);
Time_to_relax = T_C_relax (1);
Relaxed_sarc_length = -yAVGCalciumTrace_baseline;
Absolute_shortening = CalciumMagnitude;
Perc_shortening = CalciumMagnitude / Relaxed_sarc_length;

Tolerance = 0.10; % 10% tolerance limit to the measured values 
ContrT = AcquisitionFrequency * ((round(ContrT/AcquisitionFrequency))-addon);


if ShorteningDuration < ((1-Tolerance)* (ContrT + RlxT))
disp ('Over 10% deviation of duration of entire trace. Simulated trace is shorter')
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
end
if ShorteningDuration > ((1+Tolerance)* (ContrT + RlxT))
disp ('Over 10% deviation of duration of entire trace. Simulated trace is longer')
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
end
if Time_to_contr < ((1-Tolerance) * ContrT)
    disp ('Over 10% deviation of duration of contraction. Simulated trace is shorter ')
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
end
if Time_to_contr > ((1+Tolerance) * ContrT)
    disp ('Over 10% deviation of duration of contraction. Simulated trace is longer ')
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
end
if Time_to_relax < ((1-Tolerance)* RlxT)
disp ('Over 10% deviation of duration of relaxation. Simulated trace is shorter')
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
end
if Time_to_relax > ((1+Tolerance)* RlxT)
disp ('Over 10% deviation of duration of relaxation. Simulated trace is longer ')
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
end


disp ('Congrats! Your immense skills (defo not this excellent code) have produced the following trace:')


TBL = [Time' BAtrace]
BAtrace
end
% SavePath = uigetdir('D:/','Select DATA directory for files');
% fprintf(1,'>>> Select DATA directory to save in\n' )
% 
% writematrix((TBL),fullfile(SavePath,'Simulated Trace.xlsx'));




