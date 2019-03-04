function [out_param] = modsel(label,inst, in_param)
%MODSEL Perform Model selection for LibSVM
%
%		[out_param] = modsel(label,inst, in_param)
%
% INPUT
%   label:      vector with the labels of the patterns
%   inst:       matrix of the patterns used for training the model
%   in_param:   structure containing the optional parameters. For
%               more information on the parameters please refer to generateLibSVMcmd.
%                       
% OUTPUT
%   out_param:  same structure as in_param, with added some information on
%               the model selection
%                       
% DESCRIPTION
% This routine perform the model selection of C (referred in the structure
% in_param as 'cost') and gamma (referred in the structure in_param as
% 'gamma'). The latter one is optimized if the kernel type (in the
% structure'kernel_type') is not linear. The optimization that is performed
% is just a grid search. The search can be composed by many iterations each
% with a finer step size. The parameters of the search can be modified at
% the beginning of the file. If c and gamma are defined in in_param, then
% no optimization is performed and the program simply return.
% In the output structure the values of the accuracy obtained in cross
% validation are stored.
% 
% SEE ALSO
% GENERATELIBSVMCMD, EPSSVM, GETDEFAULTPARAM_LIBSVM, CLASSIFY_SVM, GETPATTERNS

% $Id$

% Mauro Dalla Mura
% Remote Sensing Laboratory
% Dept. of Information Engineering and Computer Science
% University of Trento
% E-mail: dallamura@disi.unitn.it
% Web page: http://www.disi.unitn.it/rslab

