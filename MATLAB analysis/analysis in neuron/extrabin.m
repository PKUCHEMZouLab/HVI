function [mov_new] = extrabin(movie_in, times);
order = 0;
raw = movie_in;
while order < times
temp = raw(1:2:size(raw,1)-1,:,:)+raw(2:2:size(raw,1),:,:);
temp = temp(:,1:2:size(raw,2)-1,:)+temp(:,2:2:size(raw,2),:);
order = order + 1
raw = temp;
clear temp
end
mov_new = raw;
