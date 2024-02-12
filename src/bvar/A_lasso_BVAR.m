clc; clear;

% this data comes from NowCast_Data/output/MergedDataForAnalysis.csv
load mergedDataforAnalysis.mat;

% choose 2024-01-01 to get forecast for 2024-01-01
TR = timerange("1996-07-01", "2024-01-01");
DT = table2timetable(mergedDataforAnalysis);

% lags (will depend on number of features 
numlags = 2;

% if there is very little data, remove the column
data = DT(TR, [1:9,12:18,24:28,30:end]);

% remove missing values, careful that you don't remove most recent data
data_no_missing = rmmissing(data);

% remove gdp_total from data
series_names = data_no_missing(:, 2:end).Properties.VariableNames;

% normalize data or not
% X_data = normalize(data_no_missing(:, 2:end));
X_data = data_no_missing(:, 2:end);

% set-up X and y
X = table2array(X_data);
y = data_no_missing(:, 'gdp_total');
y = table2array(y);

% lasso and cross validation
[B,FitInfo] = lasso(X,y,CV=100);

% how many values are signifcant?
lassoPlot(B,FitInfo,PlotType="CV");
legend("show");

% which rows have the most non-zero values
collen = sum(B~=0,2);
indexnzc = find(collen >= 85);

% print the series needed
lasso_seriesnames = series_names(indexnzc);

% add gdp_total back in and count number of series
numseries = numel(lasso_seriesnames) + 1;
subseriesnames = ["gdp_total" lasso_seriesnames];
 
% run model
PriorMdl = bayesvarm(numseries,numlags,'SeriesNames',subseriesnames);
 
% forecast number of periods
numperiods = 1;
[YForecast,YStd] = forecast(PriorMdl,numperiods,data_no_missing{:,subseriesnames});

% make prediction
pred = cumsum([119388; data_no_missing.gdp_total(:); YForecast(:,1)]);
pred(end-numperiods:end)
plot(pred);

