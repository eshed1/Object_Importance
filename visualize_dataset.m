%Visualizations of annotations, subject info (in the end), etc.

LABELLIST = {
    'Car'
    'Van'
    'Truck'
    'Pedestrian'
    'Person (sitting)'
    'Cyclist'
    'Tram'
    'Misc'
    };

stats = []; allstds = [];
for i_vid = 1:length(vids);
    rankres = outvids(i_vid,:);
    %%
    for img_idx=0:length(rankres{1})-1
        totalrank = []; %Accumulates over subjects
        for subji=1:length(rankres)
            
            totalrank= [totalrank rankres{subji}{img_idx+1}.currrank];
        end
        %Some may have unavailable annotations. Remove them! Do not overlay/use. do
        %next.
        totalrank(totalrank<1) = nan; %-1 or less is unavailable
        totalrank(totalrank>3) = 3;
        avgrank = nanmean(totalrank,2);
        avgvote = nanmedian(totalrank,2);
        stdrank = nanstd(totalrank,[],2);
        
        if(sum(avgrank<0)>0 || sum(avgrank>3)>0);
            pause
        end
        %%
        idxrem = ~isnan(avgrank);
        
        avgrank = avgrank(idxrem,:);
        avgvote = avgvote(idxrem,:);
        stdrank = stdrank(idxrem,:);
        
        allstds = [allstds;stdrank];
        
        %Conservative!
        avgvote = ceil(avgvote);
        if(sum(avgvote ~=1 & avgvote~=2 & avgvote~=3)>0)
            pause
        end
        
        currbb = rankres{subji}{img_idx+1}.currbb(idxrem,:);
        currtrunc = rankres{subji}{img_idx+1}.currtrunc(idxrem,:);
        currocc = rankres{subji}{img_idx+1}.currocc(idxrem,:);
        currori = rankres{subji}{img_idx+1}.currori(idxrem,:);
        %%
        currlabels = [];
        for insti=1:length(rankres{subji}{img_idx+1}.currtypes)
            [labidx] = find(strcmp(rankres{subji}{img_idx+1}.currtypes{insti},LABELLIST)==1);
            currlabels = [currlabels;labidx];
        end
        currlabels = currlabels(idxrem,:);
        currcent = rankres{subji}{img_idx+1}.currcentroid(idxrem,:);
        %egovel = repmat(rankres{subji}{img_idx+1}.egovel,size(currcent,1),1);
        egovel = rankres{subji}{img_idx+1}.egovel(idxrem,:);
        currabsvel = rankres{subji}{img_idx+1}.currabsvel(idxrem,:);
        
        %%
        stats = [stats; [avgrank currbb currtrunc currocc currori avgvote currlabels currcent egovel currabsvel] ]; %Mag and direction. KMH
        
    end
end
%%
%%

%NEXT! ALSO COLLECT DISTANCE! HAVE THAT VALUE! Collect next. keep x y and
%z, so can study. TODO next. Can also get an occlusion percentage! to
%study! as opposed to 0-3. Check if there's a big differenct on any sample
%between 0 and 3. Do these next. Do these next in extraction. Almost done!
%Next add distance correctly. Type. Velocity? can do by distance kind of.
%do velocity next. pad it. also orientation velo.
close all

idxc = 5;
idx1 = find(stats(:,9)==1); %For each state...
idx2 = find(stats(:,9)==2);
idx3 = find(stats(:,9)==3);

Y= [];
Y.High = stats(idx1,idxc);
Y.Medium = stats(idx2,idxc);
Y.Low = stats(idx3,idxc);

cols = [1 0 0; 0 1 0; 0 0 1];
t = nhist(Y,'samebins','color',cols);
grid on
pause(1); 
%%
close all
%total statistics.
X = [length(idx1) length(idx2) length(idx3)];
pie(X)
%cols = [1 0 0; 0 1 0; 0 0 1];
   cols = [1 0 0;1 0.5 0;0 1 0];
colormap(cols)
legend('High','Medium','Low')
pause(1)

%%
%Avg distribution. 
close all

