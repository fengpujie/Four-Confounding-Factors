%This Code is Using to Determining 2 Confounding Factors: different time points and parcellation 
%In Individual Cognitive Traits Prediction With Functional Connectivity
%Just select the type of input FC or select subjects to change variance can also determining
%Other two Factors:different variance of the predicted target and different type of FC
clc,clear all
tic,
load('sub_ID&sub_score.mat'); %column 1:sub_ID and column 2: sub_score,1003rows.
ic=[15,25,50,100,200,300];  %ICs
savepath=[''];  %define savepath
for i=1:6
    IC=ic(i);
    column=1;
    for time=100:100:1200       %
        trainloadpath=['/0-',num2str(time),'/IC',num2str(IC),'time0-',num2str(time),'FC'];
        load (trainloadpath);       % load FC data
        type=['IC',num2str(IC),'time0-',num2str(time),'',num2str(l),'_S1200'];  %define name of result data
        [~,index_sub]=ismember(trainsub(:,1),all_fc(:,1)); 
        FC=all_fc(index_sub,:);
        score=(trainsub(:,2));
             for times=1:100
                [r]=myplsrwithbeta(FC(:,2:end),score,time);
                result{times,column}=r.positive;
                beta{times,column}=r.beta;
             end
    end
 % ---------------save the results-----------------
       
            save([savepath,'/',type,'.mat'],'result','beta');
            clear result;clear beta;
 %------------
end  
 toc;