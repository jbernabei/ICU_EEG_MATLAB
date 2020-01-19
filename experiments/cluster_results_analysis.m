clear all

num_clusters = [1:7];
load all_annots_85.mat
load BigOlLabels4.mat
%%

for i = 1:32
    amount_sz(i) = sum(labelSeizureVector{i});
    portion_sz(i) = amount_sz(i)./length(labelSeizureVector{i});
    num_sz(i) = length(all_annots(i).sz_start);
end

%% Get ROC for all seizure containing patients
threshold = [0.01:0.01:1];


for c = num_clusters
    load(sprintf('patient_results_edit_%d_clusters.mat',c))
    for pt = [1:85]%[1:53,55:58,60:70,72:75,77:85]
        pt_in_clust(c,pt) = patient_results(pt).clust_info;
        cluster_train(c).results(pt).data = patient_results(pt).train_patients;
        for s = [1,2,3,4]
            Y_score = patient_results(pt).score_vals;
            Y_true = labelSeizureVector{pt}';
            for t = 1:length(threshold)
                % Threshold votes
                if size(Y_score,2)==1
                    Y_pred = Y_score-1;
                else
                    Y_pred = double(Y_score(:,2)>=threshold(t));
                end
                
                % Smooth seizure identifications
                Y_pred = VoteFiltering(Y_pred,s);
                Y_pred_smooth(c).cluster(s).patient(pt).threshold(t,:) = Y_pred;
                [IsolateInstances,TPrate,TNrate,Precision,Recall,F1,AdvRecall] = JustMetrics(Y_pred,Y_true);
                if pt < 33
                    TPR_thresh(c).cluster(s).smooth(pt,t) = sum((Y_pred+Y_true)==2)./sum(Y_true);
                    FPR_thresh(c).cluster(s).smooth(pt,t) = sum((Y_true-Y_pred)==-1)./sum(Y_true==0);
                    
                    adv_recall_clust(c).cluster(s).smooth(pt,t) = AdvRecall;
                    data_redux(c).cluster(s).smooth(pt,t) = 1-IsolateInstances;
                else
                    data_redux(c).cluster(s).smooth(pt,t) = 1-IsolateInstances;
                end
            end
        end
    end
end

%% Figure 2A: Raw ROC for individual window prediction
figure(1);clf
hold on

cmp2 = [78 172 91;
        246 193 67;
        78 171 214;
        103 55 155]/255;
a = 0;    
for c = [1,3,5,7]
    a =  a+1;
    clear TPR
    clear FPR
    for pt = 1:32
    TPR(pt,:) = TPR_thresh(c).cluster(4).smooth(pt,:);
    FPR(pt,:) = FPR_thresh(c).cluster(4).smooth(pt,:);
    end
    mean_TPR_clust = mean(TPR);
    mean_FPR_clust = mean(FPR);
   
    plot(mean_FPR_clust,mean_TPR_clust,'LineWidth',2,'Color',cmp2(a,:))
    
    AUC(a) = 1- sum(mean_TPR_clust)./length(mean_TPR_clust)
end
ylabel('True positive rate')
xlabel('1 - False positive rate')
title('Window-wise ROC of cross-patient classifier')
plot([0 1],[0 1],'k-.')
legend('1 cluster','3 clusters','5 clusters','7 clusters','chance','Location','NorthWest')
hold off


%% Figure 2B: Recall - data reduction
figure(2);clf
hold on

cmp2 = [78 172 91;
        246 193 67;
        78 171 214;
        103 55 155]/255;
a = 0;    
for c = [1,3,5,7]
    a =  a+1;
    clear TPR
    clear FPR
    for pt = 1:32
    TPR(pt,:) = data_redux(c).cluster(1).smooth(pt,:);
    FPR(pt,:) = adv_recall_clust(c).cluster(1).smooth(pt,:);
    end
    mean_TPR_clust = median(TPR);
    mean_FPR_clust = median(FPR);
   
    plot(mean_FPR_clust,mean_TPR_clust,'LineWidth',2,'Color',cmp2(a,:))

end
xlabel('Median data reduction')
ylabel('Median seizure sensitivity')
%title('Relationship between seizure sensitivity and data reduction')
legend('1 cluster','3 clusters','5 clusters','7 clusters','Location','SouthWest')
hold off

