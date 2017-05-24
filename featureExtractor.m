function [ feature ] = featureExtractor(sample,featureType)
% This function extracts the specific feature of a sample matrix
% Input
%   -sample  sample matrix
%   -featureType feature type need to extract
% Output
%   -feature  result feature matrix
% featureType='super_hist';
% sample = imread('Lena.jpg');
switch lower(featureType)
    case {'hog'}
        sampleNumber=size(sample,1);
        feature=zeros(sampleNumber,324);
        for i=1: sampleNumber
            s=sample(i,:);
            s=reshape(s,32,32);
            [hog1, visualization] = extractHOGFeatures(s,'CellSize',[8 8]);
            feature(i,:)=hog1;
        end
        disp('feature extraction complete');
    case {'super_hist'}  %还有一些问题需要修改
        sampleNumber=size(sample,1);
        SLIC_sp_num=100;  %超像素的个数
        SLIC_spatial_proximity_weight=10;
        feature=zeros(sampleNumber,512*20);
        for i=1: sampleNumber
            s=sample(i,:);
            s=reshape(s,32,32);
            newf = zeros(size(s,1), size(s,2), 3);
            newf(:,:,1) = s;
            newf(:,:,2) = s;
            newf(:,:,3) = s;
            newf=uint8(newf);
            [ klabels, sp_pixel_num, temp_sp_cl_hist ] = perform_slic( newf,SLIC_sp_num,SLIC_spatial_proximity_weight );
            [m n]=size(temp_sp_cl_hist);
            %             feature=zeros(sampleNumber,m*n);
            temp_sp_cl_hist=reshape(temp_sp_cl_hist,m*n,1);
            temp_sp_cl_hist=temp_sp_cl_hist(1:512*20);
            feature(i,:)=temp_sp_cl_hist;
        end
        disp('feature extraction complete');
    otherwise
        disp('please select a feature type');
        
end

