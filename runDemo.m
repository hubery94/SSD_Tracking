function runDemo(seq,times)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% config some parameters
pathAnno = './Datasets/';
imgSavePath=['./resultImage/' seq.name '/'];
if ~exist(imgSavePath,'dir')
    mkdir(imgSavePath);
end
config;
results=cell(1,times);
for time=1:times
    rect_anno = dlmread([pathAnno seq.name '/groundtruth_rect.txt']);
    param.init_rect=rect_anno(1,:);
    image_no = seq.startFrame;
    nz	= strcat('%0',num2str(seq.nz),'d'); %number of zeros in the name of image
    id = sprintf(nz,image_no);
    seq.s_frames{1} = strcat(seq.path,id,'.',seq.ext);
    img = imread(seq.s_frames{1});
    % 将图像转为灰度图
    %     if size(img_color,3)==3
    %         %     img	= double(rgb2gray(img_color));  %这两种方式有什么区别啊
    %         img	= im2double(rgb2gray(img_color));
    %     else
    %         %     img	= double(img_color);
    %         img	= im2double(img_color);
    %     end
    imshow(img);
    if size(img, 3) == 1
        newf = zeros(size(img,1), size(img,2), 3);
        newf(:,:,1) = img;
        newf(:,:,2) = img;
        newf(:,:,3) = img;
        img = uint8(newf);
    end
    %    init2仅为测试代码,输入为3通道图片
    [model train_sample AffineParam]=init2(img,param);
    %     [model train_sample AffineParam]=init(img,param);
    seq_length=seq.len;
    result.type='4corner';
    result.res=zeros(2,5,seq_length);
    result.center=zeros(2,seq_length);
    result.anno=rect_anno;
    result.len=seq.len;
    result.tmplsize=param.psize;
    result.startFrame=seq.startFrame;
    result.annoBegin=seq.startFrame;
    result_rect=rect_anno(1,:);
    for f = 1:seq_length
        
        %     img_color = imread([dataPath int2str(f) forMat]);
        image_no = seq.startFrame + (f-1);
        id = sprintf(nz,image_no);
        seq.s_frames{f} = strcat(seq.path,id,'.',seq.ext);
        img = imread(seq.s_frames{f});
        %         if size(img_color,3)==3
        %             img	= im2double(rgb2gray(img_color));
        %         else
        %             img	= im2double(img_color);
        %         end
        %     hold on;
        if size(img, 3) == 1
            newf = zeros(size(img,1), size(img,2), 3);
            newf(:,:,1) = img;
            newf(:,:,2) = img;
            newf(:,:,3) = img;
            img = uint8(newf);
        end
        imshow(img);
        disp(['Seq:' seq.name ' ---FrameNo:' num2str(f)]);
        text(10,10,['#' int2str(f)], 'Color', 'g','fontsize',20)
        [AffineParam result_idx result_rect] = processFrame(img,param,AffineParam,model,result_rect);
        AffineParam.est=affparam2mat(AffineParam.param(:,result_idx));
        color = [ 1 0 0 ];
        [ r_center r_corners ] = drawbox([32 32],AffineParam.est , 'Color', color, 'LineWidth', 2.5);
        result.res(:,:,f)=r_corners;
        result.center(:,f)=r_center;
        axis off;
        drawnow;
        imwrite(frame2im(getframe), [imgSavePath  num2str(f) '.png']);
    end
    results{time}=result;
    % resultMat=['./results/' s.name '_HWJ'];
    % save(resultMat,'results');
end
resultMat=['./results/' seq.name '_HWJ'];
save(resultMat,'results');
end