%% Figure 2C: Distribution of all adv recall across clusters - seizure
a = 0;
clear all_data
clear all_data_orig
for c = [1,3,5,7]
    a = a+1;
    all_data(:,a) =  adv_recall_clust(c).cluster(3).smooth(:,50);
    all_data_orig(:,a) = adv_recall_clust(c).cluster(3).smooth(:,50);
end
all_data = all_data(:);
axis_nums = [1:4];
scatter_plot_axis = [ones(1,32),2*ones(1,32),3*ones(1,32),4*ones(1,32)];
figure(3);clf
hold on
for i = 1:4
    scatter(scatter_plot_axis(i+32*(i-1):32*i),all_data(i+32*(i-1):32*i),'jitter','on','MarkerEdgeColor',cmp2(i,:),'MarkerFaceColor',cmp2(i,:))
end
ylabel('Fraction of all seizures detected')
%title('Seizure detection for different numbers of clusters')
xlabel('Number of clusters')

plot([axis_nums(1,:)-0.15; axis_nums(1,:) + 0.15], repmat(nanmedian(all_data_orig, 1), 2, 1), 'k-','Linewidth',2)
hold off

for i = 1:4
    for j = 1:4
        P_val = signrank(all_data_orig(:,i),all_data_orig(:,j));
        p_adv_recall(i,j) = P_val
    end 
end

%% Figure 3A: Distribution of all data reduction across clusters - seizure
a = 0;
clear all_data
for c = [1,3,5,7]
    a = a+1;
    all_data(:,a) =  data_redux(c).cluster(3).smooth(1:32,50);
    all_data_orig(:,a) = data_redux(c).cluster(3).smooth(1:32,50);
end
all_data = all_data(:);
axis_nums = [1:4];
scatter_plot_axis = [ones(1,32),2*ones(1,32),3*ones(1,32),4*ones(1,32)];
figure(4);clf
hold on
for i = 1:4
    scatter(scatter_plot_axis(i+32*(i-1):32*i),all_data(i+32*(i-1):32*i),'jitter','on','MarkerEdgeColor',cmp2(i,:),'MarkerFaceColor',cmp2(i,:))
end
ylabel('Data reduction')
%title('Data reduction for different numbers of clusters: Seizures')
xlabel('Numbers of clusters')

plot([axis_nums(1,:)-0.15; axis_nums(1,:) + 0.15], repmat(nanmedian(all_data_orig, 1), 2, 1), 'k-','Linewidth',2)
hold off

for i = 1:4
    for j = 1:4
        P_val = signrank(all_data_orig(:,i),all_data_orig(:,j));
        p_data_redux(i,j) = P_val
    end 
end


%% Figure 3B: Distribution of all data reduction across clusters - non seizure
a = 0;
clear all_data
clear all_data_orig
for c = [1,3,5,7]
    a = a+1;
    all_data(:,a) =  data_redux(c).cluster(3).smooth(32:85,50);
    all_data_orig(:,a) = data_redux(c).cluster(3).smooth(32:85,50);
end
all_data = all_data(:);
axis_nums = [1:4];
scatter_plot_axis = [ones(1,53),2*ones(1,53),3*ones(1,53),4*ones(1,53)];
figure(5);clf
hold on
for i = 1:4
    scatter(scatter_plot_axis(i+53*(i-1):53*i),all_data(i+53*(i-1):53*i),'jitter','on','MarkerEdgeColor',cmp2(i,:),'MarkerFaceColor',cmp2(i,:))
end
ylabel('Data reduction')
%title('Data reduction for different numbers of clusters: Non-seizure')
xlabel('Numbers of clusters')

plot([axis_nums(1,:)-0.15; axis_nums(1,:) + 0.15], repmat(nanmedian(all_data_orig, 1), 2, 1), 'k-','Linewidth',2)
hold off

for i = 1:4
    for j = 1:4
        P_val = signrank(all_data_orig(:,i),all_data_orig(:,j));
        p_data_redux(i,j) = P_val
    end 
end


%% Figure 4A: Performance of seizure detection across diagnostic subtype
for pt = 1:32
    sz_detect_type(pt) = all_annots(pt).type;
    sz_detect_perform(pt) = adv_recall_clust(7).cluster(3).smooth(pt,50);
