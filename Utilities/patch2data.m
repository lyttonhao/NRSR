function [im_pout, im_sout] = patch2data(Y, h,w,ch, b, s)
im_pout   =  zeros(h,w,ch, 'single');
im_sout   =  zeros(h,w,ch, 'single');
im_wei   =  zeros(h,w,ch, 'single');
k        =  0;
b2         =   b*b*2;
k          =   0;


N       =  h-b+1;
M       =  w-b+1;

r     =  [1:s:N];
r     =  [r r(end)+1:N];
c     =  [1:s:M];
c     =  [c c(end)+1:M];
N       =  length(r);
M       =  length(c);
L       =  length(r)*length(c)*ch;

for i  = 1:b
    for j  = 1:b
        k    =  k+1;
        im_pout(r-1+i,c-1+j,:)  =  im_pout(r-1+i,c-1+j,:) + reshape( Y(k,:)', [N M ch]);
        im_wei(r-1+i,c-1+j,:)  =  im_wei(r-1+i,c-1+j,:) + 1;       
    end
end
for i  = 1:b
    for j  = 1:b
        k    =  k+1;
        im_sout(r-1+i,c-1+j,:)  =  im_sout(r-1+i,c-1+j,:) + reshape( Y(k,:)', [N M ch]);
    end
end
im_sout  =  im_sout./(im_wei+eps);
im_pout  =  im_pout./(im_wei+eps);