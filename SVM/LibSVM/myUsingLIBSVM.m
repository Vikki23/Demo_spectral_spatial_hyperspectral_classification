%% Cleanup
clc; clear all; close all;

%% Adding Paths LIBSVM Matlab
addpath 'D:\MAHDI\Code\libsvm-3.20';
addpath 'D:\MAHDI\Code\libsvm-3.20\matlab';
addpath 'D:\MAHDI\Code\libsvm-3.20\windows';

%% Example on Heart Scale Data
[heart_scale_label, heart_scale_inst] = libsvmread('D:\MAHDI\Code\libsvm-3.20\heart_scale');

% Train and Test Data Selection
N=150; % Number of training samples
M=size(heart_scale_label,1); % Total Number of samples
train_data = heart_scale_inst(1:N,:);
train_label = heart_scale_label(1:N,:);
test_data = heart_scale_inst(N+1:270,:);
test_label = heart_scale_label(N+1:270,:);

% Linear Kernel
model_linear = svmtrain(train_label, train_data, '-t 0');
model_precomputed = svmtrain(train_label, [(1:N)', train_data*train_data'], '-t 4');

% Applying SVM
[predict_label_L, accuracy_L, dec_values_L] = svmpredict(test_label, test_data, model_linear);
[predict_label_P, accuracy_P, dec_values_P] = svmpredict(test_label, [(1:M-N)', test_data*train_data'], model_precomputed);
