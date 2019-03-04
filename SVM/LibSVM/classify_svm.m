function [outdata, out_param] = classify_svm(varargin)
%CLASSIFYSVM Classify with libSVM an image
%
%		[outdata, out_param] = classify_svm(img, train, opt)
%
% INPUT
%   img    Multispectral image to be classified.
%   train  Training set image (zero is unclassified and will not be
%           considered).
%   opt    input parameters. Structure with each field correspondent to a
%           libsvm parameter
%           Below the availabel fields. The letters in the brackets corresponds to the flags used in libsvm:
%             "svm_type":	(-s) set type of SVM (default 0)
%                   0 -- C-SVC
%                   1 -- nu-SVC
%     	            2 -- one-class SVM
%     	            3 -- epsilon-SVR
%     	            4 -- nu-SVR
%             "kernel_type": (-t) set type of kernel function (default 2)
%                   0 -- linear: u'*v
%                   1 -- polynomial: (gamma*u'*v + coef0)^degree
%                   2 -- radial basis function: exp(-gamma*|u-v|^2)
%                   3 -- sigmoid: tanh(gamma*u'*v + coef0)
%                   4 -- precomputed kernel (kernel values in training_instance_matrix)
%             "kernel_degree": (-d) set degree in kernel function (default 3)
%             "gamma": set gamma in kernel function (default 1/k, k=number of features)
%             "coef0": (-r) set coef0 in kernel function (default 0)
%             "cost": (-c) set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
%             "nu": (-n) parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
%             "epsilon_regr": (-p) set the epsilon in loss function of epsilon-SVR (default 0.1)
%             "chache": (-m) set cache memory size in MB (default 100)
%             "epsilon": (-e) set tolerance of termination criterion (default 0.001)
%             "shrinking": (-h) whether to use the shrinking heuristics, 0 or 1 (default 1)
%             "probability_estimates": (-b) whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
%             "weight": (-wi) set the parameter C of class i to weight*C, for C-SVC (default 1)
%             "nfold": (-v) n-fold cross validation mode
%             "quite": (-q) quiet mode (no outputs)
%           For setting other default values, modify generateLibSVMcmd.
%
% OUTPUT
%   outdata    Classified image
%   out_param  structure reports the values of the parameters
%
% DESCRIPTION
% This routine classify an image according to the training set provided
% with libsvm. By default, the data are scaled and normalized to have unit
% variance and zero mean for each band of the image. If the parameters
% defining the model of the svm (e.g., the cost C and gamma) are not
% provided, the function call the routin MODSEL and which optimizes the
% parameters. Once the model is trained the image is classified and is
% returned as output.
%
% SEE ALSO
% EPSSVM, MODSEL, GETDEFAULTPARAM_LIBSVM, GENERATELIBSVMCMD, GETPATTERNS

% Mauro Dalla Mura
% Remote Sensing Laboratory
% Dept. of Information Engineering and Computer Science
% University of Trento
% E-mail: dallamura@disi.unitn.it
% Web page: http://www.disi.unitn.it/rslab

% Parse inputs
if nargin == 2
    data_set = varargin{1};
    train = varargin{2};
    in_param = struct;
%    in_param.kernel_type = 2;   % default RBF
elseif nargin == 3
    data_set = varargin{1};
    train = varargin{2};
    in_param = varargin{3};
end

% Default Parameters - Scaling the data
scaling_range = true;       % Scale each feature of the data in the range [-1,1]
scaling_std = true;         % Scale each feature of the data in order to have std=1

% Read in_param
if (isfield(in_param, 'scaling_range'))
    scaling_range = in_param.scaling_range;       % scaling_range
else
    in_param.scaling_range = scaling_range;
end
if (isfield(in_param, 'scaling_std'))
    scaling_std = in_param.scaling_std;           % scaling_range
else
    in_param.scaling_std = scaling_std;
end
% ------------------------

[nrows ncols nfeats] = size(data_set);
Ximg = double(reshape(data_set, nrows*ncols, nfeats));

% Transform training set in a format compliant to RF
[X, L] = getPatterns(data_set, train);
nclasses = length(unique(L));

[X,row_factor] = removeconstantrows(X);   % Remove redundant features
Ximg = Ximg(:,row_factor.keep); % Remove redundant features

% ========= Preprocessing =========
% Scale each feature of the data in the range [-1,1]
if (scaling_range)
    [X,scale_factor] = mapminmax(X);   % Perform the scaling on the training set
    nfold = 10;
    nelem = round(size(Ximg,1)/nfold);
    for i=1:nfold-1                     % Apply the same scaling on the whole set
        Ximg((i-1)*nelem+1:i*nelem,:) = (mapminmax('apply',Ximg((i-1)*nelem+1:i*nelem,:)',scale_factor))';
    end
    Ximg((nfold-1)*nelem+1:end,:) = (mapminmax('apply',Ximg((nfold-1)*nelem+1:end,:)',scale_factor))';
end
% Scale each feature in order to have std=1
if (scaling_std)
    [X,scale_factor] = mapstd(X);  % Perform the scaling on the training set
    nfold = 5;
    nelem = round(size(Ximg,1)/nfold);
    for i=1:nfold-1                 % Apply the same scaling on the whole set
        Ximg((i-1)*nelem+1:i*nelem,:) = (mapstd('apply',Ximg((i-1)*nelem+1:i*nelem,:)',scale_factor))';
    end
    Ximg((nfold-1)*nelem+1:end,:) = (mapstd('apply',Ximg((nfold-1)*nelem+1:end,:)',scale_factor))';
end

tic
% Train the model
[model, out_param] = epsSVM(double(X)', double(L)', in_param);
out_param.time_tr = toc;
out_param.nfeats = length(row_factor.keep);

% Classify the whole data
%Ximg = double(reshape(data_set, nrows*ncols, nfeats));

% 
% nfold = 5;
% nelem = round(size(Ximg,1)/nfold);
% 
% for i=1:nfold-1
%     Ximg((i-1)*nelem+1:i*nelem,:) = (mapminmax('apply',Ximg((i-1)*nelem+1:i*nelem,:)',scale_factor))';
% end
% Ximg((nfold-1)*nelem+1:end,:) = (mapminmax('apply',Ximg((nfold-1)*nelem+1:end,:)',scale_factor))';

%Ximg = Ximg*scale_factor;
cmd = generateLibSVMcmd(out_param, 'predict');      % this is needed when the training is done with -b enabled (probabilities estimated)
if isempty(cmd)
    [predicted_labels, out_param.accuracy] = svmpredict(ones(nrows*ncols, 1), Ximg, model);
else
    [predicted_labels, out_param.accuracy, out_param.prob_estimates] = svmpredict(ones(nrows*ncols, 1), Ximg, model, cmd);
end

% reshape the array of labels to the original dimensions of the image
outdata = reshape(predicted_labels,nrows,ncols,1);
out_param.time_tot = toc;


