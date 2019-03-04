%% Pre-processing
HyperCube = HyperCube(YStart : YEnd, XStart : XEnd,:);
TruthMap = TruthMap(YStart : YEnd, XStart : XEnd);

%% label rearranging
TruthMap1D = TruthMap(:);
UniqueLabel = unique(TruthMap1D);
UniqueLabel = sort(UniqueLabel, 'ascend');
for i = 1: length(UniqueLabel)
    TruthMap1D( find(TruthMap1D==UniqueLabel(i)) ) = i-1;
end
TruthMap = reshape(TruthMap1D, size(TruthMap));
SelClassNo = [1:length(UniqueLabel)]; %

%% band and class eliminations
HyperCube(:,:,DelBand) = [];
SelClassNo(DelClass) = []; % eliminating background

%% get the total number of every used classes.
TruthMap1D = TruthMap(:);
UniqueLabels = unique(TruthMap1D);
ClassLabel = UniqueLabels(SelClassNo);
for i = 1:length(ClassLabel)
    LabelOneClass = find(TruthMap1D == ClassLabel(i));%%!!!%LabelOneClass为编号为i-1的位置
    TotalSamNumAClass(i,1) = length(LabelOneClass);
end

%%
%NumClassSam = ceil(TrainPercent*TotalSamNumAClass);