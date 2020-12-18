% dF/F analysis of 150mV voltage change
% for HVI, Ace2N-2AA-mNeon and other GEVIs,
% eg, fig 2C
%% parameters
subfolder = '';
basepath = '';
path = [basepath subfolder];

% constants
movname = '\movie.bin';
ncol = 176;         % x
nrow = 96;         % y
bkg = 400;          % background due to camera bias (100 for bin 1x1)
dt_mov = 0.1;       % exposure time in millisecond
DAQname = '\movie_DAQ.txt';
dnsamp = 100;       % downsampling rate = DAQ rate
dt_daq = 0.001;     % in millisecond

% load movie
fname = [path movname]
[mov, nframe] = readBinMov(fname, nrow, ncol);
mov = double(mov);
img = mean(mov, 3);
len = size(mov,3);
t_mov = [0:(len-1)]*dt_mov;     % time axis in second

% select ROI for analysis
[~, intens] = clicky(mov, img, 'Select only 1 ROI, right click when done');
% save clicky figure
saveas(gca,[path '\clicky analysis_gap junction.fig']);
saveas(gca,[path '\clicky analysis_gap junction.png']);
% normalize intensity wrt -100 mV (in %)
bkg=mean(intens(:,2));
background_reference=sort(reshape(mean(mov,3),ncol*nrow,1));
background_reference=mean(background_reference(10:round(0.05*length(background_reference))))
intens_norm = (intens-background_reference)/(max(intens)-background_reference)*100;
% load DAQ data
tmp = importdata([path DAQname]);   % import data 
data = tmp.data;                    % get array
Vm = data(:,2)*100;     % Vm in millivolt, column vector
% downsample Vm
len = length(Vm);
t_daq = [0:(len-1)]*dt_daq;                 % time axis in millisecond
Vm_dnsamp = mean(reshape(Vm,dnsamp,len/dnsamp));

% plot traces
figure;
% plot F-t
subplot(2,2,1);
plot(t_mov,intens);
xlabel('time (s)');
ylabel('Intens (a.u.)');
axis tight;
% plot Vm-t
subplot(2,2,3);
plot(t_daq,Vm);
ylabel('V_m (mV)');
axis tight;
% plot F-V curve
subplot(2,2,2);
plot(Vm_dnsamp, intens);
xlabel('V_m (mV)');
ylabel('Intensity');
axis tight;
% plot normalized dF/F-V curve
subplot(2,2,4);
plot(Vm_dnsamp, intens_norm);
title('Normalized F-V curve');
xlabel('V_m (mV)');
ylabel('dF/F (%)');
axis tight;

% save F-V figure
saveas(gca,[path '\F-V analysis.fig']);
saveas(gca,[path '\F-V analysis.png']);
%%
V_trace = intens(:,1)-intens(:,2);
subplot(2,1,1)
plot(t_daq,Vm)
box off
ylim([-100 50])
xlabel('time (s)')
ylabel('Vm (mV)')
subplot(2,1,2)
plot(t_mov,V_trace)
box off
axis tight
xlabel('time (s)')
ylabel('Intensity (W/O background)')

param_pbrem = V_trace([28 68 88 128 148 188 208])
param_pbrem = param_pbrem./max(param_pbrem)
p = polyfit([28 68 88 128 148 188 208],param_pbrem',1)
plot([28 68 88 128 148 188 208],param_pbrem')
correct_line = [1:p(1):1+p(1)*(size(V_trace,1)-1)]';
V_rem = V_trace./correct_line;
plot(V_rem)

subplot(2,1,1)
plot(t_mov,V_trace)
box off
axis tight
xlabel('time (s)')
ylabel('Intensity (W/O background)')
title('Before removing PB')
subplot(2,1,2)
plot(t_mov,V_rem)
box off
axis tight
xlabel('time (s)')
ylabel('Intensity (W/O background)')
title('After removing PB')
saveas(gca,[path '\F-V analysis_rem pb.fig']);
saveas(gca,[path '\F-V analysis_rem pb.png']);

figure()
plot(Vm_dnsamp, V_rem./max(V_rem)*100);
title('Normalized F-V curve');
xlabel('V_m (mV)');
ylabel('dF/F (%)');
axis tight;
box off
axis tight
saveas(gca,[path '\F-V analysis_rem pb_stack.fig']);
saveas(gca,[path '\F-V analysis_rem pb_stack.png']);