end
figure(6);clf
scatter(sz_detect_type,sz_detect_perform)
xlabel('Placeholder')
ylabel('Placeholder')
%% Figure 4B: Performance of data reduction across diagnostic subtype
for pt = 1:85
    data_redux_type(pt) = all_annots(pt).type;
    data_redux_perform(pt) = data_redux(7).cluster(3).smooth(pt,50);
end
figure(7);clf
scatter(data_redux_type,data_redux_perform)
xlabel('Placeholder')
ylabel('Placeholder')

for i = 1:4
    for j = 1:4
        p_val_class(i,j) = ranksum(data_redux_perform(find(data_redux_type==i)),data_redux_perform(find(data_redux_type==j)))
    end
end

%% Figure 6: Show attention vs label for a few patients
c1 = [220 91 45]./255;
c2 = [46 105 200]./255;

figure(8);clf
hold on
sz_loc = find(labelSeizureVector{6}==1);
plot((sz_loc*5./3600),ones(length(sz_loc),1),'rs','MarkerSize',20,'markeredgecolor',c2,'markerfacecolor',c2)
sz_pred = find(Y_pred_smooth(7).cluster(4).patient(6).threshold(50,:)==1);
plot((sz_pred*5./3600),ones(length(sz_pred),1),'ks','MarkerSize',8,'markeredgecolor',c1,'markerfacecolor',c1)
hold off

figure(9);clf
hold on
sz_loc2 = find(labelSeizureVector{26}==1);
plot((sz_loc2*5./3600),ones(length(sz_loc2),1),'rs','MarkerSize',20,'markeredgecolor',c2,'markerfacecolor',c2)
sz_pred2 = find(Y_pred_smooth(7).cluster(4).patient(26).threshold(50,:)==1);
plot((sz_pred2*5./3600),ones(length(sz_pred2),1),'ks','MarkerSize',8,'markeredgecolor',c1,'markerfacecolor',c1)
hold off

% figure(10);clf
% hold on
% sz_pred3 = find(Y_pred_smooth(7).cluster(4).patient(12).threshold(50,:)==1);
% plot((sz_pred3*5./3600),ones(length(sz_pred3),1),'ko','MarkerSize',10,'markerfacecolor','k')
% sz_loc3 = find(labelSeizureVector{12}==1);
% plot((sz_loc3*5./3600),ones(length(sz_loc3),1),'ro','MarkerSize',5,'markerfacecolor','r')
% hold off

%% Lin reg

plt_style = {'bo','ro'}

for i = [2:3]
lm = fitlm(num_pt_in_clust(1:30,i),adv_recall_clust(1:30,i))
x0 = table2array(lm.Coefficients(1,1))
x1 = table2array(lm.Coefficients(2,1))
pval = table2array(lm.Coefficients(2,4))
figure(i-1);clf
hold on
plot(num_pt_in_clust(1:30,i),adv_recall_clust(1:30,i),plt_style{i-1})
xvals= [min(num_pt_in_clust(1:30,i)):max(num_pt_in_clust(1:30,i))];
plot(xvals,(xvals.*x1+x0),'k-')
hold off
xlabel('Number of patients in cluster')
ylabel('Fraction of seizures detected')
title(sprintf('Relationship between number of patients in cluster and seizure detection p = %d',pval))
end

%% Make ROC for predicting whether any seizures or not
all_redux = [data_reduction_sz(1:30,4);data_reduction_nonsz(:,4)];
all_labels = [ones(30,1);zeros(51,1)];

t_sweep = [0.01:0.01:1];

for i = 1:length(t_sweep)
    predictions = (all_redux<=t_sweep(i));
    TPR(i) = sum((predictions+all_labels)==2)./sum(all_labels);
    FPR(i) = sum((all_labels-predictions)==-1)./sum(all_labels==0);
    one_minus_FPR(i) = 1-FPR(i);
end

figure(1);clf;
hold on
plot(FPR,TPR,'b-')
plot([0,1],[0,1],'k--')
auc = 1- sum(TPR)./sum(ceil(TPR))
xlabel('1 - False Positive Rate')
ylabel('True Positive Rate')
title('ROC for prediction of seizure presence (AUC = 0.67)')
