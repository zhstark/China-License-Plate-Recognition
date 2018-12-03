%--coding: utf-8--%
%step2 train svm model
clc;
clear;
vl_setup;

load('hogTrainData.mat');

mdl=fitcsvm(hogBox, label','KernelFunction', 'rbf', 'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus','ShowPlots',false));
%the best hyper parameters
C=mdl.ModelParameters.BoxConstraint;
sigma=mdl.ModelParameters.KernelScale;

model=fitcsvm(hogBox, label', 'KernelFunction', 'gaussian', 'KernelScale', sigma, 'BoxConstraint',C);

save('model.mat','model');
