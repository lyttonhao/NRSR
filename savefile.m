function [] = savefile(imLR, ori_HR, im_rgb, result, h1, v1, imbicubic, filename)
    
    filename = filename(1:end-4);
    imLR = imresize( ori_HR, 1.0/3, 'Bicubic');
    imwrite(uint8(imLR),  ['Result\', filename, '_LR.bmp']);
    imwrite(uint8(ori_HR),  ['Result\', filename, '_HR.bmp']);
    imwrite(uint8(im_rgb),  ['Result\', filename, '_rgb.bmp']);
    imwrite(uint8(result),  ['Result\', filename, '_result.bmp']);
    imwrite(mat2gray(h1),  ['Result\', filename, '_H.bmp']);
    imwrite(mat2gray(v1),  ['Result\', filename, '_V.bmp']);
    imwrite(uint8(imbicubic),  ['Result\', filename, '_bicubic.bmp']);
end