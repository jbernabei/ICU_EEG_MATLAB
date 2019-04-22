function [F1, Precision, Recall, IsolateInstances, Mdl] = random_Forest(MyHugeFeats, MyHugeLabels, Num_patients,testCut)

X = [];
Y = [];
Xtest = [];
Ytest = [];
for i = 1:Num_patients
    X = [X MyHugeFeats{i}];
    Y = [Y MyHugeLabels{i}];
end

backup = Y;

indices = randsample(size(X,2),floor(size(X,2)*testCut),false);

Xtest = X(:,indices);
Ytest = Y(indices);
Xtrain = X;
Ytrain = Y;
Xtrain(:,indices) = [];
Ytrain(indices) = [];

Mdl = TreeBagger(300,Xtrain',Ytrain, 'Cost',[0 0.001; 0.999, 0]);

Yguess_cell = Mdl.predict(Xtest');

Yhat = str2num(cell2mat(Yguess_cell));

IsolateInstances = sum(Yhat')./size(Ytest,2);

TPrate = sum((Yhat' + Ytest)==2)./sum(Ytest);

TNrate = sum((Yhat' + Ytest)==0)./sum(Ytest == 0);

Precision = sum((Yhat' + Ytest)==2)./sum(Yhat');

Recall = sum((Yhat' + Ytest)==2)./(sum((Yhat' + Ytest)==2) + sum(((Yhat' == 0)+ (Ytest==1))==2));

F1 = 2*Precision*Recall/(Recall + Precision);

counter = 0;


