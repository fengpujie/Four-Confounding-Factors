function [r]=myplsrwithbeta(FC,score,timecourse)
%This function performs PLSR with 10-fold cross validation,
%Outputs statistical data and features weight "beta".
% Input

% 'FC'                Functional Connectivity in a matrix of size (number of training subjects, number of features)
% 'score'             behaviral data in a vector of size (number of training subjects, 1)
% 'time'              Time Points
% Output

% 'r.postivite'       statistical data:Correlation coefficient and its p value，R^2,MSE...
% 'r.beta'            Features weight "beta"


     %% 10-FLOD-CV
 features1=[FC,score(:,1)];
 samplesize=size(features1,1);
 fold_number=floor(samplesize/10);
 iteration=1;
 
 for component=1:10
     rand_index=randperm(samplesize);
     features=features1(rand_index,:);
     fprintf('\n Leaving out component # %6.3f',component);
     for i=1:10
            
     	temp_data=features;
        if i==10
            testing_index=(fold_number*i-(fold_number-1)):samplesize;
        else
        	testing_index=(fold_number*i-(fold_number-1)):fold_number*i;           
        end
        testing=temp_data(testing_index,:);
        temp_data(testing_index,:)=[];  
        training=temp_data; 
        [positive.xl,positive.yl,positive.xs,positive.ys,positive.beta,positive.pctvar,positive.mse] = plsregress(training(:,(1:end-1)),training(:,end),min(component,size(training,2)),'CV',10);
        positive.testing_features=[ones(size(testing,1),1),testing(:,(1:end-1))];
      %% multiple linear regression by positive features
      	fitted_training(:,1) = [ones(size(training,1),1),training(:,(1:end-1))]*positive.beta;
        positive_training(i,1)=corr(fitted_training,training(:,end));
        positive_predicted(testing_index,1) = positive.testing_features*positive.beta;
        plsrbeta(:,i)=positive.beta;
        clear positive; clear temp_data;
        clear training; clear fitted_training;
    end
    rbeta(:,iteration)=mean(plsrbeta,2);
      %% Statistical parameters
    r.positive{iteration,1}=num2str(timecourse);
    r.positive{iteration,2}=component;
    [r.positive{iteration,3},r.positive{iteration,4}]=corr(positive_predicted,features(:,end));
    r.positive{iteration,5}=mean(positive_training);
    r.positive{iteration,6}=length(positive_predicted);
    [r.positive{iteration,7},r.positive{iteration,8}]=corr(positive_predicted,features(:,end),'type','Spearman');
                
    mse1=sum((positive_predicted-features(:,end)).^2)/length(positive_predicted);
    mse2=sum((mean(features(:,end))-features(:,end)).^2)/length(positive_predicted);
    r.positive{iteration,9}=mse1;
    r.positive{iteration,10}=1-mse1/mse2; %R^2
                  
    clear mse1; clear mse2;
    disp([num2str(iteration),'  ',num2str(component),' ',num2str(r.positive{iteration,3}),' ',num2str(r.positive{iteration,7})]);
    iteration=iteration+1;
 end
     %% beta of plsr model
 for j=1:10
 	 pred(j,1)=r.positive{j,3};
 end
 [~,max_index]=max(pred(:,1));
 r.positive{11,1}=max_index;
 r.beta=rbeta(:,max_index);
 clear rbeta; clear positive_predicted;
end 
