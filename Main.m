clear all
clc

global Data trn vald;
d=input('select Dataset : 1=zoo   2=tic-toc-toe  3=Wine: ');
switch d
    case 1
        Data=load('zoo.dat');
    case 2
        Data=load('tic-tac-toe.data');
    case 3
        Data=load('wine.data');
        Data=[Data(:,2:end),Data(:,1)];
end
nVar=size(Data,2)-1; % number of decision variables
costFunction=@FitFun;
foldNum=5;
sampleNum= size(Data,1);
c = cvpartition(sampleNum,'k',foldNum);%Partition Data
for fold=1:foldNum
    tic
    trn=c.training(fold);
    vald=c.test(fold);
    VarSize=[1 nVar];

    Archive=MOHOA(nVar,costFunction);   
end


