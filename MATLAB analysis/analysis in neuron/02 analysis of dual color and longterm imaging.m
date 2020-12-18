% pay attention to the ncol,nrow,dt_mov,testmode,camera_bias,basepath,subfolder and line 86!
% dF/F analysis of neural activity
% for HVI, Ace2N-2AA-mNeon and other GEVIs,
% eg, fig 3d,4b
%% load and select
clear all; clc;
% Movie loading path
% Firstly, determine patch or optopatch.1¡úpatch£¬2¡úoptopatch
testmode = 1
if testmode == 1
    dt_mov = 2.0658;
    dnsamp = 9681.4793/(1/dt_mov);        % downsampling rate = DAQ rate/camera rate
else
    dt_mov = 20;
    dnsamp = 10471.2/(1/dt_mov);        % downsampling rate = DAQ rate/camera rate
end
subfolder = '';
basepath = 'C:\Users\ZouOptics\Desktop\HVI code\MATLAB analysis\analysis in neuron\dual_spon2\';
pathname = [basepath subfolder];

% constants
movname = '\movie.bin';
ncol = 512;         % x
nrow = 104;          % y
camera_bias = 1600;          % background due to camera bias (100 for bin 1x1)
DAQname = '\movie_DAQ.txt';

% load movie
fname = [pathname movname];
[mov, nframe] = readBinMov(fname, nrow, ncol);
mov = double(mov);
img = mean(mov, 3);
len = size(mov,3);
t_mov = [0:(len-1)]*dt_mov/1000;     % time axis in second


% select ROI for analysis
[~, intens] = clicky(mov, img, 'Select only 1 ROI, right click when done');
background = mean(intens(:,2));
% save clicky figure
saveas(gca,[pathname '\clicky analysis_V.fig']);
saveas(gca,[pathname '\clicky analysis_V.png']);



% load DAQ data
% load DAQ data
%tmp = importdata([pathname DAQname]);   % import data 
%data = tmp.data;                    % get array
%Vm = data(:,2)*100;                 % Vm in millivolt, column vector
%dt_daq = dt_mov/dnsamp;             % DAQ dt in millisecond
%t_daq = [0:length(Vm)-1]*dt_daq;       % DAQ time axis in second
%% plot Vm-t and Intensity-t
figure
subplot(3,1,1)
plot(mat2gray(img));% gray img plot
imshow(mat2gray(img));
title('selected cell');
%subplot(3,1,2)
%plot(t_daq,Vm);
%title('membrane voltage signal');
%xlabel('t(s)');
%ylabel('Vm (mV)');
%axis tight;
%hold on
%xL=[0,max(t_mov)];yL=[min(Vm)-10,max(Vm)+10];% range of figure
%plot(xL,[yL(2),yL(2)],'w',[xL(2),xL(2)],[yL(1),yL(2)],'w');hold on
%plot([60:10:100], [-52 -52 -52 -52 -52],'.','Color',[0.99 0 0 ]) ;hold on;
%plot([60 max(t_daq)], [-50 -50],'r','LineWidth',3) ;hold on
%box off
%axis tight
%box off 
subplot(3,1,3)
plot(t_mov,intens(:,1)-background);
hold on
title('Optical signal');
xlabel('t(s)');
ylabel('intensity (W/O background)');
axis tight;
xL=[0,max(t_mov)];yL=[min(intens(:,1)-background)-2,max(intens(:,1)-background)+2];% range of figure
plot(xL,[yL(2),yL(2)],'w',[xL(2),xL(2)],[yL(1),yL(2)],'w')
box off
set(gcf,'outerposition',get(0,'screensize'));
saveas(gca,[pathname '\integrated analysis_1.fig'])
saveas(gca,[pathname '\integrated analysis_1.png'])

%% calibration of photobleaching
h=open('C:\Users\ZouOptics\Desktop\HVI code\MATLAB analysis\analysis in neuron\dual_spon2\0clicky analysis.fig');
h=get(gca,'children')
data=get(h,{'xdata','ydata'})
% for n = 1:length(data);
%     data1(:,n) = data{n,2};
% end
raw_trace = data{2,2}-data{1,2};
dire = -1
[rem_trace, pbleach] = rem_pbleach_noNorm(dire*raw_trace, 1000);
pbleach = dire*pbleach;
dt_mov = 2.0658/1000;% in seconds
t_mov = [0:dt_mov:dt_mov*(size(raw_trace,2)-1)];
% plot(pbleach);
figure()
plot(t_mov,rem_trace);
box off
axis tight
xlabel('Time (s)')
ylabel('Intensity w/o background')
title('')

% test = fliplr(test);
% test = test +100;
% [rem_trace, pbleach] = rem_pbleach_noNorm(dire*test, 5);
% pbleach = dire*pbleach;
% plot(pbleach);
% plot(rem_trace)