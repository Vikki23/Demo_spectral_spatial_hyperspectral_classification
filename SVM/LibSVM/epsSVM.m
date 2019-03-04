function [model, out_param] = epsSVM(instance_matrix, label_vector, in_param)
%EPSSVM Perform training of a svm
%
%		[model, out_param] = epsSVM(instance_matrix, label_vector, in_param)
%
% INPUT
%   instance_matrix:    matrix of the patterns used for training the model
%   label_vector:       vector with the labels of the patterns
%   in_param:           structure containing the optional parameters. For
%                       more information on the parameters please refer to generateLibSVMcmd.
%                       
% OUTPUT
%   model:              trained model
%   out_param:          same structure as in_param, with added some
%                       information
%                       
% DESCRIPTION
% This routine perform the training of a SVM on a training set. The values
% of the parameters not specified in in_param are the default ones defined
% in getDefaultParam_libSVM. If no value of the cost C (or gamma if the
% kernel type is non linear) then the value/s is optimized by modsel.
% The routine return the trained model and the structure with added
% information on the model selection.
%
% SEE ALSO
% GENERATELIBSVMCMD, MODSEL, GETDEFAULTPARAM_LIBSVM, CLASSIFY_SVM, GETPATTERNS

% $Id$

% Mauro Dalla Mura
% Remote Sensing Laboratory
% Dept. of Information Engineering and Computer Science
% University of Trento
% E-mail: dallamura@disi.unitn.it
% Web page: http://www.disi.unitn.it/rslab

% ------------------------
% % Default Parameters
gamma = [];         % default optimize it
cost = [];          % default optimize it

% check if c or g are defined, if so overwrite them
if (isfield(in_param, 'gamma'))
    gamma = in_param.gamma;       % epsilon SVM
end
if (isfield(in_param, 'cost'))
    cost = in_param.cost;       % epsilon SVM
end

% Pre-process data
instance_matrix2 = full(instance_matrix)';
%[instance_matrix2,row_factor] = removeconstantrows(instance_matrix2);   % Remove redundant features?
[instance_matrix2,col_factor,temp] = unique(instance_matrix2','rows');  % Remove redundant patterns?
label_vector2 = label_vector(col_factor);

% out_param.best_cv = [];
out_param = in_param;
out_param.isoptimized = false;

% switch out_param = in_param;

kernel_type = getDefaultParam_libSVM(in_param, 'kernel_type');


if ((kernel_type ~= 0) && isempty(gamma)) || isempty(cost)  % OPTIMIZE C, Gamma
    out_param.isoptimized = true;

    [out_param] = modsel(label_vector2,instance_matrix2, out_param);
    %[best_c,best_g,best_cv,hC] =
    %modsel_unbalanced(label_vector2,instance_matrix2');    % TODO not modified
    % yet
end

% --- solve the problem ---
% fprintf('Starting LIBSVM\n');
cmd = generateLibSVMcmd(out_param, 'train');
tic;
model = svmtrain(label_vector2, instance_matrix2, cmd);
% fprintf('Optimization finished in %3.2f sec\n',toc);


