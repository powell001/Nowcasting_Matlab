function checkArima(y,pp,qq, numobs)
% pp is the maximum for p
% qq is the maximum for q
LOGL = zeros(pp+1,qq+1); %Initialize
PQ = zeros(pp+1,qq+1);
for r = 0:1
    for p = 1:pp+1
        for q = 1:qq+1
            mod = arima(p-1,r,q-1);
            [fit,~,logL] = estimate(mod,y);
            LOGL(p,q) = logL;
            PQ(p,q) = p+q;
        end
    end
end
LOGL = reshape(LOGL,(pp+1)*(qq+1),1);
PQ = reshape(PQ,(pp+1)*(qq+1),1);
[~,aic] = aicbic(LOGL,PQ+1,numobs);
ar=reshape(aic,pp+1,qq+1);
% display(aic);

minimum = min(min(ar));
[x,y]=find(ar==minimum);

bestmod = ['AR: ' num2str(x - 1), ' Diff: ' num2str(r),  ' MA: ' num2str(y - 1)];
% disp(bestmod);
end

% the rows correspond to the AR degree (p) and the
% columns correspond to the MA degree (q). The smallest value is best


