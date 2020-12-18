% Copyright (c) 2013, Adam Cohen
% All rights reserved.
% 
% Redistribution in source or binary forms, with or without modification,
% is not permitted
%        
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [kernel, spiketimes, kernel_org, spiketimes_org] = spikefind_corr(pathway, intens, nback, nfront, thresh)
% function [kernel, spiketimes] = spikefind_corr(intens, nback, nfront, pathway, thresh);
% Find the indices of spikes in intens, using an iterative convolution
% approach to find the times when each spike best matches the average spike
% waveform.  
% Thresh is an optional argument giving the initial threshold value to use.
% If Thresh is not specified then the function prompts the user to select
% a threshold by clicking on a plot of intens.
% AEC 12/22/2012

nsamp = length(intens);  % number of samples

figure;
plot(intens)
if nargin == 4;
    title('Right-click to indicate threshold')
    [x, y] = getpts(gca);
    thresh = y(end)
end;
hold all;
plot([1 nsamp], [thresh thresh], 'r-');

spikeT = spikefind(intens, thresh);  % The second argument is the threshold above which each spike must go.
%throw out first or last spikes if there is not space to look before and after each spike
cutEnd = 0;
if spikeT(end) > nsamp - nfront;
    spikeT(end) = [];
    cutEnd = 1;
end;
cutBeg = 0;
if spikeT(1) < nback + 1;
    spikeT(1) = [];
    cutBeg = 1;
end

nspike = size(spikeT,2);

% Plot the spikes overlaid on the data.  Each spike should be marked by a
% red star.
plot(spikeT, intens(spikeT), 'r*')
% Decide how many frames before and after each spike to look.  At 1
% ms/frame, we typically look back 25 frames, and forward 74 frames.
Lk = nfront + nback + 1;  % Length of the kernel
spikemat = zeros(Lk, nspike);  % This will hold all the spikes lined up
% Fill the spike matrix
for j = 1:nspike
    spikemat(:,j) = intens((spikeT(j)-nback):(spikeT(j) + nfront));
end;
kernel1 = mean(spikemat,2);
kernel1 = kernel1 - mean(kernel1);  % set the mean value of the kernel to zero

intenscov = imfilter(intens, kernel1, 'replicate', 'corr');  % fit the data trace with the kernel
intenscov = mat2gray(intenscov)*(max(intens) - min(intens)) + min(intens);  % scale to intens
spikeT2 = spikefind(intenscov, thresh);

%throw out first or last spikes if there is not space to look before and after each spike
if cutEnd;
    spikeT2(end) = [];
end;
if cutBeg;
    spikeT2(1) = [];
end

% Calculate the offset to adjust the timing
Toff = round(mean(spikeT2) - mean(spikeT));
intenscov = circshift(intenscov, -Toff);
spikeT2 = spikeT2 - Toff;
plot(intenscov)

if spikeT2(end) > nsamp - nfront;
    spikeT2(end) = [];
end;
if spikeT2(1) < nback + 1;
    spikeT2(1) = [];
end
nspike = length(spikeT2);

plot(spikeT2, intens(spikeT2), 'go')
legend('Input', 'Threshold', 'Spike times', 'smoothed input', 'Refined spike times')
hold off;
saveas(gca, [pathway 'Spike selection.fig']);
saveas(gca, [pathway 'Spike selection.png']);
spikemat2 = zeros(Lk, nspike);  % This will hold all the spikes lined up
% Fill the spike matrix
for j = 1:nspike
    spikemat2(:,j) = intens((spikeT2(j)-nback):(spikeT2(j) + nfront));
end;
kernel2=mean(spikemat2,2);
kernel2 = kernel2 - mean(kernel2);  % set the mean value of the kernel to zero
figure;
plot(1:Lk, kernel1, 1:Lk, kernel2)
xlabel('Frame number');
ylabel('Intensity (A.U.)')
legend('kernel 1', 'kernel 2')
saveas(gca, [pathway 'Kernel.fig']);
saveas(gca, [pathway 'Kernel.png']);

figure;
pcolor(spikemat2);
shading 'interp'
title(['All ' num2str(nspike) ' spikes aligned in time'])
xlabel('Spike number')
ylabel('Frame number')
saveas(gca, [pathway 'Spike aligned in time.fig']);
saveas(gca, [pathway 'Spike aligned in time.png']);

kernel_org = kernel1;
spiketimes_org = spikeT;
kernel = kernel2;
spiketimes = spikeT2;




