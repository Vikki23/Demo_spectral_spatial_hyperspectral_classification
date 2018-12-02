%% Demo_LBP: Hyperspectral segmentation for the AVIRIS Indian Pines 
%% scene by using loopy belief propagation algorithm
%%
clear all
close all
clc

addpath('./LORSAL-BP')

% load image
load data_Indian_pines
img = data; 
clear data
[no_lines,no_columns,no_bands] = size(img);   
img = ToVector(img);
img = img';
% load ground truth
load gt_Indian_16class
trainall = trainall';
n_class     = length(unique(trainall(2,:))); % number of class

% parameters
no_class = 25; % training samples per class
mu = 2; 
beta = 4;

%% randomly disctribute the ground truth image to training set and test set
indexes             = train_test_random_equal_number(trainall(2,:),no_class,no_class*n_class);
train_set   = trainall(:,indexes);
test_set            = trainall;
test_set(:,indexes) = [];  
train_samples       = img(:,train_set(1,:));
train_label         = train_set(2,:);
test_label          = test_set(2,:);

%% LORSAL
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

[~,classp] = max(p);

[OA_lorsal,kappa_lorsal,AA_lorsal,CA_lorsal]=...
    calcError( test_set(2,:)-1, classp(test_set(1,:))-1,[1:n_class] );
OA_lorsal

%% belief propagation
% compute the neighborhood from the grid, in this paper we use the first order neighborhood
[numN, nList] = getNeighFromGrid(no_lines,no_columns); 

v0 = exp(beta);
v1 = exp(0);
psi = v1*ones(n_class,n_class);
for i = 1:n_class
    psi(i,i) = v0;   
end

psi_temp = sum(psi);
psi_temp = repmat(psi_temp,n_class,1);
psi = psi./psi_temp;
p =p';

[belief] = BP_message(p,psi,nList,train_set);

[~,map_LBP] = max(belief);
indexb = double(map_LBP);
[OA_LBP, kappa_LBP, AA_LBP, CA_LBP]=...
    calcError(test_set(2,:)-1, map_LBP(test_set(1,:))-1,[1:n_class]);
OA_LBP