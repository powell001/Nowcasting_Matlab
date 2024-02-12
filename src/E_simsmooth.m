clc; clear;

load transformedData.mat
load bestfeatures.mat

namemodel = 'BESTModel_ImpgoodsserviceInvestBeloning';
namemodel = 'CompleteNetexpGovconInvHouse';
numlags = 3;


seriesnames = DataTimeTable.Properties.VariableNames;

% best, 4(4*4) + 4 = 68
% seriesnames = seriesnames([1; indexnzc]);
% 

% employ gov added, use lag of 5, so 5(1*5) + 5 = 30
% gdp, netexp, invest, beloning
% seriesnames = seriesnames([1; 7; 5; 16])
%

% employ gov added, use lag of 5, so 5(1*5) + 5 = 30
% gdp, netexp, invest, govcon
seriesnames = seriesnames([1; 7; 4; 5])
%

% employ gov added, use lag of 2, so 5(2*5) + 5 = 55
% gdp, netexp, invest, govcon, beloning
% seriesnames = seriesnames([1; 7; 4; 5; 16])
%

% employ gov added, use lag of 2, so 5(2*5) + 5 = 55
% gdp, netexp, invest, govcon, household
% seriesnames = seriesnames([1; 7; 4; 5; 3]);
%

TR = timerange("1996-04-01", "2023-11-01");
DataTimeTable = DataTimeTable(TR, seriesnames);

rmldDataTimeTable = rmmissing(DataTimeTable(:,seriesnames));

numseries = numel(seriesnames);


PriorMdl = conjugatebvarm(numseries,numlags,'SeriesNames',seriesnames);
numcoeffseqn = size(PriorMdl.V,1);
PriorMdl.V = 1e4*eye(numcoeffseqn);

[Coeff,Sigma] = simsmooth(PriorMdl,rmldDataTimeTable.Variables);

Summary = summarize(PriorMdl,'off');
table(Coeff(:,1),'RowNames',Summary.CoeffMap);

EmpMdl = empiricalbvarm(numseries,numlags,'SeriesNames',seriesnames,...
    'CoeffDraws',Coeff,'SigmaDraws',Sigma);
summarize(EmpMdl,'equation');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [~,~,NaNDraws] = simsmooth(PriorMdl,DataTimeTable.Variables);
% 
% [idxi,idxj] = find(ismissing(DataTimeTable),1);
% responsename = seriesnames(idxj(end))
% 
% observationtime = DataTimeTable.Date(idxi(end))
% 
% histogram(NaNDraws(3,:))
% title('Q3-2020 GDP Difference Empirical Distribution')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PriorMdl = conjugatebvarm(numseries,numlags,'SeriesNames',seriesnames);
numcoeffseqn = size(PriorMdl.V,1);
PriorMdl.V = 1e4*eye(numcoeffseqn);

% rng(1); % For reproducibility
numperiods = 7;
YF = forecast(PriorMdl,numperiods,rmldDataTimeTable{:,seriesnames});


fh = rmldDataTimeTable.Date(end) + calmonths(1:numperiods);
for j = 1:PriorMdl.NumSeries
    subplot(numseries,1,j)
    plot(rmldDataTimeTable.Date(end - 20:end),rmldDataTimeTable{end - 20:end,seriesnames(j)},'r',...
        [rmldDataTimeTable.Date(end) fh],[rmldDataTimeTable{end,seriesnames(j)}; YF(:,j)],'b');
    legend("Observed","Forecasted",'Location','NorthWest')
    title(seriesnames(j))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fTT = array2timetable(NaN(numperiods,numseries),'RowTimes',fh,...
    'VariableNames',seriesnames);
frmldDataTimeTable = [rmldDataTimeTable(:,seriesnames); fTT];
tail(frmldDataTimeTable)

[~,~,~,YMean] = simsmooth(PriorMdl,frmldDataTimeTable.Variables);

YMeanTT = array2timetable(YMean,'RowTimes',frmldDataTimeTable.Date((PriorMdl.P + 1):end),...
    'VariableNames',seriesnames);

tiledlayout(numseries,1)
for j = 1:PriorMdl.NumSeries
    nexttile
    plot(YMeanTT.Time((end - 20 - numperiods):(end - numperiods)),YMeanTT{(end - 20 - numperiods):(end - numperiods),j},'r',...
        YMeanTT.Time((end - numperiods):end),YMeanTT{(end - numperiods):end,j},'b');
        legend("Observed","Forecasted",'Location','NorthWest')
    title(seriesnames(j))
end

savecsv(DataTimeTable, TR, YMeanTT, numperiods,frmldDataTimeTable, namemodel)

function levels = savecsv(dataTT, TR, YMeanTT, numperiods, frmldDataTimeTable, namefile)
    % code to dediff data, combine with forecasts, plot
    diff_historicaldata = dataTT(TR,1);
    works = [diff_historicaldata; YMeanTT(end - numperiods + 1:end, 1)];
    works1 = table2array(rmmissing(works));
    levels = cumsum([120275.3333; works1]);

    writematrix(levels, strcat("output/", namefile, ".csv"));
    
    %myend = size(levels);
    figure;
    x1 = datetime(2023,10,1);
    x2 = datetime(2024,1,1);
    fx = [x1 x2 x2 x1];
    fy = [160000  160000  210000 210000];

    patch(fx, fy, [0.693 1.0 0.349])
    hold on

    xaxs = frmldDataTimeTable.Date;
    x1= xaxs(275-1:end);
    y1 = levels(275:end);
    plot(x1, y1, LineWidth=2);
    hold off
    title(namefile)
    grid

    saveas(gcf, strcat('output/', namefile, '.png'))

end


