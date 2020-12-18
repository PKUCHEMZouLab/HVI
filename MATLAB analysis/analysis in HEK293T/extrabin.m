function [mov_new] = extrabin(movie_in, times);

mov_new = zeros(size(movie_in,1)./times,size(movie_in,2)./times,size(movie_in,3));
tic
for n = 1:size(movie_in,1)./times
    for k=1:size(movie_in,2)./times
    mov_new(n,k,:) = movie_in(2*n-1,2*k-1,:)+movie_in(2*n-1,2*k,:)+movie_in(2*n,2*k-1,:)+movie_in(2*n,2*k,:);
end
end
toc