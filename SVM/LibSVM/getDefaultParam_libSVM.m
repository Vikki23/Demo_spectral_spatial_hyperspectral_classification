function val = getDefaultParam_libSVM(param_struc, param)
%GETDEFAULTPARAM_LIBSVM Return a structure with the default values of an optional parameter of libsvm
%
%		val = getDefaultParam_libSVM(param_struc, param)
%
% INPUT
%   param_struc:    structure of the parameters
%   param:          string with the name of the parameter to check
%                       
% OUTPUT
%   val:            default value of 'param'
%                       
% DESCRIPTION
% This routine gives the value of a parameter. If it is defined in the
% structure, then its value is returned otherwise its default value set in
% GENERATELIBSVMCMD is returned.
% 
% SEE ALSO
% GENERATELIBSVMCMD, EPSSVM, MODSEL, CLASSIFY_SVM, GETPATTERNS

% $Id$

% Mauro Dalla Mura
% Remote Sensing Laboratory
% Dept. of Information Engineering and Computer Science
% University of Trento
% E-mail: dallamura@disi.unitn.it
% Web page: http://www.disi.unitn.it/rslab

param_struc = generateLibSVMcmd(param_struc);

val = getfield(param_struc, param);
