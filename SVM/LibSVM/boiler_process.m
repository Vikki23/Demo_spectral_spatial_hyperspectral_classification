% PROCESS FUNCTION BOILERPLATE CODE

% Copyright 2005-2007 The MathWorks, Inc.

% TODO - Add size checking for X and Y

if (nargin < 1), error('NNET:Arguments','Not enough arguments.'); end

if isstr(in1)
  switch lower(in1)
    case 'name',
      if nargin > 1, error('NNET:Arguments','Too many input arguments for ''name'' action'), end
      if (nargout > 1), error('NNET:Arguments','Too many output arguments for ''name'' action'), end
      out1 = name;
    case 'pdefaults'
      if nargin > 2, error('NNET:Arguments','Too many input arguments for ''pdefaults'' action'), end
      if nargin < 2, in2 = {}; end
      if (nargout > 1), error('NNET:Arguments','Too many output arguments for ''pdefaults'' action'), end
      out1 = param_defaults(in2);
    case 'pnames'
      if nargin > 1, error('NNET:Arguments','Too many input arguments for ''pnames'' action'), end
      if (nargout > 1), error('NNET:Arguments','Too many output arguments for ''pnames'' action'), end
      out1 = param_names;
    case 'pcheck'
      if (nargin < 2), error('NNET:Arguments','Not enough input arguments for ''pcheck'' action'), end
      if nargin > 2, error('NNET:Arguments','Too many input arguments for ''pcheck'' action'), end
      if (nargout > 1), error('NNET:Arguments','Too many output arguments for ''pcheck'' action'), end
      if ~isa(in2,'struct'), error('NNET:Arguments','Parameters are not a struct.'); end
      names1 = fieldnames(param_defaults({}));
      names2 = fieldnames(in2);
      if length(names1) ~= length(names2), error('NNET:Arguments','Incorrect number of parameters.'); end
      names1 = sort(names1);
      names2 = sort(names2);
      for i=1:length(names1)
        if ~strcmp(names1{i},names2{i}), error('NNET:Arguments',['Parameter field name is not correct:' names2{i}]); end
      end
      out1 = param_check(in2);
      if (nargout == 0) && ~isempty(out1)
        error('NNET:Arguments',out1);
      end
    case 'apply'
      if (nargin < 3), error('NNET:Arguments','Not enough input arguments for ''apply'' action.'); end
      if (nargin > 3), error('NNET:Arguments','Too many input arguments for ''apply'' action'), end
      if (nargout > 1), error('NNET:Arguments','Too many output arguments for ''apply'' action'), end
      c = iscell(in2);
      if c
        if (size(in2,1) ~= 1)
          error('NNET:Arguments','Cell array X must have only one row')
        end
        cols = size(in2,2);
        colSizes = zeros(1,cols);
        for i=1:cols
          colSizes(i) = size(in2{1,i},2);
        end
        in2 = cell2mat(in2);
      elseif ~isa(in2,'double')
        error('NNET:Arguments','X must be a matrix or a row cell array')
      end
      out1 = apply_process(in2,in3);
      if c
        out1 = mat2cell(out1,size(out1,1),colSizes);
      end
    case 'reverse'
      if (nargin < 3), error('NNET:Arguments','Not enough input arguments for ''reverse'' action.'); end
      if (nargin > 3), error('NNET:Arguments','Too many input arguments for ''reverse'' action'), end
      if (nargout > 1), error('NNET:Arguments','Too many output arguments for ''reverse'' action'), end
      c = iscell(in2);
      if c
        if (size(in2,1) ~= 1)
          error('NNET:Arguments','Cell array X must have only one row')
        end
        cols = size(in2,2);
        colSizes = zeros(1,cols);
        for i=1:cols,colSizes(i) = size(in2{1,i},2); end
        in2 = cell2mat(in2);
      elseif ~(isnumeric(in2) || islogical(in2))
        error('NNET:Arguments','Y must be a matrix or a row cell array')
      end
      out1 = reverse_process(in2,in3);
      if c
        out1 = mat2cell(out1,size(out1,1),colSizes);
      end
      out2 = in3;
    case 'dx'
      if (nargin < 4), error('NNET:Arguments','Not enough input arguments for ''dx'' action.'); end
      if (nargout > 1), error('NNET:Arguments','Too many output arguments for ''dx'' action'), end
      if isempty(in3)
        in3 = apply_process(in2,in4);
      end
      out1 = derivative(in2,in3,in4);
    case 'dx_dy'
      if (nargin < 4), error('NNET:Arguments','Not enough input arguments for ''dx'' action.'); end
      if (nargout > 1), error('NNET:Arguments','Too many output arguments for ''dx'' action'), end
      if isempty(in3)
        in3 = apply_process(in2,in4);
      end
      out1 = reverse_derivative(in2,in3,in4);
    case 'simulink_params'
      out1 = simulink_params(in2);
    case 'simulink_reverse_params'
      out1 = simulink_reverse_params(in2);
    otherwise
      error('NNET:Arguments',['First argument is an unrecognized action string: ' in1]);
  end
  return
end

if (nargin < 2)
  in2 = param_defaults({});
elseif isa(in2,'struct')
  if (nargin > 2),error('NNET:Arguments','Too many input arguments when second argument is parameter structure FP'), end
else
  numFields = length(fieldnames(param_defaults({})));
  if (nargin > 1 + numFields), error('NNET:Arguments','Too many input argument'), end
  values = {in2};
  if (nargin > 2), values{2} = in3; end
  if (nargin > 3) values = [values varargin]; end
  in2 = param_defaults(values);
end
err = param_check(in2);
if ~isempty(err)
  error('NNET:Arguments',err)
end
c = iscell(in1);
if c
  if (size(in1,1) ~= 1)
    error('NNET:Arguments','Cell array X must have only one row')
  end
  cols = size(in1,2);
  colSizes = zeros(1,cols);
  for i=1:cols,colSizes(i) = size(in1{1,i},2); end
  in1 = cell2mat(in1);
elseif ~isa(in1,'double')
  error('NNET:Arguments','X must be a matrix or a row cell array')
end
[out1,out2] = new_process(in1,in2); y =[]; % MATLAB BUG if [out1,y] =...
if c
  out1 = mat2cell(out1,size(out1,1),colSizes);
end
