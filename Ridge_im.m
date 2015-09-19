%NRSR Release 1.0
%by Li Yanghao

clear all;clc;

addpath('Flann')
addpath('Data');
addpath('Utilities');
cc = 0;
re = [];

im_path = 'Data/Test/';
im_dir = dir( fullfile(im_path, '*bmp') );
im_num = length( im_dir );


patch_size = 9;  
nSmp        = 1000000;  %number of patches to sample
par.nFactor = 3;   %magnification factor
par.win = patch_size;  %patch size
par.step = 1;          %sample patch step   
par.prunvar = 10;     

%sample train patches
[Cp, Cs] = smp_patch_prod_im( patch_size, nSmp, par);

%build for knn search
dataset = Cp;  
build_params.target_precision = 1;  
build_params.build_weight = 0.5; 
build_params.memory_weight = 0; 
[index, parameters] = flann_build_index(dataset, build_params);

lambda = 0.15;   %ridge parameter
nnn = 9;                %neighbor number
tot = 0;
for img = 1:im_num,

    imHR = imread( fullfile(im_path, im_dir(img).name) );
    
    [im_h, im_w,dummy] = size(imHR);
    im_h = floor((im_h )/par.nFactor)*par.nFactor ;
    im_w = floor((im_w )/par.nFactor)*par.nFactor ;
    imHR=imHR(1:im_h,1:im_w,:);

    ori_HR = imHR;
    if (size(imHR, 3) == 3)
        imHR = double(rgb2ycbcr( imHR ) );
        im_cb = imresize( imHR(:,:,2), 1/par.nFactor, 'Bicubic' );
        im_cr = imresize( imHR(:,:,3), 1/par.nFactor, 'Bicubic' );
        im_cb = imresize( im_cb, par.nFactor, 'Bicubic' );
        im_cr = imresize( im_cr, par.nFactor, 'Bicubic' );
    end
 
    
    imHR = double(imHR(:,:,1));
    imLR = imresize( imHR, 1/par.nFactor, 'Bicubic');  %%LR
    imBicubic = imresize( imLR, [im_h, im_w], 'Bicubic');
       
    fprintf('Bicubic: %2.2f \n', csnr(imHR, imBicubic, 0, 0));
    
    hf1 = [-1,0,1];
    vf1 = [-1,0,1]';
    lf1 = zeros(3,3); lf1(1,1) = -1; lf1(3,3) = 1;
    rf1 = zeros(3,3); rf1(1,3) = -1; rf1(3,1) = 1;
    hf2 = [1,0,-2,0,1];
    vf2 = [1,0,-2,0,1]';
 
   [v2 h1] = data2patch(conv2(double(imBicubic), vf2, 'same'), conv2(double(imBicubic), hf1, 'same'), par);
   [v1, h2] = data2patch(conv2(double(imBicubic), vf1, 'same'), conv2(double( imBicubic), hf2, 'same'), par);
   Tl = [h1;v1];
 
   %search knn
   vec_patches = Tl;
   nn = nnn;
   testset = double(vec_patches);
   [idx,dst] = flann_search(index,testset,nn,parameters);

   Q = zeros(nn,nn);
   output = zeros(patch_size*patch_size*4, size(testset,2));
   for ii = 1:size(testset, 2),
                Ip = testset(:, ii);
                Ipk = zeros(size(testset,1), nn);
                Isk = zeros(size(Cs,1), nn);
                err = zeros(size(Ipk));
            for i=1:nn
                Ipk(:, i) = Cp(:,idx(i,ii));
                Isk(:, i) = Cs(:,idx(i,ii));
            end
      
            Coeff = ( Ipk'*Ipk + lambda*eye(nn) ) \ Ipk' * Ip;  %ridge regression
       
            Is = Isk * Coeff;         
            output(:, ii) = Is;    
   end

        [h1, v1] = patch2data1([output(1:patch_size*patch_size, :);output(patch_size*patch_size+1:patch_size*patch_size*2, :)], im_h, im_w, 1,par.win, par.step);
        [l1, r1] = patch2data1([output(patch_size*patch_size*2+1:patch_size*patch_size*3, :);output(patch_size*patch_size*3+1:patch_size*patch_size*4, :)], im_h, im_w, 1,par.win, par.step);

        result = func_improve_NL_im(imLR, imHR, imBicubic, h1, v1, l1, r1 );
        
        fprintf('%d %d %d %s Result: %2.2f \n',patch_size, nSmp, nnn, im_dir(img).name, csnr(imHR, result, 0, 0));
        tot = tot + csnr(imHR, result, 0, 0);
        
        im_rgb = zeros(size(ori_HR));
        im_rgb(:,:,1) = result;
        imB = zeros(size(imBicubic));
        imB(:,:,1) = imBicubic;
        if size(ori_HR, 3) == 3,
            im_rgb(:,:,2) = im_cb;
            im_rgb(:,:,3) = im_cr;
            im_rgb = ycbcr2rgb( uint8( im_rgb ) );
            imB(:,:,2) = im_cb;
            imB(:,:,3) = im_cr;
            imB = ycbcr2rgb( uint8( imB ) );
        end
    
        savefile( imLR, ori_HR, im_rgb, result, h1, v1, imB, im_dir(img).name);

end
fprintf('average %2.2f\n',tot/im_num);
   
flann_free_index(index);% free the memory      


