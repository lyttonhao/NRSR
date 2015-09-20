function [result] = func_improve_NL_im(imLR, imHR, imBicubic, h1, v1, l1, r1 )

par.factor = 3;

ee = 2e-5;
p = [0,0,0;1,0,-1;0,0,0];
H = Set_matrix( 1, imLR, p, imHR);
p = [0,1,0;0,0,0;0,-1,0];
V = Set_matrix( 1, imLR, p, imHR);
lf1 = zeros(3,3); lf1(1,1) = 1; lf1(3,3) = -1;
L = Set_matrix( 1, imLR, lf1, imHR);
rf1 = zeros(3,3); rf1(1,3) = 1; rf1(3,1) = -1;
R = Set_matrix( 1, imLR, rf1, imHR);

%sigma = 100;
%weight = exp(abs(h1)/sigma)./(exp(abs(h1)/sigma) + exp(abs(v1)/sigma)+eps);
weight  = abs([h1(:), v1(:)]);%, l1(:), r1(:)]); 
weight = double(weight./(repmat(sum(weight,2)+eps, [1,2])));

te_Out = imBicubic;

 h0 = te_Out;
 
 im_h = h0;
 
[row_h, col_h] = size(im_h);
 
alpha = 0.1;

HTY = H' * double(h1(:));
HTH = H' * H;

VTY = V' * double(v1(:));
VTV = V' * V;

LTY = L' * double(l1(:));
LTL = L' * L;

RTY = R' * double(r1(:));
RTR = R' * R;

f = double(im_h(:));
lamNL = 0.5;
NLiter = 1;


 %gradient descent
for i = 1:10,
     f = f + alpha*( weight(:,1) .* (HTY - HTH*f) +  weight(:,2) .* (VTY - VTV*f) );% + weight(:,3).*(LTY - LTL*f) + weight(:,4) .* (RTY - RTR*f)  );
     %Nonlocal similarity
     for iii =1:NLiter,
          if mod(i, 5) == 1
              im_h = reshape(f, [row_h, col_h]);
              N            =   Compute_NLM_Matrix( im_h, 5, par );
              NTN          =   N'*N*lamNL;
          end
         f         =  f  - NTN*f;     
     end  
end

%back projection
im_h = reshape(f, [row_h, col_h]);
result = backprojection(im_h, imLR, 20);



