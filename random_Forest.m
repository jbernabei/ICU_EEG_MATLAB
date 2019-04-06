Num_patients = 1;
X = [];
Y = [];
Xtest = [];
Ytest = [];
for i = 1:Num_patients
    X = [X feats{i}];
    Y = [Y labelSeizureVector{i}];
end

indices = randsample(Num_patients*size(feats{1},2),floor(Num_patients*size(feats{1},2)*0.30),false);

Xtest = X(:,indices);
Ytest = Y(indices);
X(:,indices) = [];
Y(indices) = [];

Mdl = TreeBagger(300,X',Y, 'Cost',[0 0.0001; 0.9999, 0]);

Yguess_cell = Mdl.predict(Xtest');

Yhat = str2num(cell2mat(Yguess_cell));

accuracy = sum((Yhat'==Ytest))/size(Ytest,2)

TPrate = sum((Yhat' + Ytest)==2)./sum(Ytest);

TNrate = sum((Yhat' + Ytest)==0)./sum(Ytest == 0);

Precision = sum((Yhat' + Ytest)==2)./sum(Yhat');

Recall = sum((Yhat' + Ytest)==2)./(sum((Yhat' + Ytest)==2) + sum(((Yhat' == 0)+ (Ytest==1))==2));

F1 = 2*Precision*Recall/(Recall + Precision);

