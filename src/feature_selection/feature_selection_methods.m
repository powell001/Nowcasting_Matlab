% feature selection

clc; clear;

%%%%%%%%%%%%%%%%%%%%
% Stepwise
%%%%%%%%%%%%%%%%%%%%

load 'mergedDataforAnalysis.mat'
data_orig = mergedDataforAnalysis(:,:)
Xdata = mergedDataforAnalysis(:, [3:24, 30:32, 34:end])
Xdata_orig = mergedDataforAnalysis(:, [3:24, 30:32, 34:end])
ydata = mergedDataforAnalysis{:, [2]}

Alldatalag =  lagmatrix(Xdata,[1])
Alldatalag.gdp_total = ydata

stepwiselm(Alldatalag,'Upper','Linear')

%%%%%%%%%%%%%%%%%%%%
% Lasso
%%%%%%%%%%%%%%%%%%%%

% lasso and cross validation

Xdata = Alldatalag(:, 1:end-1) %ydata was added, so remove
Xnames = Xdata.Properties.VariableNames
Xdata = table2array(Xdata)

[r,c] = size(Xdata)

[B,FitInfo] = lasso(Xdata,ydata,CV=100);

% how many values are signifcant?
lassoPlot(B,FitInfo,PlotType="CV");
legend("show");

% which rows have the most non-zero values
collen = sum(B~=0,2);
indexnzc = find(collen >= 90);

% print the series needed
lasso_seriesnames1 = Xnames(indexnzc)


%%%%%%%%%%%%%%%%%%%%%%%
% Run BVAR
%%%%%%%%%%%%%%%%%%%%%%%
numlags = 2

% remove missing values, careful that you don't remove most recent data
data_no_missing = rmmissing(Xdata);

lasso_seriesnames = ["AEX_close", "Residential_NLD_Housing_Prices", "ProducerConfidence_1", "Bankruptcies", "ExpectedActivity_2"];
% add gdp_total back in and count number of series
numseries = numel(lasso_seriesnames) + 1;
subseriesnames = ["gdp_total" lasso_seriesnames];
 
% run model
PriorMdl = bayesvarm(numseries,numlags,'SeriesNames', subseriesnames);
 
% forecast number of periods
numperiods = 1;
[YForecast,YStd] = forecast(PriorMdl,numperiods,data_orig{:,subseriesnames});

% make prediction
ydatarm = rmmissing(data_orig.gdp_total(:));
pred = cumsum([119388; ydatarm; YForecast(:,1)]);
pred(end-numperiods:end)
plot(pred);


