function [model train_sample param1]= init2(img,param)
% function init(img,opt)
% Init the tracker
%   Input
%     -img   the image
%     -bb    target location obtained in first frame
%     -param  parameters for inition
%   Output
%
%   首先在目标周围进行采样，构建样本空间，利用粒子滤波框架进行
addpath('./Affine Sample Functions');
rect=param.init_rect;
p = [rect(1)+rect(3)/2, rect(2)+rect(4)/2, rect(3), rect(4), 0];
sz = param.psize;
param0 = [p(1), p(2), p(3)/sz(1), p(5), p(4)/p(3), 0]; %param0 = [px, py, sc, th,ratio,phi];
param0 = affparam2mat(param0);
p0 = p(4)/p(3);
param1 = [];
param1.est = param0';
num_p = 50;
num_n = 200;
% ----------新增的测试代码-----------------------------------------
% 现在上一帧周围进行超像素分割
grid_ratio=2.5;
image_size.cx=size(img,2);
image_size.cy=size(img,1);
temp_length = uint16(norm([rect(3)/2,rect(4)/2])*grid_ratio);
last_box = zeros(1,4);
last_box(1) = max(1,rect(1) - temp_length);
last_box(2) = max(1,rect(2) - temp_length);
last_box(3) = min(image_size.cx ,rect(1) + temp_length);
last_box(4) = min(image_size.cy ,rect(2) + temp_length);
% last_box(1) =1;
% last_box(2) =1;
% last_box(3) = size(img,1);
% last_box(4) = size(img,2);
warpimg = img(last_box(2) : last_box(4),...
    last_box(1) : last_box(3), :);
SLIC_sp_num=100;  %超像素的个数
SLIC_spatial_proximity_weight=10;
% [ klabels, sp_pixel_num, temp_sp_cl_hist ] = perform_slic( warpimg,SLIC_sp_num,SLIC_spatial_proximity_weight );
%----------以上为新增的代码，主要为在上一帧位置周围一定范围内做超像素分割----------------------------------------------
[ klabels] = perform_slic( warpimg,SLIC_sp_num,SLIC_spatial_proximity_weight );

sp_feature_num=25;
sp_feature_dimention=768;
% 获取全局模型的训练样本
[pos_Param neg_Param] = affineTrainG2(sz, param, param1, num_p, num_n, p0);   % obtain positive and negative templates for the holistic templates
% pos_rect=zeros(4,size(pos_Param.param,2));
P_Feature=zeros(sp_feature_dimention*sp_feature_num,size(pos_Param.param,2));
for i=1:size(pos_Param.param,2)
    pos_affine=affparam2mat(pos_Param.param(:,i));
    M = [pos_affine(1) pos_affine(3) pos_affine(4); pos_affine(2) pos_affine(5) pos_affine(6)];
    w=sz(1);
    h=sz(2);
    corners = [ 1,-w/2,-h/2; 1,w/2,-h/2; 1,w/2,h/2; 1,-w/2,h/2; 1,-w/2,-h/2 ]';
    corners = M * corners;
    temp_pp(1)=corners(1,1);
    temp_pp(2)=corners(2,1);
    temp_pp(3)=corners(1,2)-corners(1,1);
    temp_pp(4)=corners(2,3)-corners(2,2);
    %     pos_rect(:,i)=temp_pp;
    lable_x= max(1,round(temp_pp(2)-last_box(2)+1));
    lable_xmax=min(round(lable_x+temp_pp(4)),size(klabels,1));
    lable_y= max(1,round(temp_pp(1)-last_box(1)+1));
    lable_ymax=min(round(lable_y+temp_pp(3)),size(klabels,2));
    labels=klabels(lable_x:lable_xmax,lable_y:lable_ymax);
    %     ---------修改于3.3
    img_x= lable_x+last_box(2);
    img_xmax=min(round(img_x+temp_pp(4)),image_size.cy);
    img_y= lable_y+last_box(1);
    img_ymax=min(round(img_y+temp_pp(3)),image_size.cx);
    tempwarpimg = img(img_x : img_xmax,...
        img_y : img_ymax, :);
    %     N_superpixels = unique(labels);
    %     test.sp_num = size(N_superpixels,1);
    %     test.labels =labels;
    %     temp_hist=temp_sp_cl_hist(:,N_superpixels);
    [temp_hist] = cal_each_s_rgb_hist(labels, tempwarpimg);
    %     ---------修改于3.3 ,下面也同时修改
    % 尝试对每一个样本分别计算直方图
    hist_size=size(temp_hist,2);
