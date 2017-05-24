function [ sp_pixel_num, temp_sp_cl_hist ] = cal_superpiexl_rgb_hist( temp_frame, img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
temp_labels = temp_frame.labels;
t = tabulate(temp_labels(:));
sp_pixel_num = t(:,2);
img_1=img(:,:,1);
img_2=img(:,:,2);
img_3=img(:,:,3);
temp_sp_cl_hist=zeros(256*3,temp_frame.sp_num);
for k = 1:temp_frame.sp_num
    bars1=zeros(1,256);
    bars2=zeros(1,256);
    bars3=zeros(1,256);
    x1 =img_1(temp_labels == k);
    x2 =img_2(temp_labels == k);
    x3 =img_3(temp_labels == k);
    for value=0:255
        bars1(value+1)=sum(value==x1(:))/sp_pixel_num(k);
        bars2(value+1)=sum(value==x2(:))/sp_pixel_num(k);
        bars3(value+1)=sum(value==x3(:))/sp_pixel_num(k);
    end
    temp=[bars1 bars2 bars3]';
    temp_sp_cl_hist(:,k)=temp;
    
end
end