Y= [];
Y.vehicles = stats(idxcar,1);
Y.pedestrians = stats(idxperson,1);
Y.cyclists = stats(idxcyclist,1);

%colormap(hot)
colormap(linspecer(4))
hold on
fsz = 18;
[t1,t2,t3] = nhist(Y,'normal','samebins','binfactor',3,'color','colormap','fsize',fsz,'location','best');
grid on
xlabel('Average Rank','fontsize',fsz);
ylabel('% Samples','fontsize',fsz)
set(gca,'fontsize',fsz);
xlim([1 3]);
pause(1)
%%
close all
%other properties...
%11 12 13 are
%-30 to 30 (X) , -1.5 to 3 (Y), 0 to 100 (Z)
colormap(linspecer(4))
idxc = [11 12 13];
idx1 = find(stats(:,9)==1); %For each state...
idx2 = find(stats(:,9)==2);
idx3 = find(stats(:,9)==3);

Y= [];
Y.High = sqrt(sum(stats(idx1,idxc).^2,2));
Y.Medium =sqrt(sum(stats(idx2,idxc).^2,2));
Y.Low = sqrt(sum(stats(idx3,idxc).^2,2));

%colormap(hot)
hold on
fsz = 18;
cols = [1 0 0; 1 0.7961 0; 0 1 0];
colormap(cols)
t = nhist({Y.High, Y.Medium, Y.Low},'normal','samebins','binfactor',10,'color','colormap','fsize',fsz);
grid on
xlabel('Distance (meters)','fontsize',fsz);
ylabel('% Samples','fontsize',fsz)
set(gca,'fontsize',fsz);
pause(1)
%%

%%
close all
%Related to Z value.
idxc = [13];
idx1 = find(stats(:,9)==1); %For each state...
idx2 = find(stats(:,9)==2);
idx3 = find(stats(:,9)==3);

Y= [];
Y.High = stats(idx1,idxc);
Y.Medium =stats(idx2,idxc);
Y.Low = stats(idx3,idxc);

%colormap(hot)
t = nhist(Y,'samebins','binfactor',10,'color','colormap');
grid on
pause(1)
%%
close all
%AND X VAL
idxc = [11];
idx1 = find(stats(:,9)==1); %For each state...
idx2 = find(stats(:,9)==2);
idx3 = find(stats(:,9)==3);

Y= [];
Y.High = stats(idx1,idxc);
Y.Medium =stats(idx2,idxc);
Y.Low = stats(idx3,idxc);

%colormap(hot)
t = nhist(Y,'samebins','binfactor',10,'color','colormap');
grid on
pause(1)
%%
close all
%Velocity. 
idxc = [14];
idx1 = find(stats(:,9)==1); %For each state...
idx2 = find(stats(:,9)==2);
idx3 = find(stats(:,9)==3);

Y= [];
Y.High = stats(idx1,idxc);
Y.Medium =stats(idx2,idxc);
Y.Low = stats(idx3,idxc);

%colormap(hot)
colormap(cols)
%t = nhist(Y,'normal','samebins','binfactor',10,'color','colormap');
%grid on

hold on
fsz = 18;
cols = [1 0 0; 1 0.7961 0; 0 1 0];
colormap(cols)
t = nhist({Y.High, Y.Medium, Y.Low},'normal','samebins','binfactor',10,'color','colormap','fsize',fsz);
grid on
xlabel('Ego Velocity (MPH)','fontsize',fsz);
ylabel('% Samples','fontsize',fsz)
set(gca,'fontsize',fsz);
pause(1)
%%
close all
%Relative velocity. assume ego vel is always forward.
%CAREFUL SOME ARE -1000, first or previous empty frames. ignore these.
%NOTE! This is in meters/s . have to convert to

%First, remove -1000
MS2KMH = 3.6;
%plot(stats(stats(:,16)>-100,16)*MS2KMH)
idxc = [16];
idx1 = find(stats(:,9)==1 & stats(:,16)>-1000); %For each state...
idx2 = find(stats(:,9)==2 & stats(:,16)>-1000);
idx3 = find(stats(:,9)==3 & stats(:,16)>-1000);

