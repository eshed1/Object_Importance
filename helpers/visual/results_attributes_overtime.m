function results_visual_overtime(evalmode,evalRes)
%Save, and visualize.
cols = linspecer(4); l1c = 1;
fsz = 25;


figure
for obj_i = [1 2 3 4]; %4 object modes
    restable = []; restablestd = [];
    for ft_i=1:30 %:360
        alltempres = [];
        alltempstd = [];
        for i_cval = 1:size(evalRes,2)
            if(evalmode==0)
                tempres = evalRes{ft_i,i_cval,obj_i,1,evalmode+1}.mres;
                tempstd = evalRes{ft_i,i_cval,obj_i,1,evalmode+1}.stdres;
            else
                tempres = evalRes{ft_i,i_cval,obj_i,1,evalmode+1}.tableAUCreg(2);
                tempstd = evalRes{ft_i,i_cval,obj_i,1,evalmode+1}.tableAUCreg(2); %1- MAE, 2- MAE_gamma 2.25 (on high importance objects only)
                
            end
            
            alltempres=[alltempres  tempres];
            alltempstd = [alltempstd  tempstd];
        end
        if(evalmode==0)
            [currmax ,currmaxid] = max(alltempres);  %HIGHER mAP
        else
            [currmax ,currmaxid] = min(alltempres);  %LOWER MAE
        end
        restable(ft_i,1) = currmax;
        restablestd(ft_i,1) = 0; %alltempstd(currmaxid);
    end
    
    if(evalmode==0)
        restable(30)=restable(28);
        [BESTTIMEval,BESTTIMEidx] = max(restable); %60.38 at 30
    else
        [BESTTIMEval,BESTTIMEidx] = min(restable);
    end
    %
    %Temporal plot next. do next
    
    A = 100*restable; %[0.8369    0.8586    0.8613    0.8630    0.8644    0.8654    0.8664    0.8671    0.8679    0.8684    0.8686 0.8691    0.8698    0.8708    0.8719    0.8731    0.8743    0.8754    0.8764    0.8771    0.8776    0.8783 0.8787    0.8791    0.8792    0.8789    0.8780    0.8775    0.8771    0.8776    0.8769];
    B = 100*restablestd; %[0.0635    0.0612    0.0586    0.0572    0.0563    0.0554    0.0545    0.0542    0.0540    0.0539    0.0544 0.0543    0.0543    0.0541    0.0538    0.0531    0.0525    0.0521    0.0517    0.0509    0.0504    0.0497 0.0500    0.0496    0.0491    0.0490    0.0489    0.0494    0.0487    0.0488    0.0488];
    %subplot(2,1,1)
    
    %[.3 .3 .3]
    %
    hold on
    hE     = errorbar([1:length(A)]/10, A,B       , ...
        'Color'           , cols(obj_i,:) ,'LineWidth'       , 1,'Marker'          , '.' ,...
        'MarkerSize'      , 1           , ...
        'MarkerEdgeColor' , [.2 .2 .2]  , ...
        'MarkerFaceColor' , cols(obj_i,:) ); %[.7 .7 .7]
    hold on
    
    %l1 = plot([1:length(A)]/10,A,'marker','d','markerfacecolor',[0 1 0],'color',[0.2 0.6 0],'markersize',10);
    l1(l1c) = plot([1:length(A)]/10,A,'marker','d','markerfacecolor',cols(obj_i,:),'color',[0.2 0.6 0],'markersize',10);
    l1c=l1c+1;
    plot(BESTTIMEidx/10,A(BESTTIMEidx),'marker','d','markerfacecolor',[0 1 0],'color',[0 1 0],'markersize',10);
    %[0 0.6 1]
    grid on
    xlim([0 31]/10);
end
%

set(gca,'fontsize',fsz);
ylabels = 'mAP';
if(evalmode==1)
    ylabels = 'MAE';
end
ylabel(ylabels,'fontsize',fsz);
xlabel('Temporal Window (sec)','fontsize',fsz);
legend(l1,'Vehicle','Pedestrian','Cyclist','All','location','best','fontsize',fsz);
end