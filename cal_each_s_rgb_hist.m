function [temp_sp_cl_hist ] = cal_each_s_rgb_hist( labels, img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(size(labels,1)~=size(img,1)||size(labels,2)~=size(img,2))
    cut_x=min(size(labels,1),size(img,1));
    cut_y=min(size(labels,2),size(img,2));
    labels=labels(1:cut_x,1:cut_y);
    img=img(1:cut_x,1:cut_y,:);
%     disp('label img size problem');
%     disp([size(labels) size(img)]);
end
% t = tabulate(labels(:));
N_superpixels = unique(labels);
temp_frame.sp_num=size(N_superpixels,1);
% sp_pixel_num =zeros(temp_frame.sp_num,1);
img_1=img(:,:,1);
img_2=img(:,:,2);
img_3=img(:,:,3);
temp_sp_cl_hist=zeros(256*3,temp_frame.sp_num);
if(size(labels,1)==0||size(labels,2)==0)
    disp('labels null');
    return;
end
bars1=zeros(1,256);
bars2=zeros(1,256);
bars3=zeros(1,256);
if(temp_frame.sp_num==0)
    return;
end
for i = 1:temp_frame.sp_num
    k=N_superpixels(i,:);
    x1 =img_1(labels == k);
    x2 =img_2(labels == k);
    x3 =img_3(labels == k);
    %     bars1=hist(x1);
    %     bars2=hist(x2);
    %     bars3=hist(x3);
        sp_pixel_num=size(x1,1);
    for j=1:sp_pixel_num
        pixel1=x1(j);
        pixel2=x2(j);
        pixel3=x3(j);
        bars1(pixel1+1)=sum(pixel1==x1(:))/sp_pixel_num;
        bars2(pixel2+1)=sum(pixel2==x2(:))/sp_pixel_num;
        bars3(pixel3+1)=sum(pixel3==x3(:))/sp_pixel_num;
    end
    temp=[bars1 bars2 bars3]';
    temp_sp_cl_hist(:,i)=temp;
    
end
end

