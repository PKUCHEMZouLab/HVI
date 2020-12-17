% This MATLAB code generate the waveform file in .txt format, with each
% column representing each channel.  For now, we are only implementing 
% electrophysiology control.  The first column is AO (External command)
% No control for lasers
% The phase is always -90 degree (i.e. starting from low)

% Peng Zou, 2016-07-20

%% Generate waveform
% Initialization
clear all;
path = 'C:\Users\ZouOptics\Desktop\Ctrl v2.11 test\MATLAB codes\waveforms\';

file_num = 1;       % file number
samprate = 10;      % kHz

% parameters to change
low = 0;            % mV in real unit
high = 500;         % mV in real unit
period = 2;         % sec
cycles = 2;         % number of cycles

% calculations
stepsize = (high - low)/(period/2)/samprate/1000;    % mV in real unit
riseVec = low:stepsize:(high - stepsize);       % rising vector
fallVec = high:(-stepsize):(low + stepsize);    % falling vector

AO = repmat([riseVec, fallVec],1,cycles);       % Analog out waveform
t = 0:(1/samprate):(period*cycles*1000);        % msec
t = t(1:(end-1));                               % 1 less data point

%% save waveform and export figures
% plot waveform
figure;
title('Analog out (ephys)');
hold on;
plot(t, AO);
xlabel('time (ms)');
ylabel('voltage (mV)');
legend('External command');

% save waveform figure
saveas(gca,[path num2str(file_num,'%02d') '_ephys waveforms.fig']);
saveas(gca,[path num2str(file_num,'%02d') '_ephys waveforms.png']);

% save waveform data
fname = [path num2str(file_num,'%02d') '_waveforms.txt'];
fid = fopen(fname, 'w');
fprintf(fid, '%.3f\t%.1f\r\n', [t; AO]);
fclose(fid);

% save matlab variables
save([path num2str(file_num,'%02d') '_variables.mat'])
clear file_num
