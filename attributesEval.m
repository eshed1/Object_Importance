function [ evalmoderescollect,CHIST ] = attributesEval( prm ,allfts,alllabs)
%Annotations are kept in these indices, either by median vote ([1,2,3]) or
%by mean vote (continous number between 1 and 3).
IDXMEDIANVOTE = 10; %in label array
IDXMEANVOTE = 11;

objmodes = prm.objmodes;
Cval = prm.Cval;
CVlist = prm.CVlist;
plotmode_i= prm.plotmode_i;


T = prm.bgeotemporal.takeback; %Frames to take back
FTPERTIME = length(prm.IDXFORGEO);  %12 usually.  %HOW MANY FEATURES PER TIME INSTANCE

%allstats = [];  tableAUC = []; stdAUC = []; 
ftcombos= []; tableAUCreg = [];
evalmoderescollect = [];
CHIST = []; 

for evalmode = 0:1; %0 classification, 1 regression
    for ci = 1:length(Cval)
        cvalue = Cval(ci);
        
        %disp('careful! feature indices and object mode changed'); pause(1);
        for obj_i = 1:length(objmodes) %1:4
            ftcombos = [];
            objtypemode = objmodes{obj_i};
            
            %If want to do per user. Look at plotmode_i == 3
            NUSEERS = 1;
            
            %Several evaluation modes. 
            if(plotmode_i==1)
                %Temporal mode, all features
                
                for i_k =1:T-1
                    ftcombos{1,i_k} = [1:i_k*FTPERTIME];
                end
               % ftcombos = {1:(T-1)*FTPERTIME};  %ALL ATTRIBUTES OVER TIME JUST LAST TIME STEP
                % ftcombos= {1:30*FTPERTIME};
                %ftcombos ={1,[1:40*FTPERTIME]}
                % ftcombos ={1,[1:30*FTPERTIME],1:(T-1)*FTPERTIME};
            
            elseif(plotmode_i==2)
                %% Analysis per attribute
                 ftcombos = {1,2,3,4,5,6,7,8,9,10,11,12,1:12}; %INDIVIDUAL  ATTRIBUTES VS ALL
               
                %Analysis of per attribute over time
