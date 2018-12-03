vl_setup;
load('model.mat');

files_plant_number=dir('../test_data/test_1/*.jpg');
files_non_plant_number = dir('../test_data/test_0/*.jpg');
pos_number = length(files_plant_number);
neg_number = length(files_non_plant_number);
features=zeros(1,5*17*31);
% save labels, the 1st column is true label, the 2nd column is predicted
labels=zeros(pos_number+neg_number,2);

for i =1:pos_number
	labels(i,1)=1;
	Img=imread(['../test_data/test_1/' files_plant_number(i).name]);
	imgs=im2single(rgb2gray(Img));
	hog=vl_hog(imgs, 8, 'verbose');
	features(1,:)=hog(:);
	labels(i,2)=predict(model, features);
end

for i=1:neg_number
	labels(pos_number+i,1)=0;
	Img=imread(['../test_data/test_0/' files_non_plant_number(i).name]);
	imgs=im2single(rgb2gray(Img)); 
    hog=vl_hog(imgs, 8, 'verbose');
	features(1,:)=hog(:);
    labels(pos_number+i,2)=predict(model,features);
end

al=pos_number+neg_number;
right=length( find(labels(:,1)==1 & labels(:,2)==1) ) ;
right=right+length( find(labels(:,1)==0 & labels(:,2)==0) );
precision_rate=right/al