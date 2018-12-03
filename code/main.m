%function main
clc;
clear all;
close all;
vl_setup;
	
load('model.mat');% Read the trained model

[fn,pn,fi]=uigetfile('*.jpg','Select images');
I=imread([pn fn]);
figure(1);
title('original image');
imshow(I);

features=zeros(1,5*17*31);% Space for HOG feature
[m,n,~] = size(I);
% Transfer to Lab color space
data_lab = rgb2lab(I);
data_hsv = rgb2hsv(I);
a = data_lab(:,:,2);
b = data_lab(:,:,3);
label_white = zeros(m,n);
%lab binarize according to blue
color_markers_lab_blue = [18.1039; -39.6309];
distance_lab =  sqrt((a - color_markers_lab_blue(1)).^2 + (b - color_markers_lab_blue(2)).^2);
label_lab = zeros([m, n]);
label_lab((distance_lab <=27) & (distance_lab > 0)) = 1;% We get the area which might be the plate

% filter
se=strel('disk', 5); 
gi=imdilate(label_lab,se); 
gi_temp=bwareaopen(gi,800);
Iprops=regionprops(gi_temp,'BoundingBox','Image');

 for i = 1:m
    for j = 1: n
        if data_hsv(i,j,2) < 0.35 && data_hsv(i,j,3) > 0.35 
            label_white(i,j) = 255; % label white to 1
        end
    end
 end

for k = 1 : length(Iprops)
      boundingBox = Iprops(k).BoundingBox;
      subimg = imcrop(label_white,boundingBox);
      rectangle('Position', [boundingBox(1),boundingBox(2),boundingBox(3),boundingBox(4)], 'EdgeColor','r','LineWidth',2 )
end

final_boundingBox = [];
final_plant = [];
if(length(Iprops) > 0)
    pre_val = zeros([length(Iprops), 1]);
    for k=1:length(Iprops)
        boundingBox = Iprops(k).BoundingBox;
        plant = imcrop(I, boundingBox);
        %% If the block looks like this
            %   |-------|
            %   |       |
            %   |       |
            %   |       |
            %   |       |
            %   |       |
            %   |       |
            %   |-------|
            %               Reject!
        if(size(plant, 1) > size(plant, 2) || size(plant, 2)<50)
            pre_val(k) = -2.00;
            continue;
        end
        plant_color(:, :, 1) = imresize(plant(:, :, 1), [36, 136], 'nearest');
        plant_color(:, :, 2) = imresize(plant(:, :, 2), [36, 136], 'nearest');
        plant_color(:, :, 3) = imresize(plant(:, :, 3), [36, 136], 'nearest');

        plant = rgb2gray(plant);
        plant = imresize(plant, [36, 136], 'bilinear');
        imgs = im2single(plant);
        hog = vl_hog(imgs, 8 , 'verbose');
        features(1,:) = hog(:);
        [~,temp]=predict(model, features);
        pre_val(k)=temp(2);
    end

    [pre_thresh, index] = max(pre_val);

    final_boundingBox = Iprops(index).BoundingBox;

end

