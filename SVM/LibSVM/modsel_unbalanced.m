function [bestc,bestg,bestcv,hC] = modsel_unbalanced(label,inst)
% Model selection for (lib)SVM by searching for the best param on a 2D grid
% example:
%
% load heart_scale.mat
% [bestc,bestg,bestcv,hC] = modsel(heart_scale_label,heart_scale_inst);
%

%contour plot
wa = @(e1,e2,s1,s2)(1-(e1*1/s1+e2*1/s2)/2)*100; %weighted accuracy
label(label==-1) = 2;
label(label==0) = 2;
fold = 10;

c_begin = -5; c_end = 10; c_step = 1;
g_begin = 8; g_end = -8; g_step = -1;
%c_begin = 0; c_end = 8; c_step = 1;
%g_begin = -4; g_end = -12; g_step = -1;
bestcv = 0;
bestc = 2^c_begin;
bestg = 2^g_begin;

% Preallocation of memory -> Just for speed
Z = zeros(length(c_begin:c_step:c_end),length(g_begin:g_step:g_end));

i = 1; j = 1;
indices = crossvalind('Kfold',label,fold);
for log2c = c_begin:c_step:c_end
    for log2g = g_begin:g_step:g_end
        cmd = ['-w1 5 -w2 1 -c ',num2str(2^log2c),' -g ',num2str(2^log2g)];               
        cp = classperf(label);
        for k = 1:fold
            test = (indices == k); train = ~test;
            mdl = svmtrain(label(train,:),inst(train,:),cmd);
            [class] = svmpredict(label(test,:),inst(test,:),mdl);
            classperf(cp,class,test);
        end        
        cv = wa(cp.errorDistributionByClass(1),cp.errorDistributionByClass(2),...
            cp.SampleDistributionByClass(1),cp.SampleDistributionByClass(2));       
        if (cv > bestcv) || ((cv == bestcv) && (2^log2c < bestc) && (2^log2g == bestg))
            bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
        end
        disp([num2str(log2c),' ',num2str(log2g),' (best c=',num2str(bestc),' g=',num2str(bestg),' rate=',num2str(bestcv),'%)'])
        Z(i,j) = cv;        
        j = j+1;
    end
    j = 1;
    i = i+1;
end
xlin = linspace(c_begin,c_end,size(Z,1));
ylin = linspace(g_begin,g_end,size(Z,2));
[X,Y] = meshgrid(xlin,ylin); 
acc_range = (ceil(bestcv)-3.5:.5:ceil(bestcv));
[C,hC] = contour(X,Y,Z',acc_range);    

%legend plot
set(get(get(hC,'Annotation'),'LegendInformation'),'IconDisplayStyle','Children')
ch = get(hC,'Children');
tmp = cell2mat(get(ch,'UserData'));
[M,N] = unique(tmp);
c = setxor(N,1:length(tmp));
for i = 1:length(N)
    set(ch(N(i)),'DisplayName',num2str(acc_range(i)))
end  
for i = 1:length(c) 
    set(get(get(ch(c(i)),'Annotation'),'LegendInformation'),'IconDisplayStyle','Off')
end
legend('show')  

%bullseye plot
hold on;
plot(log2(bestc),log2(bestg),'o','Color',[0 0.5 0],'LineWidth',2,'MarkerSize',15); 
axs = get(gca);
plot([axs.XLim(1) axs.XLim(2)],[log2(bestg) log2(bestg)],'Color',[0 0.5 0],'LineStyle',':')
plot([log2(bestc) log2(bestc)],[axs.YLim(1) axs.YLim(2)],'Color',[0 0.5 0],'LineStyle',':')
hold off;
title({['Best log2(C) = ',num2str(log2(bestc)),',  log2(gamma) = ',num2str(log2(bestg)),',  Accuracy = ',num2str(bestcv),'%'];...
    ['(C = ',num2str(bestc),',  gamma = ',num2str(bestg),')']})
xlabel('log2(C)')
ylabel('log2(gamma)')

