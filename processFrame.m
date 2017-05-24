% --------------------------------------------------------------
% This function is used to process every frame of input dataset,
% return the result index of the best candidate.
% -------------------------------------------------------------

function [AffineParam result_idx result_rect] = processFrame(img,param,AffineParam,model,result_rect)
%   process every frame of image sequences
%   Input
%     -img   image of frame i
%     -param param of inition
%     -AffineParam  affine parameter
%   Output
%     -result_bb    Result location of frame i (moved latter)
%     -AffineParam  affine parameter
%     -result_idx   index of the best candidate

% draw N candidates with particle filter
% Norm the candidates
% candidate_feature=featureExtractor(Y','super_hist');
% candidate_all=candidate_feature;
% ------------------新增代码----20160223
grid_ratio=2.5;
image_size.cx=size(img,2);
image_size.cy=size(img,1);
temp_length = uint16(norm([result_rect(3)/2,result_rect(4)/2])*grid_ratio);
last_box = zeros(1,4);
last_box(1) = max(1,result_rect(1) - temp_length);
last_box(2) = max(1,result_rect(2) - temp_length);
last_box(3) = min(image_size.cx ,result_rect(1) + temp_length);
last_box(4) = min(image_size.cy ,result_rect(2) + temp_length);
warpimg = img(last_box(2) : last_box(4),...
    last_box(1) : last_box(3), :);
% last_box(1) =1;
% last_box(2) =1;
% last_box(3) = size(img,1);
% last_box(4) = size(img,2);
sp_feature_num=25;
sp_feature_dimention=768;
SLIC_sp_num=100;  %超像素的个数
SLIC_spatial_proximity_weight=10;
% [ klabels, sp_pixel_num, temp_sp_cl_hist ] = perform_slic( warpimg,SLIC_sp_num,SLIC_spatial_proximity_weight );
[ klabels] = perform_slic( warpimg,SLIC_sp_num,SLIC_spatial_proximity_weight );
sz= param.psize;
% [wimgs Y AffineParam] = affineSample(img,sz, param, AffineParam);
AffineParam = affineSample2(img,sz, param, AffineParam);
test_lable=ones(param.numsample,1);
candidate_feature=zeros(sp_feature_dimention*sp_feature_num,size(AffineParam.param,2));
for i=1:size(AffineParam.param,2)
    pos_affine=affparam2mat(AffineParam.param(:,i));
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
%     N_superpixels = unique(labels);
%     temp_hist=temp_sp_cl_hist(:,N_superpixels);
% ------修改于3.3
    img_x= lable_x+last_box(2);
    img_xmax=min(round(img_x+temp_pp(4)),image_size.cy);
    img_y= lable_y+last_box(1);
    img_ymax=min(round(img_y+temp_pp(3)),image_size.cx);
    tempwarpimg = img(img_x : img_xmax,...
        img_y : img_ymax, :);
    [temp_hist] = cal_each_s_rgb_hist(labels, tempwarpimg);
%     ---------修改于3.3
    hist_size=size(temp_hist,2);
%     disp(['candinate hist_size:' num2str(hist_size)]);
    pos_feature=zeros(sp_feature_dimention,sp_feature_num);
    if(hist_size<sp_feature_num)
        pos_feature(:,1:hist_size)=temp_hist;
    elseif(hist_size>sp_feature_num)
        pos_feature=temp_hist(:,1:sp_feature_num);
    else
        pos_feature=temp_hist;
    end
    pos_feature=reshape(pos_feature,sp_feature_dimention*sp_feature_num,1);
    candidate_feature(:,i)=pos_feature;
end
% ---------------------
% candidate_all=Y';
candidate_all=candidate_feature';
% use no feature
% Y=normVector(Y);
% use hog feature
candidate_all=normVector(candidate_all);
% predict the lables of candidates with libsvm with no feature
% [predict_label, accuracy, dec_values] = libsvmpredict(test_lable, Y', model);
% predict the lables of candidates with libsvm with hog feature
% 整体上利用SVM得到分值
[predict_label, accuracy, dec_values] = libsvmpredict(test_lable,candidate_all, model);
result_idx=find(dec_values==max(dec_values));
if(size(result_idx,1)>1)
    result_idx=result_idx(1,1);
    disp('result_idx is more than 1!');
end
% result_bb=wimgs(:,:,result_idx);
result_affine=affparam2mat(AffineParam.param(:,result_idx));
M = [result_affine(1) result_affine(3) result_affine(4); result_affine(2) result_affine(5) result_affine(6)];
w=sz(1);
h=sz(2);
corners = [ 1,-w/2,-h/2; 1,w/2,-h/2; 1,w/2,h/2; 1,-w/2,h/2; 1,-w/2,-h/2 ]';
corners = M * corners;
result_rect(1)=max(1,corners(1,1));
result_rect(2)=max(1,corners(2,1));
result_rect(3)=max(1,corners(1,2)-corners(1,1));
result_rect(4)=max(1,corners(2,3)-corners(2,2));
if(result_rect(3)<10||result_rect(4)<10)
    result_rect=param.init_rect;
end
end

