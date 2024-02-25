function y=FitFun(x)
global Data trn vald 
warning off
y(1,1)=sum(x)/length(x);
 x=[x,0];
 x2=find(x>0.5);
if sum(x2)==0
    y(1,1)=1;
    y(2,1)=100;
    return;
end
% c=fitcknn(Data(trn,x2),Data(trn,end),'NumNeighbors',5);
% flwrClass = predict(c,Data(vald,x2));

c = knnclassify(Data(vald,x2),Data(trn,x2),Data(trn,end),5);
cp = classperf(Data(vald,end),c);

y(2,1)=cp.ErrorRate*100;
end