% -------------------------------------------
% Set default parameters for the grid search
% Modify this for changing the parameters of the search
c_in = 0;                          % Initial value
c_deltal = [-4];  %-5+10 -0.5+0.5 -0.4+0.4 (-4 +4)  % Left range of search wrt to the inital value (c_deltal(1) is the left range for the first search, c_deltal(2) for the second and so on.
c_deltar = [16];     % Right range of search wrt to the inital value
c_step = [1];           % Steps used in the search % 1 0.5 0.1

kernel_type = getDefaultParam_libSVM(in_param, 'kernel_type');          % check the kernel type
if kernel_type  ~= 0    % Gamma is involved only if the kernel_type is not linear (kernel_type = 0)
    g_in = 0;                          % Initial value
    g_deltal = [-12]; %-8+8(-10 -2)     % Left range of search wrt to the inital value (c_deltal(1) is the left range for the first search, c_deltal(2) for the second and so on.
    g_deltar = [3];      % Right range of search wrt to the inital value
    g_step = [1];           % Steps used in the search
end
% -------------------------------------------

plot_on = false;

% Read in_param

c = [];
if (isfield(in_param, 'cost'))  % check value of C
    c = in_param.cost       % C
end

if kernel_type ~= 0             % check value of gamma
    g = [];
    if (isfield(in_param, 'gamma'))
        g = in_param.gamma;       % gamma
    end
end

out_param = in_param;

if (kernel_type == 0)
    if (~isempty(c))    % Nothing has to be optimized, return the original values
        out_param.isoptimized = false;
        display('asdasd')
        return;
    else
        c_trial = (c_in+c_deltal(1)):c_step(1):(c_in+c_deltar(1));
        for i=2:length(c_step)
            c_trial = [c_trial, (c_in+c_deltal(i)):c_step(i):(c_in+c_deltar(i))];   % get the list of c values that will be tested
        end
        out_param.modsel.cost = 2.^(c_trial);
    end

    out_param.modsel.cv = zeros(length(c_trial),1);
    out_param.modsel.cost = zeros(length(c_trial),1);
else % case non linear
    if (~isempty(c)) && (~isempty(g))    % Nothing has to be optimized, return the original values
        out_param.isoptimized = false;
        return;
    elseif (isempty(c)) && (~isempty(g))    % Optimize C
        c_trial = (c_in+c_deltal(1)):c_step(1):(c_in+c_deltar(1));
        for i=2:length(c_step)
            c_trial = [c_trial, (c_in+c_deltal(i)):c_step(i):(c_in+c_deltar(i))];   % get the list of c values that will be tested
        end
        g_trial = g;    % gamma value is given so fill the the list of values for gamma with it
        out_param.modsel.cost = 2.^(c_trial);
        out_param.modsel.gamma = 2.^(g_trial);
    elseif (~isempty(c)) && (isempty(g))    % Optimize gamma
        g_trial = (g_in+g_deltal(1)):g_step(1):(g_in+g_deltar(1));
        for i=2:length(g_step)
            g_trial = [g_trial, (g_in+g_deltal(i)):g_step(i):(g_in+g_deltar(i))];   % get the list of c values that will be tested
        end
        c_trial = c;    % gamma value is given so fill the the list of values for gamma with it
        out_param.modsel.cost = 2.^(c_trial);
        out_param.modsel.gamma = 2.^(g_trial);
    elseif (isempty(c)) && (isempty(g))    % Optimize gamma and C
        g_trial = (g_in+g_deltal(1)):g_step(1):(g_in+g_deltar(1));
        for i=2:length(g_step)
            g_trial = [g_trial, (g_in+g_deltal(i)):g_step(i):(g_in+g_deltar(i))];   % get the list of c values that will be tested
        end
        c_trial = (c_in+c_deltal(1)):c_step(1):(c_in+c_deltar(1));
        for i=2:length(c_step)
            c_trial = [c_trial, (c_in+c_deltal(i)):c_step(i):(c_in+c_deltar(i))];   % get the list of c values that will be tested
        end
        out_param.modsel.cost = repmat(2.^(c_trial), length(g_trial), 1)';
        out_param.modsel.gamma = repmat(2.^(g_trial), 1, length(c_trial))';
    end

    out_param.modsel.cv = zeros(length(c_trial),length(g_trial));
    out_param.modsel.cost = zeros(length(c_trial),length(g_trial));
    out_param.modsel.gamma = zeros(length(c_trial),length(g_trial));
end

out_param.best_cv = 0;
out_param.modsel.type = 'grid';
in_param.nfold = getDefaultParam_libSVM(in_param, 'nfold');     % nfold has to be set in order to perform the crossvalidation in svmtrain!

% Do the search
if (kernel_type == 0)
    for i=1:length(c_trial)

        in_param.cost = 2^c_trial(i);

        cmd = generateLibSVMcmd(in_param, 'train');
        cv = svmtrain_libsvm(label,inst,cmd);

        display(out_param.best_cv)
        if (cv > (out_param.best_cv)) || ((cv == out_param.best_cv) && (2^in_param.cost < out_param.cost))
            out_param.best_cv = cv; out_param.cost = in_param.cost;
        end
        disp(['log2C = ', num2str(c_trial(i)),', C = ',num2str(in_param.cost),' (best C = ',num2str(out_param.cost),' rate = ',num2str(out_param.best_cv),'%)'])

        out_param.modsel.cost(i) = in_param.cost;
        out_param.modsel.cv(i) = cv;
    end
else
    for i=1:length(c_trial)
        in_param.cost = 2^c_trial(i);
        
        
        if i==1%%%%%%%%%%%%%
            out_param.cost=in_param.cost;
        end

        for j=1:length(g_trial)

            in_param.gamma = 2^g_trial(j);
            
            if i==1%%%%%%%%%%%
            out_param.gamma=in_param.gamma;
           end

            cmd = generateLibSVMcmd(in_param, 'modsel');
            cv = svmtrain(label,inst,cmd);

            if (cv > (out_param.best_cv)) || ((cv == out_param.best_cv) && (2^(in_param.cost) < out_param.cost) && (2^(in_param.gamma) == out_param.gamma))
                out_param.best_cv = cv; out_param.cost = in_param.cost; out_param.gamma = in_param.gamma;
            end
           % disp(['log2C = ', num2str(c_trial(i)),'log2g = ', num2str(g_trial(j)),', C = ',num2str(in_param.cost),', g = ',num2str(in_param.gamma),' (best C = ',num2str(out_param.cost),', g = ',num2str(out_param.gamma),' rate = ',num2str(out_param.best_cv),'%)'])
            disp(['C = ',num2str(log2(in_param.cost)),',g = ',num2str(log2(in_param.gamma)),', rate = ',num2str(out_param.best_cv)])
            
            out_param.modsel.cost(i,j) = in_param.cost;
            out_param.modsel.gamma(i,j) = in_param.gamma;
            out_param.modsel.cv(i,j) = cv;
        end
    end
end


%disp(gamma)
%disp(cost)

%%% Parte aggiunta per ottimizzazione!!!!
c_trial= log2(out_param.cost)-0.3:0.2:log2(out_param.cost)+0.3;
g_trial= log2(out_param.gamma)-0.5:0.1:log2(out_param.gamma)+0.5;

% Do the refined search!!
if (kernel_type == 0)
    for i=1:length(c_trial)

        in_param.cost = 2^c_trial(i);

        cmd = generateLibSVMcmd(in_param, 'train');
        cv = svmtrain_libsvm(label,inst,cmd);

        display(out_param.best_cv)
        if (cv > (out_param.best_cv)) || ((cv == out_param.best_cv) && (2^in_param.cost < out_param.cost))
            out_param.best_cv = cv; out_param.cost = in_param.cost;
        end
        disp(['log2C = ', num2str(c_trial(i)),', C = ',num2str(in_param.cost),' (best C = ',num2str(out_param.cost),' rate = ',num2str(out_param.best_cv),'%)'])

        out_param.modsel.cost(i) = in_param.cost;
        out_param.modsel.cv(i) = cv;
    end
else
    for i=1:length(c_trial)
        in_param.cost = 2^c_trial(i);
        
        
        if i==1%%%%%%%%%%%%%
            out_param.cost=in_param.cost;
        end

        for j=1:length(g_trial)

            in_param.gamma = 2^g_trial(j);
            
            if i==1%%%%%%%%%%%
            out_param.gamma=in_param.gamma;
           end

            cmd = generateLibSVMcmd(in_param, 'modsel');
            cv = svmtrain(label,inst,cmd);

            if (cv > (out_param.best_cv)) || ((cv == out_param.best_cv) && (2^(in_param.cost) < out_param.cost) && (2^(in_param.gamma) == out_param.gamma))
                out_param.best_cv = cv; out_param.cost = in_param.cost; out_param.gamma = in_param.gamma;
            end
           % disp(['log2C = ', num2str(c_trial(i)),'log2g = ', num2str(g_trial(j)),', C = ',num2str(in_param.cost),', g = ',num2str(in_param.gamma),' (best C = ',num2str(out_param.cost),', g = ',num2str(out_param.gamma),' rate = ',num2str(out_param.best_cv),'%)'])
            disp(['C = ',num2str(log2(in_param.cost)),',g = ',num2str(log2(in_param.gamma)),', rate = ',num2str(out_param.best_cv)])
            
            out_param.modsel.cost(i,j) = in_param.cost;
            out_param.modsel.gamma(i,j) = in_param.gamma;
            out_param.modsel.cv(i,j) = cv;
        end
    end
end

% 
% 
% out_param.gamma = bestg;
% out_param.cost = bestc;
% out_param.bestcv = bestcv;
% 
% 
% if (plot_on)
%     xlin = linspace(c_begin(1),c_end(1),size(Z,1));
%     ylin = linspace(g_begin(1),g_end(1),size(Z,2));
%     [X,Y] = meshgrid(xlin,ylin);
%     Z = Z';
%     acc_range = (ceil(bestcv)-3.5:.5:ceil(bestcv));
%     figure;
%     [C,hC] = contour(X,Y,Z,acc_range);
% 
%     %     hold on
%     %     xlin = linspace(c_begin(1),c_end(1),size(Z,1));
%     %     ylin = linspace(g_begin(1),g_end(1),size(Z,2));
%     %     [X,Y] = meshgrid(xlin,ylin);
%     %     Z = Z';
%     %     acc_range = (ceil(bestcv)-3.5:.5:ceil(bestcv));
%     %     figure;
%     %     [C,hC] = contour(X,Y,Z,acc_range);
% 
%     %legend plot
%     set(get(get(hC,'Annotation'),'LegendInformation'),'IconDisplayStyle','Children')
%     ch = get(hC,'Children');
%     tmp = cell2mat(get(ch,'UserData'));
%     [M,N] = unique(tmp);
%     c = setxor(N,1:length(tmp));
%     for i = 1:length(N)
%         set(ch(N(i)),'DisplayName',num2str(acc_range(i)))
%     end
%     for i = 1:length(c)
%         set(get(get(ch(c(i)),'Annotation'),'LegendInformation'),'IconDisplayStyle','Off')
%     end
%     legend('show')
% 
%     %bullseye plot
%     hold on;
%     plot(log2(bestc),log2(bestg),'o','Color',[0 0.5 0],'LineWidth',2,'MarkerSize',15);
%     axs = get(gca);
%     plot([axs.XLim(1) axs.XLim(2)],[log2(bestg) log2(bestg)],'Color',[0 0.5 0],'LineStyle',':')
%     plot([log2(bestc) log2(bestc)],[axs.YLim(1) axs.YLim(2)],'Color',[0 0.5 0],'LineStyle',':')
%     hold off;
%     title({['Best log2(C) = ',num2str(log2(bestc)),',  log2(gamma) = ',num2str(log2(bestg)),',  Accuracy = ',num2str(bestcv),'%'];...
%         ['(C = ',num2str(bestc),',  gamma = ',num2str(bestg),')']})
%     xlabel('log2(C)')
%     ylabel('log2(gamma)')
% else
%     hC = 0;
% end
% 
