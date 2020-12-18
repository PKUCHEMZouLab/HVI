% analysis of voltage-glutmate dual signal
% for HVI and other GEVIs,
% eg, fig s6g
% pay attention to the ncol,nrow,dt_mov,camera_bias,basepath,subfolder and line 47!
% line 47 generate a figure and please left click the desired signal
% peak,than press Enter.
% you may have to save the result manually
%%
clear all; clc;
% Movie loading path
basepath = 'C:\Users\ZouOptics\Desktop\HVI code\MATLAB analysis\analysis in neuron\bin4_10mM_50-100s\';
% subfolder = '\154450_current injection_step\'
pathname = [basepath '\']
mkdir([pathname '\analysis\'])

%% Load the .bin movie data
movname = '\movie.bin';
ncol = 512;         % x
nrow = 104;         % y
camera_bias = 1600;  % background due to camera bias (100 for bin 1x1)
dt_mov = 2.0658;    % exposure time in millisecond (484 Hz)
movname = '\movie.bin';
ysize=nrow;
xsize=ncol;
DAQname = '\movie_DAQ.txt';

% load bin movie
fname = [pathname movname];
[mov1, nframes] = readBinMov(fname, nrow, ncol);
mov1= double(mov1);
% mov1 = mov1(:,102:281,:);
[nrow,ncol,nframe]=size(mov1);

%% Split the movie: movie_left : glutamate; movie_right: HVI-Cy5 (Voltage)

imwrite(uint16(mean(mov1,3)),[pathname  'analysis\mean image.tif'],'WriteMode', 'append',  'Compression','none') %write the first category
xywh = [52 1 169 99];
x = xywh(1);
y = xywh(2);
w = xywh(3);
h = xywh(4);
mean_left = imcrop(mean(mov1,3),[1558 1605],xywh);% here we extract the cell from the raw images
mean_right = imcrop(mean(mov1,3),[1558 1605],[(xywh(1))+340-118 (xywh(2))+3 xywh(3:4)]);% here we extract the cell from the raw images
parameter_x = 340-118;
parameter_y = 3;
imwrite(uint16(mean_left),[pathname  'analysis\mean image_left.tif'],'WriteMode', 'append',  'Compression','none') %write the first category
imwrite(uint16(mean_right),[pathname  'analysis\mean image_right.tif'],'WriteMode', 'append',  'Compression','none') %write the first category

%% choose signal peak in left channel (Glu)
mov_left = mov1(y:y+h,x:x+w,:);
mov_right = mov1(y+parameter_y:y+h+parameter_y,x+parameter_x:x+w+parameter_x,:);
figure()
plot(smooth(smooth(squeeze(mean(mean(mov_left))))));
title('Click one time on the selected Glutamate trace, then press enter')
[locx,locy] = ginput();
frame_back = 1500;
frame_after = 2499;% frame_back and frame_after define the range of data for generating heatmap
mov_left_1 = mov_left(:,:,round(locx(1))-frame_back:round(locx(1))+frame_after);

%% select mask for cell
extrabin_times = 1;
[mov_left_1] = extrabin(mov_left_1, extrabin_times);% When extrabin_times = 1, then increase bin to 8
[roi_points_out,inpoly_out] = clicky_getpoly(mov_left_1, 8, mean(mov_left_1,3));
% in inpoly_out (selected region in the clicky window), 1st region is an outline of the cell, 
% and 2nd to last regions are "hollowed-out regions" in the cell 
region_ejection = [];
for n = 2:size(inpoly_out,2)
    region_ejection = [region_ejection inpoly_out{1,n}];
end
region_ejection = reshape(region_ejection,[size(mean(mov_left_1,3)) (size(inpoly_out,2)-1)]);
region_ejection = repmat(ones(size(mean(mov_left_1,3))),[1 1 size(region_ejection,3)])-region_ejection;

mask = inpoly_out{1,1};
for n = 1:size(region_ejection,3)
    mask = mask.*region_ejection(:,:,n);
end

figure()
set(gcf,'outerposition',get(0,'screensize'));
imshow(mask,[]);%check the selected mask
title('Selected mask')
saveas(gcf,[pathname  'analysis\mask.fig'])
saveas(gcf,[pathname  'analysis\mask.png'])
%% dF/F analysis

% mov_left_1 = temp
for xx = 1:size(mov_left_1,1);
   for yy = 1:size(mov_left_1,2)
    mov_left_1(xx,yy,:) = smooth(mov_left_1(xx,yy,:),25);
end
end

% peak location = frame_back+1, here is 1501
bkg_heatmap = camera_bias*power(4,extrabin_times)-70;
dF_F_left_1 = (max(mov_left_1(:,:,frame_back-70:frame_back+100),[],3)-mean(mov_left_1(:,:,frame_back-200:frame_back-100),3))./(mean(mov_left_1(:,:,frame_back-200:frame_back-100),3)-bkg_heatmap);

figure()
set(gcf,'outerposition',get(0,'screensize'));
imshow(dF_F_left_1.*mask,[0 0.8])%Amplitude: deltaF/F
colormap jet
colorbar
title(colorbar,'\Delta F/F')
title('\Delta F/F heat map of Glu')
saveas(gcf,[pathname  'analysis\DF over F heat map of Glu.fig'])
saveas(gcf,[pathname  'analysis\DF over F heat map of Glu.png'])

figure()
set(gcf,'outerposition',get(0,'screensize'));
imshow(mean(mov_left_1(:,:,1:1400),3)-bkg_heatmap,[0 2000])%Fluorescence intensity, F0
colormap jet
colorbar
title(colorbar,'F_0')
title('Fluorescence of Glu')
saveas(gcf,[pathname  'analysis\Fluorescence of Glu.fig'])
saveas(gcf,[pathname  'analysis\Fluorescence of Glu.png'])
%% generate figure of masked maximal fluorescent signal
[~,locs_glu] = max(mov_left_1,[],3);
figure()
set(gcf,'outerposition',get(0,'screensize'));
subplot(2,1,1)
title(subplot(2,1,1),'Peak time of Glu increase')
imshow(locs_glu.*mask,[frame_back-50 frame_back+50])%Peak-time location
colormap jet
colorbar
title(colorbar,'Peak time (frame number)')

subplot(2,1,2)
imshow(dF_F_left_1.*mask,[0 0.8])%Amplitude: deltaF/F
colormap jet
colorbar
title(colorbar,'\Delta F/F')
title(subplot(2,1,1),'Peak time of Glu increase')
title(subplot(2,1,2),'\Delta F/F heat map of Glu')
saveas(gcf,[pathname  'analysis\Peak time and amplitude display.fig'])
saveas(gcf,[pathname  'analysis\Peak time and amplitude display.png'])
% plot(squeeze(sum(sum((mov_left_1).*repmat(mask, [1, 1, 4000]))))/sum(mask(:)))
% 
% maskT = 1-mask;
% 
% plot(squeeze(sum(sum((mov_left_1).*repmat(1-mask, [1, 1, 4000]))))/sum(maskT(:)))

%%
% Tiff([pathname  'analysis' '\tifstack.tif'],'w')
% for num_tiff=1:size(mov_left_1,3)
%    imwrite(uint16(mov_left_1(:,:,num_tiff)),['C:\Users\ZouOptics\Desktop\tifstack.tif'],'WriteMode', 'append',  'Compression','none') %write the first category
% end
%%
% plot(squeeze(sum(sum((mov_left).*repmat(mask, [1, 1, 24200]))))/sum(mask(:)))