Y= [];
Y.High = stats(idx1,idxc)*MS2KMH - stats(idx1,14);
Y.Medium =stats(idx2,idxc)*MS2KMH - stats(idx2,14);
Y.Low = stats(idx3,idxc)*MS2KMH - stats(idx3,14);

%colormap(hot)
hold on
fsz = 18;
cols = [1 0 0; 1 0.7961 0; 0 1 0];
colormap(cols)
t = nhist({Y.High, Y.Medium, Y.Low},'normal','samebins','binfactor',10,'color','colormap','fsize',fsz);
grid on
xlabel('Rel. Velocity (MPH)','fontsize',fsz);
ylabel('% Samples','fontsize',fsz)
set(gca,'fontsize',fsz);
pause(1)
%%
close all
%USER SPECIFIC VISUALIZATION
NSUBJECTS = length(rankres);
statsusr = cell(1,NSUBJECTS);
for i_vid = 1:length(vids);
    disp(num2str(i_vid))
    rankres = outvids(i_vid,:);
    %%
    for img_idx=0:length(rankres{1})-1
        totalrank = []; %Accumulates over subjects
        for subji=1:length(rankres)
            
            totalrank=[ rankres{subji}{img_idx+1}.currrank];
            
            %Some may have unavailable annotations. Remove them
            totalrank(totalrank<1) = nan; %-1 or less is unavailable
            totalrank(totalrank>3) = 3;
            avgrank = nanmean(totalrank,2);
            avgvote = nanmedian(totalrank,2);
            
            if(sum(avgrank<0)>0 || sum(avgrank>3)>0);
                pause
            end
            
            idxrem = ~isnan(avgrank);
            
            avgrank = avgrank(idxrem,:);
            avgvote = avgvote(idxrem,:);
            
            %Conservative!
            avgvote = ceil(avgvote);
            if(sum(avgvote ~=1 & avgvote~=2 & avgvote~=3)>0)
                pause
            end
            
            currbb = rankres{subji}{img_idx+1}.currbb(idxrem,:);
            currtrunc = rankres{subji}{img_idx+1}.currtrunc(idxrem,:);
            currocc = rankres{subji}{img_idx+1}.currocc(idxrem,:);
            currori = rankres{subji}{img_idx+1}.currori(idxrem,:);
            
            currlabels = [];
            for insti=1:length(rankres{subji}{img_idx+1}.currtypes)
                [labidx] = find(strcmp(rankres{subji}{img_idx+1}.currtypes{insti},LABELLIST)==1);
                currlabels = [currlabels;labidx];
            end
            currlabels = currlabels(idxrem,:);
            currcent = rankres{subji}{img_idx+1}.currcentroid(idxrem,:);
            %egovel = repmat(rankres{subji}{img_idx+1}.egovel,size(currcent,1),1);
            egovel = rankres{subji}{img_idx+1}.egovel(idxrem,:);
            currabsvel = rankres{subji}{img_idx+1}.currabsvel(idxrem,:);
            
            %%
            statsusr{subji} = [statsusr{subji}; [avgrank currbb currtrunc currocc currori avgvote currlabels currcent egovel currabsvel] ]; %Mag and direction. KMH
        end
    end
end

%%
%pies
for subji=1:NSUBJECTS
    subplot(3,4,subji)
    idx1 = find(statsusr{subji}(:,9)==1); %For each state...
    idx2 = find(statsusr{subji}(:,9)==2);
    idx3 = find(statsusr{subji}(:,9)==3);
  
    X = [length(idx1) length(idx2) length(idx3)];
     pie(X);
     %  htext = findobj(h,'type','text');
     % hpos =  get(htext,'position');
     % hpos = cell2mat(hpos);
     % hpos(:,1) = hpos(:,1)+0.05;
     % for ii=1:size(htext,1)
     % htext(ii).Position = hpos(ii,:);
     % end
    cols = [1 0 0; 1 0.7961 0; 0 1 0];
    colormap(cols)
  
    title(subjlist{subji});
    %legend('High','Medium','Low')