if(length(final_boundingBox) == 4)
    plant = imcrop(I, final_boundingBox);
    I_gray = rgb2gray(plant);
    I_gray=im2double(I_gray);
    MaxDN=max(max(I_gray));
    MinDN=min(min(I_gray));
    I_lashen=(I_gray-MinDN)/(MaxDN-MinDN);
    I_pinghua= medfilt2(I_lashen,[3,3]);

    I_edge=edge(I_pinghua,'roberts',0.08,'both');

    I1 = imclearborder(I_edge, 8);
    st=strel('rectangle',[3,35]);
    bg1 = imclose(I1, st);
    bg3 = imopen(bg1, st);
    bg2 = imopen(bg3, [1 1 1 1 1 1 1]');

    Iprops=regionprops(bg2,'BoundingBox','Image');
    if(length(Iprops) == 1)
        final_boundingBox = Iprops(1).BoundingBox;
        final_plant =  imcrop(plant, final_boundingBox);
    else
        pre_val = zeros([length(Iprops), 1]);
        for k=1:length(Iprops)
            boundingBox = Iprops(k).BoundingBox;
            tmp_plant = imcrop(plant, boundingBox);
            if(size(tmp_plant, 1) > size(tmp_plant, 2))
                pre_val(k) = -2.00;
                continue;
            end
            plant_color(:, :, 1) = imresize(tmp_plant(:, :, 1), [36, 136], 'nearest');
            plant_color(:, :, 2) = imresize(tmp_plant(:, :, 2), [36, 136], 'nearest');
            plant_color(:, :, 3) = imresize(tmp_plant(:, :, 3), [36, 136], 'nearest');

            tmp_plant = rgb2gray(tmp_plant);
            tmp_plant = imresize(tmp_plant, [36, 136], 'bilinear');
            imgs = im2single(tmp_plant); 
            hog = vl_hog(imgs, 8 , 'verbose');
            features(1,:) = hog(:);
            [~,temp]=predict(model, features);
            pre_val(k)=temp(2);
        end

        [pre_thresh, index] = max(pre_val);

        final_boundingBox = Iprops(index).BoundingBox;
        final_plant =  imcrop(plant, final_boundingBox);

     end
end
if(isempty(final_boundingBox))
    I_gray = rgb2gray(I);
    I_gray=im2double(I_gray);
    MaxDN=max(max(I_gray));
    MinDN=min(min(I_gray));
    I_lashen=(I_gray-MinDN)/(MaxDN-MinDN);
    I_pinghua= medfilt2(I_lashen,[3,3]);

    I_edge=edge(I_pinghua,'roberts',0.08,'both');
    I1 = imclearborder(I_edge, 8);
    st=strel('rectangle',[3,26]);
    bg1 = imclose(I1, st);
    bg3 = imopen(bg1, st);
    bg2 = imopen(bg3, [1 1 1 1 1 1 1]');

    Iprops=regionprops(bg2,'BoundingBox','Image');

if(length(Iprops) > 0)
    pre_val = zeros([length(Iprops), 1]);
    for k=1:length(Iprops)
        boundingBox = Iprops(k).BoundingBox;
        plant = imcrop(I, boundingBox);
        if(size(plant, 1) > size(plant, 2) || size(plant, 2)<50)
            pre_val(k) = -2.00;
            continue;
        end
        plant_color(:, :, 1) = imresize(plant(:, :, 1), [36, 136], 'nearest');
        plant_color(:, :, 2) = imresize(plant(:, :, 2), [36, 136], 'nearest');
        plant_color(:, :, 3) = imresize(plant(:, :, 3), [36, 136], 'nearest');

        plant = rgb2gray(plant);
        plant = imresize(plant, [36, 136], 'bilinear');
        imgs = im2single(plant);
        hog = vl_hog(imgs, 8 , 'verbose');
        features(1,:) = hog(:);
        [~,temp]=predict(model, features);
        pre_val(k)=temp(2);
    end

    [pre_thresh, index] = max(pre_val);

        final_boundingBox = Iprops(index).BoundingBox;
        final_plant =  imcrop(I, final_boundingBox);

end
end

Plate = final_plant;

figure, imshow(I); title('original');
bw=Plate;
figure,imshow(bw);title('License Plate');


bw=rgb2gray(bw);
I_gray=im2double(bw);
MaxDN=max(max(I_gray));
MinDN=min(min(I_gray));
I_stretch=(I_gray-MinDN)/(MaxDN-MinDN); % Gray stretch formula
bw = I_stretch;

%================Angle correction======================

angle=radonTransfer(bw) % Get the slant angle
if(abs(angle)<6)    % Correct the smale slant angle
    bw=imrotate(bw,angle,'bilinear');
end
figure,imshow(bw);title('Angle correction');
bw=im2bw(bw,graythresh(bw));    % Binarization
bw = bwareaopen(bw, 15, 8);
figure(10);imshow(bw);
bw=~bw;
% 0:black   1:white

%============= remove the border ===========

bw=projection(bw);

I_location = imresize(bw, [36, 136], 'bilinear');
histogram=sum(~I_location);
width = size(histogram, 2);
figure;plot(histogram);

%============= remove left and right sides==========
begin_bound = 0;
end_bound = 0;
for i=1:size(histogram, 2)
    if(histogram(i)==0)
        width = width-1;
    else
        begin_bound = i;
        break;
    end
end

for i=size(histogram, 2):-1:1
    if(histogram(i)==0)
        width = width-1;
    else
        end_bound = i;
        break;
    end
end

histogram = histogram(begin_bound:end_bound);
I_location = I_location(:, begin_bound:end_bound);
figure; imshow(~I_location); title('Located Plate');
[~, index] = SplitArray(histogram);
interval_array = zeros(length(index)/2-1, 1);
for i=1:length(index)/2-1
    pos1 = index(i*2);
    pos2 = index(2*i+1);
    interval_array(i) = pos2-pos1-1;
end

[~, second_third_span_index] = max(interval_array)

segment_index = zeros(14, 1);
segment_index(3) = index(2*second_third_span_index-1);
segment_index(4) = index(2*second_third_span_index);
segment_index(1) = 1;
segment_index(2) = index(2*second_third_span_index-2);
char_num = 5;
for i=1:char_num
    segment_index(4+i*2-1) = index(2*second_third_span_index+2*i-1);
    segment_index(4+i*2) = index(2*second_third_span_index+2*i);
end



first_char  =I_location( :,segment_index(1):segment_index(2));
first_char = splitspace(first_char);
second_char   =I_location( :,segment_index(3):segment_index(4));
second_char = splitspace(second_char);
third_char =I_location( :,segment_index(5):segment_index(6));
third_char = splitspace(third_char);
forth_char =I_location( :,segment_index(7):segment_index(8));  
forth_char = splitspace(forth_char);
fifth_char =I_location( :,segment_index(9):segment_index(10)); 
fifth_char = splitspace(fifth_char);
sixth_char =I_location( :,segment_index(11):segment_index(12)); 
sixth_char = splitspace(sixth_char);
seventh_char =I_location( :,segment_index(13):segment_index(14)); 
seventh_char = splitspace(seventh_char);


modified_first_char =   imresize(first_char, [32 16]);
modified_second_char  =   imresize(second_char,  [32 16]);
modified_third_char=  imresize(third_char,[32 16]);
modified_forth_char = imresize(forth_char,[32 16]);
modified_fifth_char = imresize(fifth_char,[32 16]);
modified_sixth_char = imresize(sixth_char,[32 16]);
modified_seventh_char = imresize(seventh_char,[32 16]);
figure;
subplot(171); imshow(modified_first_char); title('1');
subplot(172); imshow(modified_second_char); title('2');
subplot(173); imshow(modified_third_char); title('3');
subplot(174); imshow(modified_forth_char); title('4');
subplot(175); imshow(modified_fifth_char); title('5');
subplot(176); imshow(modified_sixth_char); title('6');
subplot(177); imshow(modified_seventh_char); title('7');

%=================================
% Recognize Chinese character
[chinesetemplate, filename] = readChineseTemplate('../templete/chinese/');
[m, n, l] = size(chinesetemplate);
compare_value = zeros(1, l);
for i=1:l
    tmp_template = chinesetemplate(:, :, i);
    %Calculate the distance between templete and data
    for j=1:m
        for k=1:n
            if  tmp_template(j,k)==modified_first_char(j,k);
             compare_value(i)=compare_value(i)+1;
            end
        end
    end
end
[value, index] = max(compare_value);
realchinesechar = ChineseRecognition(filename, index);

% Recognize the 2nd character
[lettertemplate, filename] = readLetterTemplate('../templete/letter/');
[m, n, l] = size(lettertemplate);
compare_value = zeros(1, l);
for i=1:l
    tmp_template = lettertemplate(:, :, i);

    for j=1:m
        for k=1:n
            if  tmp_template(j,k)==modified_second_char(j,k);
             compare_value(i)=compare_value(i)+1;
            end
        end
    end
end
[value, index] = max(compare_value);
realletterchar = LetterRecognition(filename, index);

% Recognize the 3rd character
[chartemplate, filename] = readCharTemplate('../templete/character/');
[m, n, l] = size(chartemplate);
compare_value = zeros(1, l);
for i=1:l
    tmp_template = chartemplate(:, :, i);
    for j=1:m
        for k=1:n
            if  tmp_template(j,k)==modified_third_char(j,k);
             compare_value(i)=compare_value(i)+1;
            end
        end
    end
end
[value, index] = max(compare_value);
realchar_1 = CharRecognition(filename, index);

% Recognize the 4th character
[chartemplate, filename] = readCharTemplate('../templete/character/');
[m, n, l] = size(chartemplate);
compare_value = zeros(1, l);
for i=1:l
    tmp_template = chartemplate(:, :, i);
    for j=1:m
        for k=1:n
            if  tmp_template(j,k)==modified_forth_char(j,k);
             compare_value(i)=compare_value(i)+1;
            end
        end
    end
end
[value, index] = max(compare_value);
realchar_2 = CharRecognition(filename, index);

% Recognize the 5th character
[chartemplate, filename] = readCharTemplate('../templete/character/');
[m, n, l] = size(chartemplate);
compare_value = zeros(1, l);
for i=1:l
    tmp_template = chartemplate(:, :, i);
    for j=1:m
        for k=1:n
            if  tmp_template(j,k)==modified_fifth_char(j,k);
             compare_value(i)=compare_value(i)+1;
            end
        end
    end
end
[value, index] = max(compare_value);
realchar_3 = CharRecognition(filename, index);

% Recognize the 6th character
[chartemplate, filename] = readCharTemplate('../templete/character/');
[m, n, l] = size(chartemplate);
compare_value = zeros(1, l);
for i=1:l
    tmp_template = chartemplate(:, :, i);
    for j=1:m
        for k=1:n
            if  tmp_template(j,k)==modified_sixth_char(j,k);
             compare_value(i)=compare_value(i)+1;
            end
        end
    end
end
[value, index] = max(compare_value);
realchar_4 = CharRecognition(filename, index);

% Recognize the 7th character
[chartemplate, filename] = readCharTemplate('../templete/character/');
[m, n, l] = size(chartemplate);
compare_value = zeros(1, l);
for i=1:l
    tmp_template = chartemplate(:, :, i);
    for j=1:m
        for k=1:n
            if  tmp_template(j,k)==modified_seventh_char(j,k);
             compare_value(i)=compare_value(i)+1;
            end
        end
    end
end
[value, index] = max(compare_value);
realchar_5 = CharRecognition(filename, index);

result = [realchinesechar realletterchar realchar_1 realchar_2 realchar_3 realchar_4 realchar_5];
%=======================================================================
msgbox(result,'result');
