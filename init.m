function [model train_sample param1]= init(img,param)
% function init(img,opt)
% Init the tracker
%   Input
%     -img   the image
%     -bb    target location obtained in first frame
%     -param  parameters for inition
%   Output
%
%   ������Ŀ����Χ���в��������������ռ䣬���������˲���ܽ���
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
% ��ȡȫ��ģ�͵�ѵ������
[A_poso A_nego] = affineTrainG(img, sz, param, param1, num_p, num_n, p0);   % obtain positive and negative templates for the holistic templates
A_pos = A_poso';
A_neg = A_nego';
% use no feature to train classifier
sample=[A_pos;A_neg];
% use hog feature to train classifier
% sample_feature=featureExtractor(sample,'super_hist');
% train_sample=sample_feature; % or train_sample=sample;
train_sample=sample;
train_sample = normVector(train_sample);
% ����������������ȡ
% ѡ��libsvm��Ϊ��������ѵ��������
% test=A_pos(1,:);
% test_result=reshape(test,32,32);
% imshow(test_result);
lable_p=ones(num_p,1);
lable_n=-1*ones(num_n,1);
train_lable=[lable_p;lable_n];
model=libsvmtrain(train_lable,train_sample,'-c 1 -g 0.07');%'-c 1 -g 0.07'
% [predict_label, accuracy, dec_values] = libsvmpredict(train_lable, train_sample, model);
end