%                 ftcombos = []; %EVERY T-1 = 30
%                 for fttype = 1:FTPERTIME
%                     %%
%                     tempftcombos = [];
%                     for i_k = 1:T-1
%                         tempftcombos{i_k} = [fttype:FTPERTIME:i_k*FTPERTIME];
%                     end
%                     ftcombos = [ftcombos tempftcombos];
%                 end
            elseif(plotmode_i==3)
                NUSEERS = length(subjlist);
                %disp('change to 1:4 object modes! and take mean of res.auc'); pause;
                %ftcombos{1} = [1:FTPERTIME]; %Without temporal
                ftcombos{1} = [1:(T-1)*FTPERTIME]; %WITH temporal
            end
            
            for i_user = 1:NUSEERS %:length(subjlist)
                if(NUSEERS>1)
                    gt = filter_annotations(prm,outvids(:,i_user),metadata);
                    [allfts,alllabs] = extractFts_clean(prm,gt,metadata);
                end
                
                for ft_i = 1:length(ftcombos)
                    
                    disp(['Eval mode:' num2str(evalmode) ', C-value: ' num2str(ci) '/' num2str(length(Cval)) ', Object mode: ' num2str(obj_i) '/' num2str(length(objmodes)) ', Feature type: ' num2str(ft_i) '/' num2str(length(ftcombos))]);
                    
                    
                    probshist = []; res = [];
                    for i_imp=[1:3];probshist(i_imp).y = []; probshist(i_imp).deci = []; end
                    
                    %CV lists. do better next... 2 folds, have many...
                    %CVlist = {[1:7],8};
                    
                    for cv = 1:size(CVlist,1)
                        clear l_tr_s d_tr_s l_te d_te d_tr_swnorm d_te_swnorm dtemptr dtempte dtemp2
                        
                        
                        prm.tr_vidsi = CVlist{cv,1}; prm.te_vidsi = CVlist{cv,2};
                        
                        %Next train an importance regressor/classifier using features...
                        [l_tr_s,d_tr_s,l_te,d_te] = sort_data(prm,allfts,alllabs);
                        
                        if(sum(sum(isnan(l_tr_s)))>0); pause; end
                        if(sum(sum(isnan(l_te)))>0); pause; end
                        
                        %Remove ignore
                        iglist = []; iglist = l_tr_s(:,1)==-1; l_tr_s(iglist,:) = []; d_tr_s(iglist,:) = [];
                        iglist = []; iglist = l_te(:,1)==-1; l_te(iglist,:) = []; d_te(iglist,:) = [];
                        
                        d_tr_s = d_tr_s(:,ftcombos{ft_i});
                        d_te = d_te(:,ftcombos{ft_i});
                        
                        if(isempty(d_tr_s)); d_tr_s= []; end
                        if(isempty(d_te)); d_te= []; end %liblinear takes empty arrays, oddly...
                        
                        %%
                        %Can extract DCT features using Matlab's DCT here,
                        %This is not exactly how it should be done but it's
                        %neat and gives comparable (minor) improvement to
                        %applying by attribute over time seperately.
                        XX = dct(d_tr_s'); XX = XX'; d_tr_s = [d_tr_s(:,:) XX];
                        XX = dct(d_te'); XX = XX'; d_te = [d_te(:,:) XX];
                        
                        %%
                        switch objtypemode
                            case 'veh';
                                idxtorem = find(l_tr_s(:,1)~=1); d_tr_s(idxtorem,:) = []; l_tr_s(idxtorem,:) = [];
                                idxtorem = find(l_te(:,1)~=1); d_te(idxtorem,:) = []; l_te(idxtorem,:) = [];
                            case 'ped';
                                idxtorem = find(l_tr_s(:,1)~=2); d_tr_s(idxtorem,:) = []; l_tr_s(idxtorem,:) = [];
                                idxtorem = find(l_te(:,1)~=2); d_te(idxtorem,:) = []; l_te(idxtorem,:) = [];
                            case 'cyc';
                                idxtorem = find(l_tr_s(:,1)~=3); d_tr_s(idxtorem,:) = []; l_tr_s(idxtorem,:) = [];
                                idxtorem = find(l_te(:,1)~=3); d_te(idxtorem,:) = []; l_te(idxtorem,:) = [];
                            case 'all';
                                %Try to add object type as the feature - minimal
                                %change, but OK.
                                d_tr_s = [l_tr_s(:,1) d_tr_s];
                                d_te = [l_te(:,1) d_te];
                        end
                        
                        bGoodVote = ~sum((l_tr_s(:,IDXMEDIANVOTE)==1 | l_tr_s(:,IDXMEDIANVOTE)==2 | l_tr_s(:,IDXMEDIANVOTE) ==3)==0);
                        bGoodRange = sum(l_tr_s(:,IDXMEANVOTE)>3 | l_tr_s(:,IDXMEANVOTE)<1)==0;
                        if(~bGoodVote || ~bGoodRange); disp('error label!'); pause; end
                        
                        impmodes = 1;
                        if(evalmode==0)
                            impmodes = [1:3];  %Classification
                        end
                        
                        for i_imp = impmodes;
                            %Convert to binary +/- 1.
                            
                            templ_tr = l_tr_s(:,IDXMEDIANVOTE);
                            idxpos = (templ_tr==i_imp);
                            idxneg = (templ_tr~=i_imp);
                            
                            templ_tr(idxpos) = 1;
                            templ_tr(idxneg) = -1;
                            
                            [d_tr_swnorm, minx, rangex] = rescaleData(d_tr_s,0,1);
                            if(evalmode==0)
                                model = train(ones(size(l_tr_s,1),1),templ_tr,sparse(double(d_tr_swnorm)),['-s 0 -c ' num2str(cvalue) ' -B 1 -q 1']);
                            else
                                %New labels
                                templ_tr = l_tr_s(:,IDXMEANVOTE); %no pos/neg, just regression value.
                                if(any(templ_tr<1) || any(templ_tr>3)); disp('error!'); pause; end
                                
                                %2.25 seems still like a good threshold
                                %here!hist(templ_tr). 
                                model = train(ones(size(l_tr_s,1),1),templ_tr,sparse(double(d_tr_swnorm)),['-s 11 -c ' num2str(cvalue) ' -B 1 -q 1']);
                            end
                            if(~isempty(model.Label) && model.Label(1)~=1); disp('BAD ORDERING!'); pause; end
                            
                            templ_te = l_te(:,IDXMEDIANVOTE);
                            idxpos = (templ_te==i_imp);
                            idxneg = (templ_te~=i_imp);
                            templ_te(idxpos) = 1;
                            templ_te(idxneg) = -1;
                            [d_te_swnorm, minx, rangex] = rescaleData(d_te,0,1,minx,rangex);
                            
                            
                            if(evalmode==0)
                                %classification
                                [s1,s2,s3] = predict(templ_te,sparse(double(d_te_swnorm)),model,'-b -1 -q 1');
                            else
                                %regression
                                templ_te = l_te(:,IDXMEANVOTE);
                                [s1,s2,s3] = predict(templ_te,sparse(double(d_te_swnorm)),model,'-q 1');
                                s1(s1<1)=1; s1(s1>3)=3;
                                s3 = [s1]; %Meaningless here.
                                
                                
                            end
                            
                            probshist(i_imp).y = [probshist(i_imp).y; [templ_te l_te] ];
                            probshist(i_imp).deci = [probshist(i_imp).deci ; s3(:,1)]; %concatenate over folds
                        end
                        
                    end
                    
                    %Sanity check, always same size
                    sanityl = length(probshist(1).deci);
                    expectedlength = size(l_tr_s,1)+size(l_te,1);
                    if(sanityl~=expectedlength); disp('warning! cv error suspected!'); pause; end
                    if(evalmode==0)
                        for i_sanity = 1:length(probshist)
                            if(length(probshist(i_sanity).deci)~=sanityl); disp('error'); pause; end
                        end
                    end
                    
                    %
                    %Plot final statistics
                    res = []; cols = [1 0 0; 1 0.7961 0; 0 1 0]; %cols = [1 0 0;1 0.5 0;0 1 0];
                    if(evalmode==0)
                        for i_imp = [1:3]
                            %%
                            %[sx,sy,auc] = plotroc_liblin_byscore(probshist(i_imp).y(:,1),probshist(i_imp).deci,model);
                            imp_temp_labs = probshist(i_imp).y(:,1);
                            %-1 neg and 1 pos, otherwise 0 is ignore
                            bsanity = sum(~(imp_temp_labs==1 | imp_temp_labs==-1))==0;
                            if(~bsanity); disp('label error!'); pause; end;
                            % pr
                            % [sx,sy,auc] = plotroc_liblin_byscore(imp_temp_labs,probshist(i_imp).deci,model);
                            [tpr,fpr,inforoc] = vl_roc(imp_temp_labs,probshist(i_imp).deci); %,'plot','fptp');
                            % plot(1-fpr,tpr)
                            %if(auc<0.5);disp('ROC error');  pause; end
                            
                            [recall, precision, info] = vl_pr(imp_temp_labs,probshist(i_imp).deci);
                            sx = recall;
                            sy = precision;
                            auc = info.auc;
                            
                            %x - recall , y-precission
                            
                            %disp(num2str(auc))
                            res(i_imp).sx = sx;
                            res(i_imp).sy = sy;
                            res(i_imp).auc = auc;
                            res(i_imp).rocauc = inforoc.auc;
                            
                            %   plot(sx,sy,'linew',4,'color',cols(i_imp,:));
                            %   hold on
                            %   grid on
                        end
                        
                        % legend('high','mod','low');
                        
                        %[res.auc]
                        %disp(num2str(mean([res.auc])))
                        
                       % CHIST = [CHIST;mean([res.auc])];
                        %  allstats(ft_i,ci,obj_i,i_user).res = res;
                        %  tableAUC(ft_i,ci,obj_i,i_user)= mean([res.auc]);
                        %  stdAUC(ft_i,ci,obj_i,i_user) =std([res.auc]);
                        
                        tempres = []; tempres.res = res;
                        tempres.mres = mean([res.auc]); tempres.stdres = std([res.auc]);
                        
                        evalmoderescollect{ft_i,ci,obj_i,i_user,evalmode+1} = tempres;
                    else
                        imp_temp_labs = probshist(1).y(:,1);
                        bsanity = sum((imp_temp_labs<1 | imp_temp_labs>3))==0;
                        if(~bsanity); disp('label error!'); pause; end;
                        
                        resMSE = mae(probshist(1).y(:,1)-probshist(1).deci);
                        
                      
                        idx1 = probshist(1).y(:,1)<=2.25; %HIGH IMPORTANCE
                        idx2 = probshist(1).y(:,1)>2.25; %LOW IMPORTANCE
                        
                        %This one 
                        resMSE1 = mae(probshist(1).y(idx1,1)-probshist(1).deci(idx1,:));
                        resMSE2 = mae(probshist(1).y(idx2,1)-probshist(1).deci(idx2,:));
                        
                        tempres = [];
                        tempres.tableAUCreg = [resMSE resMSE1 resMSE2]; %tableAUCreg;
                        
                        evalmoderescollect{ft_i,ci,obj_i,i_user,evalmode+1} = tempres;
                    end
                end
            end
        end
    end
end

end

