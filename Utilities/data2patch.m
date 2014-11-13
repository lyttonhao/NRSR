function [Xp Xs] = data2patch(trainPhoto, trainSketch, par)
[h w ch]   =   size(trainPhoto);

b          =   par.win;
b2         =   b*b*2;
k          =   0;
s          =   par.step;


N       =  h-b+1;
M       =  w-b+1;

r     =  [1:s:N];
r     =  [r r(end)+1:N];
c     =  [1:s:M];
c     =  [c c(end)+1:M];

Xp      =  zeros(b*b,length(r)*length(c)*ch, 'single');
Xs      =  zeros(b*b,length(r)*length(c)*ch, 'single');

N       =  length(r);
M       =  length(c);
L       =  size(Xp, 2);


for i  = 1:b
    for j  = 1:b
        k        =  k+1;        
        blk  =  trainPhoto(r-1+i,c-1+j,:);
        Xp(k,:)  =  blk(:)';
        blk  =  trainSketch(r-1+i,c-1+j,:);
        Xs(k,:)  =  blk(:)';
    end
end
