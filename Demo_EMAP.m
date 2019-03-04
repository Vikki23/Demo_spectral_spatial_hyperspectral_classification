%% Demo_EMAP: Hyperspectral classification for the AVIRIS Indian 
%% Pines scene on the EMAP features by using LORSAL only and with 
%% MRF for post-processing purposes, respectively.
%%
clear all
close all
clc

addpath(genpath('./EMAP'))
addpath('./LORSAL-BP')
addpath('./GraphCutMex')
addpath(genpath('./SVM'))

% load data
load MNF_20_Indian
% load traing set
load gt_Indian_16class
trainall = trainall';
n_class = length(unique(trainall(2,:))); % number of class

% parameters
no_class = 25; % training samples per class
mu = 2; % smoothness
classifier = 'LORSAL'; % 'SVM' or 'LORSAL';

%% compute the EMAP features
img = EMAP(data0,'dataIndianEMAP',false, false,'a', [200 500 1000], 's', [2.5:2.5:10]);
img = double(img);

% image size
[no_lines,no_columns,no_bands] = size(img);   % lines 
img = ToVector(img);
img = img';

%% randomly disctribute the ground truth image to training set and test set
indexes = train_test_random_equal_number(trainall(2,:),no_class,no_class*n_class);
train_set  = trainall(:,indexes);
test_set            = trainall;
test_set(:,indexes) = [];  
train_samples       = img(:,train_set(1,:));
train_label         = train_set(2,:);
test_label          = test_set(2,:);

%% classification with the spectral information only
if strcmp(classifier,'LORSAL')
    % classification with the LORSAL algorithm
    [d,n] =size(train_samples);
    nx = sum(train_samples.^2);
    [X,Y] = meshgrid(nx);
    dist=X+Y-2*train_samples'*train_samples;
    scale = mean(dist(:));
    sigma = 0.6;
    K=exp(-dist/2/scale/sigma^2);
    K = [ones(1,n); K];
    lambda = 0.00015;
    [w,L] = LORSAL(K,train_set(2,:),lambda,lambda,200);
    p = splitimage2(img,train_samples,w,scale,sigma);

    [~,cmap] = max(p);

    [OA, kappa, AA, CA] =... 
        calcError(test_set(2,:)-1, cmap(test_set(1,:))-1, 1:n_class);

elseif strcmp(classifier,'SVM')
    % classification with probabilistic SVM
    disp (['SVM: ... '])
    
    n_feat = size(img,1);
    training2D = zeros(no_lines, no_columns);
    training2D(train_set(1,:)) = train_set(2,:);

    in_param.probability_estimates = 1;
    in_param.cost = 125;
    in_param.gamma = 2^(-6);

    [map_class,outdata] = classify_svm(reshape(img',no_lines,no_columns,n_feat),training2D,in_param);

    % output probabilities
    [p,order,ordervalue] = ...
        aux_ordenar_v4(training2D,outdata.prob_estimates,no_lines, no_columns);
    p = p';

    [~,cmap] = max(p);

    [OA, kappa, AA, CA] =...
        calcError( test_set(2,:)-1, cmap(test_set(1,:))-1, 1: n_class);
else 
    disp('Error classifier type!')
    return;
end

%% post-processing with MRF
Dc = reshape((log(p+eps))',[no_lines, no_columns, n_class]);
Sc = ones(n_class) - eye(n_class);
gch = GraphCut('open', -Dc, mu*Sc);
[gch,map_MRF] = GraphCut('expand',gch);
gch = GraphCut('close', gch);
clear Dc

[OA_MRF,kappa_MRF,AA_MRF,CA_MRF] =...
    calcError( test_set(2,:)-1, map_MRF(test_set(1,:)), 1: n_class);

%% results
clc
disp (['Classification with ',classifier,':'])
OA
OA_MRF