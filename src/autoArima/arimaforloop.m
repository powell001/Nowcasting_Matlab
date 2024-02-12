clc; clear;

%%%%
% run autoarima
%%%%
% 
% load("mergedDataforAnalysis.mat");
% Y = table2timetable(mergedDataforAnalysis)
% 
% plot(Y.gdp_total)
% % plot(diff(Y.gdp_total))
% 
% models_through_time = [];
% 
% for c = 1:20
%    [numobs ~] = size(Y.gdp_total(1:end-c)) 
%    bestmod = checkArima(Y.gdp_total(1:end-c, 1), 3, 2, numobs);
%    models_through_time = [models_through_time ; bestmod];
% end

%%%%%%%%%%%%
% forecast and plot
%%%%%%%%%%%%

% compare various arima models through time

horizon = 1;
load("mergedDataforAnalysis.mat");
Y = table2timetable(mergedDataforAnalysis);
diff_gdp = rmmissing(Y.gdp_total);

realY = cumsum([119388; diff_gdp(:)]);
[numobs, ~] = size(diff_gdp);

% go back 20 periods, calculate MSE for each model
Mdl = arima(2,1,1);
rmses = zeros(5,1)
for i = 1

    % for instance, go back one quarter, compare to what is really was in that quarter, then compare what each model says it should be.   
    gobackto = diff_gdp(1:numobs-i);
    EstMdl = estimate(Mdl, gobackto, Display="off");

    % what was the real value?  This is the real data we have, we want the
    % NEXT value
    realYlast = realY(1:end-i+1);
    lastrealdata = realYlast(end);
    
    %forecast one period into the future, this is the differenced data, it
    %should also go to the NEXT to last observatoin
    [YForecast,YStd] = forecast(EstMdl,horizon, gobackto);
    
    % make prediction
    pred = cumsum([119388; gobackto; YForecast]);
    predlast = pred(end);

    offby = predlast - lastrealdata;
   
    rmses(i) = rmse(predlast, lastrealdata)

    if predlast > lastrealdata
        fprintf('Estimate too high, %f\n%', offby);
    else
        fprintf('Estimate too low, %f\n%', offby);
    end

end

mean(nonzeros(rmses))

%%%%
% 211 best model, now use all data
%%%%

gobackto = diff_gdp(1:numobs - 0);
EstMdl = estimate(Mdl, gobackto, Display="full");
[YForecast,YStd] = forecast(EstMdl,horizon, gobackto)
pred = cumsum([119388; gobackto; YForecast]);
predlast = pred(end)

% display last two points
display(pred(end-horizon:end));
plot(pred);

