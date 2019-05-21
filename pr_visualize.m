%Visualizes PR curves for different methods

diffmodes  = {'M_{v}(o)','M_{v}(os)','M_{v}(ost)','M_{a}(s)','M_{a}(st)'};

%diffmodes  = {'VGG','VGG+s','VGG+s+t','Attributes','Attributes+t'};
%diffmodes  = {'M_{visual}(o)','M_{visual}(o+s)','M_{visual}(o+s+t)','M_{attributes}(s)','M_{attributes}(s+t)'};
%visual model (object-level features)
%visual model (object+spatial context)
%visual model (object+spatial+temporal context)
%attributes model
%attributes model (with temporal features)

cols = linspecer(10,'sequential');
cols = cols([1:2:end],:);
fsz = 15; %25
lw = 3;
leg = [];
NDS = 50;

pr_data = load('pr_curves.mat');
pr_data = pr_data.plotsarray;
%5 x 3 x 4
%Number of models X number of importance levels X number of object modes
%where number of object modes is 
objmodes =  {'veh','ped','cyc','all'};
impmodes = {'high','moderate','low'};

for imp_lvl = 1:3 
    for obj_i = 1:4
        
        close all
        
        i_model = 1;
        sx = pr_data{i_model,imp_lvl,obj_i}.sx; sy = pr_data{i_model,imp_lvl,obj_i}.sy; auc = pr_data{i_model,imp_lvl,obj_i}.auc;
        
        plot(sx,sy,'color',cols(1,:),'linewidth',lw); hold on; grid on;
        leg{i_model} =  [diffmodes{i_model} ' (' sprintf('%.2f',auc) ')'];
        
        i_model = 2;
        sx = pr_data{i_model,imp_lvl,obj_i}.sx; sy = pr_data{i_model,imp_lvl,obj_i}.sy; auc = pr_data{i_model,imp_lvl,obj_i}.auc;
        plotsarray{i_model,imp_lvl,obj_i} = res_struct;

        plot(sx,sy,'color',cols(2,:),'linewidth',lw); hold on; grid on;
        leg{i_model} =  [diffmodes{i_model} ' (' sprintf('%.2f',auc) ')'];
        
        i_model = 3;
        sx = pr_data{i_model,imp_lvl,obj_i}.sx; sy = pr_data{i_model,imp_lvl,obj_i}.sy; auc = pr_data{i_model,imp_lvl,obj_i}.auc;
        % dsf = round(linspace(1,length(sx),NDS));
        dsf = round(logspace(log10(1),log10(length(sx)),NDS));
        
        plot(sx(dsf),sy(dsf),'color',cols(2,:),'linewidth',lw,'linestyle',':','marker','d'); hold on; grid on;
        leg{i_model} =  [diffmodes{i_model} ' (' sprintf('%.2f',auc) ')'];
        
        i_model = 4;
        sx = pr_data{i_model,imp_lvl,obj_i}.sx; sy = pr_data{i_model,imp_lvl,obj_i}.sy; auc = pr_data{i_model,imp_lvl,obj_i}.auc;
        plot(sx,sy,'color',cols(5,:),'linewidth',lw); hold on; grid on;
        leg{i_model} =  [diffmodes{i_model} ' (' sprintf('%.2f',auc) ')'];
        
        i_model = 5;
        sx = pr_data{i_model,imp_lvl,obj_i}.sx; sy = pr_data{i_model,imp_lvl,obj_i}.sy; auc = pr_data{i_model,imp_lvl,obj_i}.auc;
        
        plot(sx(dsf),sy(dsf),'color',cols(5,:),'linewidth',lw,'linestyle',':','marker','d'); hold on; grid on;
        leg{i_model} =  [diffmodes{i_model} ' (' sprintf('%.2f',auc) ')'];
        
        
        
        set(gca,'xtick',[0:0.2:1]);
        % plot([0 1],[0 1],'--k','linewidth',4);
        if(imp_lvl==3)
            legend(leg,'fontsize',fsz,'location','sw');
        else
            legend(leg,'fontsize',fsz,'location','ne');
        end
        xlabel('Recall','fontsize',fsz); ylabel('Precision','fontsize',fsz);
        set(gca,'fontsize',fsz);
        title([objmodes{obj_i} ', importance level: ' impmodes{imp_lvl}] )
        %ylim([0 1])
         pause
        % export_fig(['newscripts/figures/prcur/classroc_obj' num2str(obj_i) '_imp' num2str(imp_lvl)  'fsz' num2str(fsz) '.pdf'],'-pdf','-transparent');
    end
end