function belief = BP_message(phi,psi,nList,trainold,BPiter,flg)
%
%
% BP_message: beliefs obtained from Belief Propagation 
%
% belief = BP_message(phi,psi,nList,Iter)
%
%
% -------------- Input parameters -----------------------------------------
% 
% phi     -  interaction potential, where phi(y_i, y_j) = p(y_i,y_j)
%
% psi     -  association potential of label y_i given evidence x_i,
%            where psi(y_i,x_i) = p(y_i|x_i)
%
% nList   -  the neigborhood lists
% trainold - indexes and labels of the training set
%
% flg     -  if flg = 1, assign the training samples with the given
%            samples. 
%            else, assign the training samples with the obtaiend beliefs
%            default flg = 0;
%
% BPiter  -  number of iterations
%
%
% --- output parameters ---------------------------------------------------
%
% beilef  -  beliefs obtained by the belief propagation algorithm%      
%  
% -------------------------------------------------------------------------
% 
% More details in
%
% [1] J. Li, J. Bioucas-Dias and A. Plaza. Spectral-Spatial Classification 
%  of Hyperspectral Data Using Loopy Belief Propagation and Active Learning. 
%  IEEE Transactions on Geoscience and Remote Sensing. 2012. Accepted
%
% [2] J. Li, J. Bioucas-Dias and A. Plaza. Hyperspectral Image Segmentation
%  Using a New Bayesian Approach with Active Learning. IEEE Transactions on
%  Geoscience and Remote Sensing.vol.49, no.10, pp.3947-3960, Oct. 2011.
%
% [3] J. S. Yedidia, W. T. Freeman, and Y. Weiss. Constructing free energy 
%  approximations and generalized belief propagation algorithms. 
%  IEEE Transactions on Information Theory, vol. 51, pp. 2282–2312, 2004.
%
%  Copyright: Jun Li (jun@lx.it.pt) 
%             José Bioucas-Dias (bioucas@lx.it.pt)
%             Antonio Plaza (aplaza@unex.es)
%             
%  For any comments contact the authors

sz = size(nList);  % sz(1) is the number of pixels in the whole image
sz_train = size(trainold);
K = size(psi,2);   % K is the number of classes

if nargin < 6
    flg = 1;
end

if nargin < 5
    BPiter = 10;
end

%%  intialize the msg
% msg  sz*m*K  n is the number of samples, m is the number of neighbors, K
% is the number of classes   
msg = zeros(sz(1),sz(2),K);   
for  i = 1:sz(1)     
    xList = nList(i,:);
    xList(xList == 0) = [];
    for j = 1:length(xList)
        msg0 = phi(i,:)*psi;
        msg0_temp = sum(msg0);
        msg0_temp = repmat(msg0_temp,1,K);
        msg0 = msg0./msg0_temp;        
        msg(i,j,:) = msg0;        
    end
end


%% assign the training set

if flg == 1
    psi2_beta = psi(1,1);
    for  i = 1:sz_train(2)
        psi2 = psi;
        for k = 1:K
            psi2(k,k) = psi(1,2);
        end
        psi2(trainold(2,i),trainold(2,i)) = psi2_beta;
        xList = nList(trainold(1,i),:);
        xList(xList == 0) = [];
        for j = 1:length(xList)
            msg0 = phi(trainold(1,i),:)*psi2;
            msg0_temp = sum(msg0);
            msg0_temp = repmat(msg0_temp,1,K);
            msg0 = msg0./msg0_temp;        
            msg(trainold(1,i),j,:) = msg0;        
        end
    end
end


%% update message

msg_temp0 = msg;

for iter = 1:BPiter
    for  i = 1:sz(1)     
        xList = nList(i,:);
        xList(xList == 0) = [];
        for j = 1:length(xList)
            yList = xList;
            yList(j) = [];        
            msg_temp = repmat(phi(i,:),K,1).*psi;
            msg_bp = [];
            for n_prod = 1:length(yList)
                yList2 = nList(yList(n_prod),:);
                yj_ind = yList2 == i;
                msg_bp = [msg_bp squeeze(msg_temp0(yList(n_prod),yj_ind,:))]; 
            end
            msg0 = msg_temp*prod(msg_bp,2);
            msg0 = msg0';
            msg0_temp = sum(msg0);
            msg0_temp = repmat(msg0_temp,1,K);
            msg0 = msg0./msg0_temp;        
            msg(i,j,:) = msg0;
        end
    end
    
    %% assign the training set
    if flg == 1
        for  i = 1:sz_train(2)     
            psi2 = psi;
            for k = 1:K
                psi2(k,k) = psi(1,2);
            end
            psi2(trainold(2,i),trainold(2,i)) = psi2_beta;
            xList = nList(trainold(1,i),:);
            xList(xList == 0) = [];
            for j = 1:length(xList)
                yList = xList;
                yList(j) = [];                 
                msg_temp = repmat(phi(trainold(1,i),:),K,1).*psi2;                
                msg_bp = [];
                for n_prod = 1:length(yList)
                    yList2 = nList(yList(n_prod),:);
                    yj_ind = yList2 == trainold(1,i);
                    msg_bp = [msg_bp squeeze(msg_temp0(yList(n_prod),yj_ind,:))];                
                end
                msg0 = msg_temp*prod(msg_bp,2);
                msg0 = msg0';
                msg0_temp = sum(msg0);
                msg0_temp = repmat(msg0_temp,1,K);
                msg0 = msg0./msg0_temp;        
                msg(trainold(1,i),j,:) = msg0;
            end
        end
    end    
    msg_temp0 = msg;
end

%%  compute Beliefs
belief = zeros(size(phi));
for  i = 1:sz(1)     
    xList = nList(i,:);
    xList(xList == 0) = [];
    yList = xList;
    msg_bp = [];
    for n_prod = 1:length(yList)
        yList2 = nList(yList(n_prod),:);
        yj_ind = yList2 == i;
        msg_bp = [msg_bp squeeze(msg_temp0(yList(n_prod),yj_ind,:))];                
    end
    belief(i,:) = phi(i,:).*prod(msg_bp,2)';
end

belief = belief';
belief_temp = sum(belief);
belief_temp = repmat(belief_temp,K,1);
belief = belief./belief_temp;