%     disp(['p_sample hist_size:' num2str(hist_size)]);
    pos_feature=zeros(sp_feature_dimention,sp_feature_num);
    if(hist_size<sp_feature_num)
        pos_feature(:,1:hist_size)=temp_hist;
    elseif(hist_size>sp_feature_num)
        pos_feature=temp_hist(:,1:sp_feature_num);
    else
        pos_feature=temp_hist;
    end
    pos_feature=reshape(pos_feature,sp_feature_dimention*sp_feature_num,1);
    P_Feature(:,i)=pos_feature;
end
% neg_AffineParam=affparam2mat(neg_Param.param);
% temp_pos= [neg_AffineParam(1),neg_AffineParam(2),neg_AffineParam(3)*sz(2),neg_AffineParam(5)*neg_AffineParam(3)*sz(1),neg_AffineParam(4)];
N_Feature=zeros(sp_feature_dimention*sp_feature_num,size(neg_Param.param,2));
for j=1:size(neg_Param.param,2)
    neg_affine=affparam2mat(neg_Param.param(:,j));
    M = [neg_affine(1) neg_affine(3) neg_affine(4); neg_affine(2) neg_affine(5) pos_affine(6)];
    w=sz(1);
    h=sz(2);
    corners = [ 1,-w/2,-h/2; 1,w/2,-h/2; 1,w/2,h/2; 1,-w/2,h/2; 1,-w/2,-h/2 ]';
    corners = M * corners;
    temp_pp(1)=corners(1,1);
    temp_pp(2)=corners(2,1);
    temp_pp(3)=corners(1,2)-corners(1,1);
    temp_pp(4)=corners(2,3)-corners(2,2);
    %     pos_rect(:,i)=temp_pp;
    lable_x= max(1,round(temp_pp(2)-last_box(2)+1));
    lable_xmax=min(lable_x+temp_pp(4),size(klabels,1));
    lable_y= max(1,round(temp_pp(1)-last_box(1)+1));
    lable_ymax=min(lable_y+temp_pp(3),size(klabels,2));
    labels=klabels(lable_x:lable_xmax,lable_y:lable_ymax);
    %     N_superpixels = unique(labels);
    %     temp_hist=temp_sp_cl_hist(:,N_superpixels);
    img_x= lable_x+last_box(2);
    img_xmax=min(round(img_x+temp_pp(4)),image_size.cy);
    img_y= lable_y+last_box(1);
    img_ymax=min(round(img_y+temp_pp(3)),image_size.cx);
    tempwarpimg = img(img_x : img_xmax,...
        img_y : img_ymax, :);
    %     N_superpixels = unique(labels);
    %     test.sp_num = size(N_superpixels,1);
    %     test.labels =labels;
    %     temp_hist=temp_sp_cl_hist(:,N_superpixels);
    
    [temp_hist] = cal_each_s_rgb_hist(labels, tempwarpimg);
    hist_size=size(temp_hist,2);
%     disp(['n_sample hist_size:' num2str(hist_size)]);
    neg_feature=zeros(sp_feature_dimention,sp_feature_num);
    if(hist_size<sp_feature_num)
        neg_feature(:,1:hist_size)=temp_hist;
    elseif(hist_size>sp_feature_num)
        neg_feature=temp_hist(:,1:sp_feature_num);
    else
        neg_feature=temp_hist;
    end
    neg_feature=reshape(neg_feature,sp_feature_dimention*sp_feature_num,1);
    N_Feature(:,j)=neg_feature;
end
A_pos = P_Feature';
A_neg = N_Feature';
% use no feature to train classifier
sample=[A_pos;A_neg];
% use hog feature to train classifier
% sample_feature=featureExtractor(sample,'super_hist');
% train_sample=sample_feature; % or train_sample=sample;
train_sample=sample;
train_sample = normVector(train_sample);
% 对样本进行特征提取
% 选择libsvm做为分类器，训练分类器
% test=A_pos(1,:);
% test_result=reshape(test,32,32);
% imshow(test_result);
lable_p=ones(num_p,1);
lable_n=-1*ones(num_n,1);
train_lable=[lable_p;lable_n];
model=libsvmtrain(train_lable,train_sample,'-c 1 -g 0.07');%'-c 1 -g 0.07'
% [predict_label, accuracy, dec_values] = libsvmpredict(train_lable, train_sample, model);
end


