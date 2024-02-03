clc; clear;

load 'mergedDataforAnalysis.mat'
% data = mergedDataforAnalysis(:, [3:end,2])
% stepwiselm(data,'Upper','Linear')

X = mergedDataforAnalysis{:,3:end}
y = mergedDataforAnalysis{:,2}

lasso(X,y)
