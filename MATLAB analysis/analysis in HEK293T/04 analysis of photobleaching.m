% photobleaching curve analysis of sensors
% for HVI, Ace2N-2AA-mNeon and other GEVIs,
% eg, fig S4g

%% load a bin file to MATLAB
%parameters
clear all;clc;
subfolder = '';
basepath = '';
pathname = [basepath subfolder];

% constants
movname = '\movie.bin';
ncol = 176;          % x
nrow = 96;          % y
bin = 2;             % bin
bkg = 100*power(bin,2);          % background due to camera bias (100 for bin 1x1)
dt_mov = 100/1000;         % exposure time in second
% DAQname = '\movie_DAQ.txt';
% dnsamp = 10;        % downsampling rate = DAQ rate/camera rate
% dt_daq = 1000/9681.4795;       % in millisecond

% load movie
fname = [pathname movname];
[mov, nframe] = readBinMov(fname, nrow, ncol);
img = mean(mov, 3);
len = size(mov,3);
t_mov = [0:(len-1)]*dt_mov;     % time axis in second
%img = mean(mov(:,:,1:150), 3);
% select ROI for analysis
% [mov_new] = extrabin(mov, 2);
mov = single(mov);
glo_intens = squeeze(mean(mean(mov)))-100*power(bin,2);
figure();
plot(t_mov,glo_intens)
box off
axis tight
xlabel('Time (s)')
ylabel('Intensity (W/O background)')
title('')
% save clicky figure
saveas(gca,[pathname '\global analysis.fig']);
saveas(gca,[pathname '\global analysis.png']);
%%
[mov_new] = extrabin(mov, 2);
mov = single(mov_new);
%%
[roi_points,intens] = clicky_v2single(mov, dt_mov, 4, mean(mov,3), 1600 , 6000, '');
saveas(gca,[pathname '\clicky analysis.fig']);
saveas(gca,[pathname '\clicky analysis.png']);
start_frame = 1;
intens_cell = intens(start_frame:end,1)-intens(start_frame:end,2);
[F,gof] = fit(t_mov(start_frame:end)',intens_cell,'exp1');
tau = -1/F.b;
fp=fopen([pathname '\tau.txt'],'a');
fprintf(fp,'%4f',tau);%注意：%d后有逗号。
fclose(fp);
bright = mean(intens_cell(1));
fp=fopen([pathname '\brightness.txt'],'a');
fprintf(fp,'%4f',bright);%注意：%d后有逗号。
fclose(fp);

temp = smooth(intens_cell,1);
temp2 = temp<=0.5*bright;
[a,b] = find(temp2 == 1, 1 );
t1_2 = (a-1)*dt_mov;
fp=fopen([pathname '\t1_2.txt'],'a');
fprintf(fp,'%4f',t1_2);%注意：%d后有逗号。
fclose(fp);
plot(F.a*exp(t_mov*F.b));hold on
plot(intens_cell);
