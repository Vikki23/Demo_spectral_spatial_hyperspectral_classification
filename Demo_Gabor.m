%% Demo_Gabor: Hyperspectral classification for the AVIRIS Indian 
%% Pines scene on the Gabor features by using LORSAL only and with 
%% MRF for post-processing purposes, respectively.
%%
clear all
close all
clc

addpath('./Gabor')
addpath('./LORSAL-BP')
addpath('./GraphCutMex')
addpath(genpath('./SVM'))

% load data
load data_Indian_pines
% data(:,:,[104:108 150:163 220]) =[]; % remove noise bands
[no_lines,no_columns,~] = size(data);   % lines 
% load traing set
load gt_Indian_16class
trainall = trainall';
n_class = length(unique(trainall(2,:))); % number of class

% parameters
no_class = 25; % training samples per class
mu = 2; % smoothness
classifier = 'LORSAL'; % 'SVM' or 'LORSAL';

%% compute the discriminative Gabor features
ScaleXY = [3.8*ones(1,2)];
ScaleB = [0.8]';
FreqMagnitude = [1/2,1/4,1/8,1/16]'; % magnitude of frequency
TempAngle = [0, pi/4, pi/2, pi*3/4]'; % angles
IdxCom = 8;
img = fGet_3DGaborFeat(data, ScaleXY, ScaleB, FreqMagnitude, TempAngle, IdxCom);
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
    % PCA
    npc = 20;
    pcs = fPCA_2D_SpecificV1(img',npc,0,0);
    pcs = reshape(pcs,no_lines,no_columns,npc);

    % classification with probabilistic SVM
    disp (['SVM: ... '])

    training2D = zeros(no_lines, no_columns);
    training2D(train_set(1,:)) = train_set(2,:);

    in_param.probability_estimates = 1;
    in_param.cost = 125;
    in_param.gamma = 2^(-6);

    [map_class,outdata] = classify_svm(pcs,training2D,in_param);

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

%% display results
clc
disp (['Classification with ',classifier,':'])
OA
OA_MRF