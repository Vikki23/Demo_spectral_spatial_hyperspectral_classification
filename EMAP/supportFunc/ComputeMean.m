function Mea = ComputeMean(Input, Value)
%%Value = percent (%)
[row, col, ~] = size(Input);
Data = reshape(Input, row*col, 1);
Data(Data<0) = 0;
% Data(Data>1500) = 1500;
Mea = mean(Data)/100*Value;

fprintf('\n\t Min:  %f\n', min(Data));
fprintf('\n\t Max:  %f\n', max(Data));
fprintf('\n\t Mean:  %f\n', mean(Data));
fprintf('\n\t Standard Deviation:  %f\n', Mea);
end