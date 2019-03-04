function [out1,out2] = mapminmax(in1,in2,in3,in4)
%MAPMINMAX Map matrix row minimum and maximum values to [-1 1].
%  
%  Syntax
%
%   [y,ps] = mapminmax(x,ymin,ymax)
%   [y,ps] = mapminmax(x,fp)
%   y = mapminmax('apply',x,ps)
%   x = mapminmax('reverse',y,ps)
%   dx_dy = mapminmax('dx',x,y,ps)
%   dx_dy = mapminmax('dx',x,[],ps)
%   name = mapminmax('name');
%   fp = mapminmax('pdefaults');
%   names = mapminmax('pnames');
%   mapminmax('pcheck', fp);
%
%  Description
%  
%   MAPMINMAX processes matrices by normalizing the minimum and maximum values
%   of each row to [YMIN, YMAX].
%  
%   MAPMINMAX(X,YMIN,YMAX) takes X and optional parameters,
%     X - NxQ matrix or a 1xTS row cell array of NxQ matrices.
%     YMIN - Minimum value for each row of Y. (Default is -1)
%     YMAX - Maximum value for each row of Y. (Default is +1)
%   and returns,
%     Y - Each MxQ matrix (where M == N) (optional).
%     PS - Process settings, to allow consistent processing of values.
%
%   MAPMINMAX(X,FP) takes parameters as struct: FP.ymin, FP.ymax.
%   MAPMINMAX('apply',X,PS) returns Y, given X and settings PS.
%   MAPMINMAX('reverse',Y,PS) returns X, given Y and settings PS.
%   MAPMINMAX('dx',X,Y,PS) returns MxNxQ derivative of Y w/respect to X.
%   MAPMINMAX('dx',X,[],PS)  returns the derivative, less efficiently.
%   MAPMINMAX('name') returns the name of this process method.
%   MAPMINMAX('pdefaults') returns default process parameter structure.
%   MAPMINMAX('pdesc') returns the process parameter descriptions.
%   MAPMINMAX('pcheck',fp) throws an error if any parameter is illegal.
%    
%	Examples
%
%   Here is how to format a matrix so that the minimum and maximum
%   values of each row are mapped to default interval [-1,+1].
%	
%     x1 = [1 2 4; 1 1 1; 3 2 2; 0 0 0]
%     [y1,ps] = mapminmax(x1)
%
%   Next, we apply the same processing settings to new values.
%
%     x2 = [5 2 3; 1 1 1; 6 7 3; 0 0 0]
%     y2 = mapminmax('apply',x2,ps)
%
%   Here we reverse the processing of y1 to get x1 again.
%
%     x1_again = mapminmax('reverse',y1,ps)
%
%  Algorithm
%
%     It is assumed that X has only finite real values, and that
%     the elements of each row are not all equal.
%
%     y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
%
%  See also FIXUNKNOWNS, MAPSTD, PROCESSPCA, REMOVECONSTANTROWS

% Copyright 1992-2007 The MathWorks, Inc.
% $Revision: 1.1.6.10.4.1 $


% Process function boiler plate script
boiler_process

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Name
function n = name
n = 'Map Minimum and Maximum';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Defaults
function fp = param_defaults(values)

if length(values)>=1, fp.ymin = values{1}; else fp.ymin = -1; end
if length(values)>=2, fp.ymax = values{2}; else fp.ymax = fp.ymin + 2; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Names
function names = param_names()
names = {'Mininum value for each row of Y.', 'Maximum value for each row of Y.'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Check
function err = param_check(fp)

mn = fp.ymin;
mx = fp.ymax;
if ~isa(mn,'double') || any(size(mn)~=[1 1]) || ~isreal(mn) || ~isfinite(mn)
  err = 'ymin must be a real scalar value.';
elseif ~isa(mx,'double') || any(size(mx)~=[1 1]) || ~isreal(mx) || ~isfinite(mx) || (mx <= mn)
  err = 'ymax must be a real scalar value greater than ymin.';
else
  err = '';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Process
function [y,ps] = new_process(x,fp)

% Replace NaN with finite values in same row
rows = size(x,1);
for i=1:rows
  finiteInd = find(full(~isnan(x(i,:))),1);
  if isempty(finiteInd)
    xfinite = 0;
  else
    xfinite = x(finiteInd);
  end
  nanInd = isnan(x(i,:));
  x(i,nanInd) = xfinite;
end

ps.name = 'mapminmax';
ps.xrows = size(x,1);
ps.xmax = max(x,[],2);
ps.xmin = min(x,[],2);
ps.xrange = ps.xmax-ps.xmin;
ps.yrows = ps.xrows;
ps.ymax = fp.ymax;
ps.ymin = fp.ymin;
ps.yrange = ps.ymax-ps.ymin;

if any(ps.xmax == ps.xmin)
  warning('NNET:Processing','Use REMOVECONSTANTROWS to remove rows with constant values.');
end

y = apply_process(x,ps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apply Process
function y = apply_process(x,ps)

Q = size(x,2);
oneQ = ones(1,Q);
rangex = ps.xmax-ps.xmin;
rangex(rangex==0) = 1; % Avoid divisions by zero
rangey = ps.ymax-ps.ymin;
y = rangey * (x-ps.xmin(:,oneQ))./rangex(:,oneQ) + ps.ymin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reverse Process
function x = reverse_process(y,ps)

Q = size(y,2);
oneQ = ones(1,Q);
rangex = ps.xmax-ps.xmin;
rangey = ps.ymax-ps.ymin;
x = rangex(:,oneQ) .* (y-ps.ymin)*(1/rangey) + ps.xmin(:,oneQ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Derivative of Y w/respect to X
function dy_dx = derivative(x,y,ps);

Q = size(x,2);
rangex = ps.xmax-ps.xmin;
rangey = ps.ymax-ps.ymin;
d = diag(rangey ./ rangex);
dy_dx = d(:,:,ones(1,Q));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Derivative of Y w/respect to X
function dx_dy = reverse_derivative(x,y,ps);

Q = size(x,2);
rangex = ps.xmax-ps.xmin;
rangey = ps.ymax-ps.ymin;
d = diag(rangex ./ rangey);
dx_dy = d(:,:,ones(1,Q));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = simulink_params(ps)

p = ...
  { ...
  'xmin',mat2str(ps.xmin);
  'xmax',mat2str(ps.xmax);
  'ymin',mat2str(ps.ymin);
  'ymax',mat2str(ps.ymax);
  };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = simulink_reverse_params(ps)

p = ...
  { ...
  'xmin',mat2str(ps.xmin);
  'xmax',mat2str(ps.xmax);
  'ymin',mat2str(ps.ymin);
  'ymax',mat2str(ps.ymax);
  };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
