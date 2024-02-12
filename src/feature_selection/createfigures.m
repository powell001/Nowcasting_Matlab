clc; clear;

load data\mergedDataforAnalysis.mat

ts = table2timetable(mergedDataforAnalysis);

% Use these after collinearity tests
% Which one do you remove?
% Only looking at linear relationships
% Use common sense, look what others are using

usethese = {'AEX_close', 'Bankruptcies', 'BeloningSeizoengecorrigeerd_2', 'BusinessOutlook_Retail', 'CPI_1', 'EA'... 
    'EXP_advancedEconomies', 'EconomischKlimaat_2', 'ExpectedActivity_2', 'InterestRatesNLD', 'LeadIncG7', 'LeadIndG20'...
    'M1', 'M3_1', 'NetSavings', 'ProducerConfidence_1', 'Residential_NLD_Housing_Prices', 'exports_goods_services', 'gov_consumption', 'gdp_total'};
ts = ts(:, usethese);

%%%%%%%%%%%%%%%%%%%%
% Stepwise Linear Regression
%%%%%%%%%%%%%%%%%%%%

% function [names] = stepwiselm()
% 
%     % keep all variables regardless if have nan
%     tb1 = table2array(ts);
%     Xdata = tb1(:, [1:end-1]);
%     ydata = tb1(:, end);
%     stepwiselm(Xdata,ydata, 'Upper','Linear')
% 
%     % remove one variable with many nans
%     tb1 = table2array(ts);
%     Xdata = tb1(:, [1:3, 5:end-1]);
%     ydata = tb1(:, end);
%     stepwiselm(Xdata,ydata, 'Upper','Linear')
% 
%     % remove all variable with many nans
%     tb1 = table2array(ts);
%     Xdata = tb1(:, [1:3, 5:6, 8:9, 11:end-1]);
%     ydata = tb1(:, end);
%     stepwiselm(Xdata,ydata, 'Upper','Linear')
% 
%     % based on adjusted Rsquared, keep all features
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     % keep all variables regardless if have nan
%     tb1 = table2array(ts);
%     Xdata = tb1(:, [1:end-1]);
%     ydata = tb1(:, end);
%     stepwiselm(Xdata,ydata, 'Upper','Linear')
% 
%     % keep all variables regardless if have nan
%     tb1 = table2array(ts);
%     Xdata = tb1(:, [1:end-1]);
%     lagarray = [1,2]
%     Xdata = lagmatrix(Xdata, lagarray);
%     ydata = tb1(:, end);
%     stepwiselm(Xdata,ydata, 'Upper','Linear')
% 
%     % get names
%     tb1names = ts(:, [1:end-1]);
%     tb1names = lagmatrix(tb1names, lagarray);
%     names = tb1names.Properties.VariableNames;
%     names([9 12 16 19 28 31 32])
% 
% end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
% Lasso
%%%%%%%%%%%%%%%%%%%%

usethese = {'AEX_close', 'Bankruptcies', 'BeloningSeizoengecorrigeerd_2', 'BusinessOutlook_Retail', 'CPI_1', 'EA'... 
    'EXP_advancedEconomies', 'EconomischKlimaat_2', 'ExpectedActivity_2', 'InterestRatesNLD', 'LeadIncG7', 'LeadIndG20'...
    'M1', 'M3_1', 'NetSavings', 'ProducerConfidence_1', 'Residential_NLD_Housing_Prices', 'exports_goods_services', 'gov_consumption', 'gdp_total'};
ts = ts(:, usethese);

%%%%%%%
% Naive Lasso (lots of cross validation)
%%%%%%%

% lasso and cross validation

% Xdata = ts(:, 1:end-1) %ydata was added, so remove
% Xnames = Xdata.Properties.VariableNames;
% Xdata = table2array(Xdata);
% 
% ydata = ts(:, end);
% ydata = table2array(ydata);
% 
% [r,c] = size(Xdata);
% 
% [B,FitInfo] = lasso(Xdata,ydata,CV=45);
% 
% % how many values are signifcant?
% lassoPlot(B,FitInfo,PlotType="CV");
% legend("show");
% 
% % which rows have the most non-zero values
% collen = sum(B~=0,2);
% indexnzc = find(collen >= 70);
% 
% % print the series needed
% lasso_seriesnames1 = Xnames(indexnzc)

%%%%%%%
% Naive Lasso (lots of cross validation) with lags
%%%%%%%

% Xdata = ts(:, 1:end-1) %ydata was added, so remove
% Xnames = Xdata.Properties.VariableNames;
% Xdata = table2array(Xdata);
% 
% lagarray = [1,2]
% Xdata = lagmatrix(Xdata, lagarray);
% ydata = ts(:, end);
% ydata = table2array(ydata)
% 
% [r,c] = size(Xdata);
% 
% [B,FitInfo] = lasso(Xdata,ydata,CV=45);
% 
% % how many values are signifcant?
% lassoPlot(B,FitInfo,PlotType="CV");
% legend("show");
% 
% % which rows have the most non-zero values
% collen = sum(B~=0,2);
% indexnzc = find(collen >= 80);
% 
% % get names
% tb1names = ts(:, [1:end-1]);
% tb1names = lagmatrix(tb1names, lagarray);
% names = tb1names.Properties.VariableNames;
% names(indexnzc)


