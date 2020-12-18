% dF/F analysis of step voltage change
% for HVI, Ace2N-2AA-mNeon and other GEVIs,
% eg, fig 2B
%% parameters
subfolder = '';
basepath = 'C:\Users\ZouOptics\Desktop\HVI code\MATLAB analysis\analysis in HEK293T\211335_500ms_1000Hz\';
path = [basepath subfolder];

% constants
movname = '\movie.bin';
ncol = 176;         % x'
nrow = 96;         % y
bkg = 400;          % background due to camera bias (100 for bin 1x1)
dt_mov = 0.9452;       % exposure time in millisecond
DAQname = '\movie_DAQ.txt';
dnsamp = 20;       % downsampling rate = DAQ rate
dt_daq = dt_mov/dnsamp;     % in millisecond

% load movie
fname = [path movname]
[mov, nframe] = readBinMov(fname, nrow, ncol);
mov = double(mov);
img = mean(mov, 3);
len = size(mov,3);
t_mov = [0:(len-1)]*dt_mov*0.001;     % time axis in second

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
% intens_norm = intens_norm./(intens_norm(1,1));
% load DAQ data
tmp = importdata([path DAQname]);   % import data 
data = tmp.data;                    % get array
Vm = data(:,2)*100;     % Vm in millivolt, column vector
% downsample Vm
len = length(Vm);
t_daq = [0:(len-1)]*dt_daq./1000;                 % time axis in second
Vm_dnsamp = mean(reshape(Vm,dnsamp,len/dnsamp));
intens_rembkg = intens(:,1)-intens(:,2);
% plot traces
figure;
% plot F-t
subplot(2,1,1);
plot(t_mov,intens_rembkg);
xlabel('time (s)');
ylabel('Intens (a.u.)');
axis tight;
box off
% plot Vm-t
subplot(2,1,2);
plot(t_daq,Vm);
xlabel('time (s)');
ylabel('V_m (mV)');
axis tight;
box off
% save F-V figure
saveas(gca,[path '\F-V analysis.fig']);
saveas(gca,[path '\F-V analysis.png']);
%%
intens_stack = zeros(1000,11);
for n = 1:11
  intens_stack(:,n) = intens_rembkg((251+1000*(n-1):250+1000*n));
end;
figure();
for n = 1:11
plot([0:dt_mov:(1000-1)*dt_mov]',intens_stack(:,n),'color',getrgb(600)*(11-n)/11);hold on
end
box off
axis tight
xlabel('Time (ms)')
ylabel('Intensity')
saveas(gca,[path '\F-V stack.fig']);
saveas(gca,[path '\F-V stack.png']);

figure();
for n = 1:11
plot([0:dt_mov:(1000-1)*dt_mov]',intens_stack(:,n)./mean(intens_rembkg(1:400)),'color',getrgb(600)*(11-n)/11);hold on
end
box off
axis tight
xlabel('Time (ms)')
ylabel('Normalized Intensity (to -30 mV)')
saveas(gca,[path '\Norm.F-V stack.fig']);
saveas(gca,[path '\Norm.F-V stack.png']);

%% for the colorbar
figure();
temp=[-100:(200/100):100]'
temp = repmat(temp',20,1);
imshow(temp,[])
for n = 1:size(temp,2)
    color_map(:,n) = getrgb(600)*(size(temp,2)-n)/size(temp,2);
end
colormap((color_map)')
saveas(gca,[path '\colorbar.fig']);
saveas(gca,[path '\colorbar.png']);

