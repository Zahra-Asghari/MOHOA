function [y,x]=AccFun(x)
warning off
%we used this function to calculate the fitness value as in the paper 
global Data trn vald 
x=[x,0];
 x=find(x>0.5);
 
if sum(x)==0
    y=inf;
    return;
end

c = knnclassify(Data(vald,x),Data(trn,x),Data(trn,end));
cp = classperf(Data(vald,end),c);
y=cp.CorrectRate;
end
