function [ klabels] = perform_slic( img,SLIC_sp_num,SLIC_spatial_proximity_weight )
%   perform the image segmentation with SLIC superpixel
%   Input
%     -img   image to process
%     -SLIC_sp_num the number of superpixel
%     -SLIC_spatial_proximity_weight    spatial proximity weight
%   Output
%     -labels
%     -sp_pixel_num  the number of superpixel 
%     -temp_sp_cl_hist  the histogram of superpixels
addpath('./SLIC_Feature');
% compile;
test.labels = SLIC_mex(img,SLIC_sp_num,SLIC_spatial_proximity_weight);
test.warpimg_hsi = rgb2hsi(img);
ch_bins_num=8;
N_superpixels = unique(test.labels);
N_superpixels = N_superpixels(:);
test.sp_num = max(N_superpixels);       % record the number of superpixels of this frame
% [sp_pixel_num,temp_sp_cl_hist] = cal_superpiexl_rgb_hist(test, img);
% [sp_pixel_num, ~, temp_sp_cl_hist] = t1_cal_hsi_hist(test, 1, ch_bins_num, N_superpixels);
klabels=test.labels;
end