%%%%%%%
% Lasso with time series adjustment
%%%%%%%

% begindate = '1996-04-01';
% enddate = {'2015-04-01', '2020-04-01'};
% numel(enddate)
% 
% for k=1:numel(enddate)
% 
%     % select model based on training data
%     ed = enddate{k}
%     S = timerange(begindate, ed, 'closed')
% 
%     train_Xdata = ts(S, 1:end-1) 
%     Xnames = train_Xdata.Properties.VariableNames;
%     train_Xdata = table2array(train_Xdata);
% 
%     train_ydata = ts(S, end);
%     train_ydata = table2array(train_ydata)
% 
%     [B,FitInfo] = lasso(train_Xdata, train_ydata);
% 
%     % which rows have the most non-zero values
%     collen = sum(B~=0,2);
%     indexnzc = find(collen >= 80)
% 
%     % apply that model to test data, how does it do?
%     % make sure to use future data
%     test_date = timerange(ed, end, "openright");
%     test_Xdata = ts(test_date)
%     test_ydata
% 
%     fitlm
% 
% end

%%%%%%%%%%%%%%%%%%
% Rolling forecast
%%%%%%%%%%%%%%%%%%
% both start and end periods are incremented through time

% Do the important features stay the same through time?
% Should we expect them too?  Building a model requires
% that they should.

% start date for data
begindate = '1996-04-01';

% all data from start of train period
infmt = 'uuuu-MM-dd';
trainperiodstart = datetime("1996-04-01",'InputFormat',infmt);  
trainperiodend = datetime("2015-07-01",'InputFormat',infmt);  
dataEnd = datetime("2024-01-01",'InputFormat',infmt);  

% xydata is all of the data
allData = ts(ts.Date >= "1991-04-01" & ts.Date <= dataEnd, : );
allData = timetable2table(allData);

% index of first training period, this will be iterated
startoftrainperiod_index = find(allData.Date == trainperiodstart);

% index end training
endoftrainperiod_index = find(allData.Date == trainperiodend);

% index end data
dataEnd_index = find(allData.Date == dataEnd);

% over how many periods will we roll
rollingperiod = dataEnd_index - endoftrainperiod_index - 1;

% save it for later
indexvector = cell(10,1);
H = zeros(10,1);
xnames = cell(10,1);

for xyz = 1:1:rollingperiod

   if xyz <= 35
     disp(xyz)

    %%%%%%%%%%%%%%%%%
    % Build model based on rolling training period
    %%%%%%%%%%%%%%%%%
    rollingstart = startoftrainperiod_index + xyz - 1
    rollingsend = endoftrainperiod_index + xyz

    trainData = allData(rollingstart:rollingsend, :);

    % select X and y data from the training set
    train_ydata = trainData{:, end};
    % dont include date or gdp
    train_Xdata = trainData(:, 2:end-1);
    X_names = train_Xdata.Properties.VariableNames;

    % convert to array
    train_Xdata = table2array(train_Xdata);
    
    [B,FitInfo] = lasso(train_Xdata, train_ydata);

    % which rows have the most non-zero values
    collen = sum(B~=0,2);

    % dont want too many variables
    % start with numcol number of columns
    numcol = 30;
    
    for inx = 1:60
        indexnz = find(collen >= numcol + inx);
        indexlength = length(indexnz);
        if indexlength <= 4
            indexnzc = indexnz;
            break;
        end
    end

    % collect features across rolling periods
    indexvector{xyz} = indexnzc;

    % these are the best features according to the training data
    % subset X data and run regression
    train_X_subset = train_Xdata(:, indexnzc);
    mdl_train = fitlm(train_X_subset, train_ydata);

    % using index to select test data, run simple regression
    test_Xdata = allData(endoftrainperiod_index + xyz + 1:end, 2:end-1);
    test_ydata = allData(endoftrainperiod_index + xyz + 1:end, end);
    test_Xdata = test_Xdata(:, indexnzc);

    test_Xdata = table2array(test_Xdata(:,:));
    [test_size, test_columns] = size(test_Xdata);

    test_ydata = table2array(test_ydata);

    % MSE
    predGDP = predict(mdl_train, test_Xdata);
    
    H(xyz) = rmse(predGDP(1:end-1), test_ydata(1:end-1));
     
    % plot pred vs actual
    testgdp = test_ydata(1:end-1)
    pred = predGDP(1:end-1)

    plot(testgdp, 'black', 'LineStyle', '--')
    hold on
    plot(pred)

    % names of features needed below
    xnames{xyz} = X_names(indexnzc);

    % train_size should stay the same, test size will change
    [train_size, train_columns] = size(trainData);
    out = [train_size test_size];
    disp(out)

    % dont let the size of the test sample fall too much
    if test_size < 16
        disp('Not enough test data')
        break
    end        
   end
 end 
    
mean(nonzeros(H))
%plot(nonzeros(H))

disp(H)
features = cell2table(xnames);

% Write the table to a CSV file
writetable(features,'featuresfromrolling.csv')

