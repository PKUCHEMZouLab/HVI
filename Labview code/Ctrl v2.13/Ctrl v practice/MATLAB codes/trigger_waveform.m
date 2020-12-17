% This MATLAB code generate the optopatch waveform file in .txt format, 
% with each column representing each channel.
% red laser is constantly on
% blue laser blinks at regular intervals
% Peng Zou, 2016-07-29

%% Generate waveform - blue pulse and patch ramp
% SAME amplitude for blue light
% Initialization
clear all;
path = 'C:\Users\ZouOptics\Desktop\MATLAB codes\';

file_num = 1;       % file number
samprate = 10;      % kHz

% parameters to change
period = 500;          % msec
pulsewidth = 2;     % msec
cycles = 5;             % number of repeats


% calculations
% laser light
t = 0:(1/samprate):(period*cycles);       % msec
t = t(1:(end-1));                       % 1 less data point
AO1 = ones(1, period*samprate);     % initialize AO
DO1 = zeros(1, period*samprate);     % initialize DO
pulse = ones(1, pulsewidth*samprate);   % pulse signal
% add pulse to blue DO at the beginning
DO1(1:length(pulse)) = pulse;  
% repeat this waveform
AO = repmat(AO1, cycles, 1);
AO = reshape(AO', 1, []);               % column vector
AO = AO';
DO = repmat(DO1, cycles, 1);
DO = reshape(DO', 1, []);               % column vector
DO = DO';

% patch AO
patchAO = (1:length(t))/length(t);      % patch AO ramp

%% Generate waveform - blue pulse and patch ramp
% RAMPING amplitude for blue light
% Initialization
clear all;
path = 'C:\Users\ZouOptics\Desktop\MATLAB codes\waveforms\';

file_num = 2;       % file number
samprate = 10;      % kHz

% parameters to change
period = 500;          % msec
pulsewidth = 2;     % msec
cycles = 8;             % number of repeats
step = 0.2;             % blue command signal in Volt

% calculations
% laser light
t = 0:(1/samprate):(period*cycles);       % msec
t = t(1:(end-1));                       % 1 less data point

% DO waveform
DO1 = zeros(1, period*samprate);     % initialize DO
pulse = ones(1, pulsewidth*samprate);   % pulse signal
% add pulse to blue DO at the beginning
DO1(1:length(pulse)) = pulse;  
% repeat this waveform
DO = repmat(DO1, cycles, 1);            % column vector
DO = reshape(DO', 1, []);               % row vector

% AO waveform
AO1 = [(1:cycles)*step]';               % column vector
AO = repmat(AO1, 1, period*samprate);  % column vector
AO = reshape(AO', 1, []);               % row vector

% patch AO
patchAO = (1:length(t))/length(t);      % patch AO ramp

%% Generate waveform - blue pulse and patch ramp
% LONG and WEAK amplitude for blue light
% Initialization
clear all;
path = 'C:\Users\ZouOptics\Desktop\MATLAB codes\waveforms\';

file_num = 3;       % file number
samprate = 10;      % kHz

% parameters to change
period = 1000;          % msec
pulsewidth = 500;     % msec
cycles = 3;             % number of repeats
step = 0.1;             % blue command signal in Volt

% calculations
% laser light
t = 0:(1/samprate):(period*cycles);       % msec
t = t(1:(end-1));                       % 1 less data point

% DO waveform
DO1 = zeros(1, period*samprate);     % initialize DO
pulse = ones(1, pulsewidth*samprate);   % pulse signal
% add pulse to blue DO at the beginning
DO1(1:length(pulse)) = pulse;  
% repeat this waveform
DO = repmat(DO1, cycles, 1);            % column vector
DO = reshape(DO', 1, []);               % row vector

% AO waveform
AO1 = [(1:cycles)*step]';               % column vector
AO = repmat(AO1, 1, period*samprate);  % column vector
AO = reshape(AO', 1, []);               % row vector

% patch AO
patchAO = (1:length(t))/length(t);      % patch AO ramp


%% Generate waveform - blue pulse and patch ramp
% LONG and WEAK and CONSTANT amplitude for blue light
% Initialization
clear all;
path = 'C:\Users\ZouOptics\Desktop\MATLAB codes\waveforms\';

file_num = 4;       % file number
samprate = 10;      % kHz

% parameters to change
period = 1000;          % msec
pulsewidth = 500;     % msec
cycles = 3;             % number of repeats
amp = 0.1;             % blue command signal in Volt

% calculations
% laser light
t = 0:(1/samprate):(period*cycles);       % msec
t = t(1:(end-1));                       % 1 less data point

% DO waveform
DO1 = zeros(1, period*samprate);     % initialize DO
pulse = ones(1, pulsewidth*samprate);   % pulse signal
% add pulse to blue DO at the beginning
DO1(1:length(pulse)) = pulse;  
% repeat this waveform
DO = repmat(DO1, cycles, 1);            
DO = reshape(DO', 1, []);               % row vector

% AO waveform
AO1 = amp*ones(1, period*samprate);     % initialize AO
% repeat this waveform
AO = repmat(AO1, cycles, 1);            
AO = reshape(AO', 1, []);               % row vector

% patch AO
patchAO = (1:length(t))/length(t);      % patch AO ramp

%% save waveform and export figures
% plot AO waveform
figure; subplot(1,3,1);
title('Analog out');
hold on;
plot(t, AO);
xlabel('time (ms)');
ylabel('Amplitude (V)');
legend('Blue laser');

% plot DO waveform
subplot(1,3,2);
title('Digital out');
hold on;
plot(t, DO);
xlabel('time (ms)');
ylabel('Logic');
legend('Blue laser');

% plot patch AO waveform
subplot(1,3,3);
title('Patch External Command');
hold on;
plot(t, patchAO);
xlabel('time (ms)');
ylabel('Amplitude (V)');

% save waveform figure
saveas(gca,[path num2str(file_num,'%02d') '_acq waveforms.fig']);
saveas(gca,[path num2str(file_num,'%02d') '_acq waveforms.png']);

% save waveform data
% create AO-DO matrix
AO_DO = zeros(2,length(t));
AO_DO(1:2:end,:) = AO;
AO_DO(2:2:end,:) = DO;
fname = [path num2str(file_num,'%02d') '_waveforms.txt'];
fid = fopen(fname, 'w');
fprintf(fid, '%.3f\t%.3f\t%d%.3f\r\n', [t; AO_DO; patchAO]);
fclose(fid);

% save matlab variables
save([path num2str(file_num,'%02d') '_variables.mat'])
clear file_num