end
set(gca,'fontsize',18);
pause(1);
%%
close all

subinfolist = [];
for subj_i = 1:length(subjlist)
    subinfolist{subj_i} = getsubjinfo(subjlist{subj_i});
end

 fsz = 28; %28;  
 showbestfit = 1; subplotmode = 0; rankmodes = 1:3; 
    
    figure(1); hold on
    fig_c =1;
%For different x variables. Do next, then done. 

%first do 1-3, then 3-5. 
for xmode = 1:5 %:3 %:5 %1:3 %:5
    xmode

expvar = [];

switch xmode
    case 1
        xlab = 'experience';
        for subj_i = 1:length(subjlist)
            expvar = [expvar;subinfolist{subj_i}.dl];
        end
    case 2
        xlab = 'age';
        for subj_i = 1:length(subjlist)
            expvar = [expvar;subinfolist{subj_i}.age];
        end
    case 3
        %xlab = 'frequency (rare, occ, often)';
        xlab = 'frequency';
        for subj_i = 1:length(subjlist)
            expvar = [expvar;subinfolist{subj_i}.frq];
        end
            case 4
        xlab = 'gender';
        for subj_i = 1:length(subjlist)
            expvar = [expvar;subinfolist{subj_i}.gen];
        end
                  case 5
        xlab = 'self rate';
        for subj_i = 1:length(subjlist)
            expvar = [expvar;subinfolist{subj_i}.selfrate];
        end
end

%Is the data correct? Check carefully. 

xtsne = []; legc = 1;
for subji=1:NSUBJECTS %Legend flips them! Careful! Look at x-y
    idx1 = sum(statsusr{subji}(:,9)==1); %For each state...
    idx2 = sum(statsusr{subji}(:,9)==2);
    idx3 = sum(statsusr{subji}(:,9)==3);
    xtsne = [ xtsne ; [idx1 idx2 idx3]./(idx1+idx2+idx3) ];
    leg{legc} = subjlist{end-subji+1}; legc=legc+1;
end


for i_rank = rankmodes %DONT NEED 3, unless merging 1+2 vs 3, since they all sum to 1. 
    i_rank
    if(subplotmode);
 subplot(3,3,fig_c); 
    else
 close all
    end
 fig_c=fig_c+1;
yvar = xtsne(:,i_rank);

cols = linspecer(NSUBJECTS);
%scatter(expvar,yvar,120,cols(1:NSUBJECTS,:),'filled');

scatter(expvar,yvar,400,cols(1:NSUBJECTS,:),'filled');

[~, I] = unique([1:NSUBJECTS]);
p = findobj(gca,'Type','Patch');
warning off
%legend(p(I),leg,'location','best')
cor = corrcoef(expvar,yvar)
title([ '\rho = ' num2str(cor(1,2))],'fontsize',fsz);
grid on

if(xmode==3); set(gca,'xtick',[1 2 3]); end
if(xmode==4); set(gca,'xtick',[1 2]); end
if(xmode==5); set(gca,'xtick',[1 2 3]); xlim([1 3]); end

if(xmode==2 && i_rank ==1);
    ylabel('% Samples','fontsize',fsz)
end

ylab = []; 
if i_rank ==1;  ylab = '% High Importance';
elseif i_rank ==2; ylab = '% Moderate Importance';
elseif i_rank ==3; ylab = '% Low Importance';
end
if(showbestfit)
    
coeffs = polyfit(expvar, yvar, 1);
% Get fitted values
fittedX = linspace(min(expvar), max(expvar), 200);
fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
hold on;
plot(fittedX, fittedY, 'k-', 'LineWidth', 3);
end

xlabel(xlab,'fontsize',fsz)
ylabel(ylab,'fontsize',fsz)
set(gca,'fontsize',fsz);
axis tight
pause(1)
%export_fig(['figs/' num2str(i_rank) 'meta_' xlab '_large.pdf'],'-pdf','-transparent');
end
end