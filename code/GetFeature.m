%-- coding: utf-8 --%
% Read the training data(images), modify and extract hog feature
% save as mat file

clc;
clear;
close all;
vl_setup;

p=pwd;
posFilePath=[p,'/../data/1/'];
negFilePath=[p,'/../data/0/'];
posFo=dir([posFilePath,'/*.jpg']);
posLen=length(posFo);	% positive samples size
negFo=dir([negFilePath '/*.jpg']);
negLen=length(negFo);	% negative samples size
hogBox=zeros(posLen+negLen,5*17*31);	% space to save HOG feature
label=zeros(1,posLen+negLen);	% labels

%step1
%%% Process：
% 1、read file
% 2.change to gray
% 3.transfer to single precision
% 4.extract HOG feature
% 5.save HOG feature
for i=1:posLen	% deal with positive samples
	label(i)=1;
	name=posFo(i).name;
	image=imread([posFilePath,name]);	% read file
	grayImage=rgb2gray(image); % gray
	grayImage=single(grayImage);	% single precision
	hog=vl_hog(grayImage,8);	% extract HOG feature
	hogBox(i,:)=hog(:);
end

for j=1:negLen	% deal with negative samples
	name=negFo(j).name;
	image=imread([negFilePath,name]);
	grayImage=rgb2gray(image);
	grayImage=single(grayImage);
	hog=vl_hog(grayImage,8);

	hogBox(posLen+j,:)=hog(:);
end

fileName='hogTrainData.mat';
save(fileName,'hogBox','label');
%step1 end
