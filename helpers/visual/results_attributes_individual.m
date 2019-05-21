function results_attributes_individual(evalmode,evalRes)
%evalmode 0 class, 1 regression.  i_user = 1. obj_i = 1:4. ci = 1:7. ft_i

%%
ftlabels =  {[1 2  3      4   5 6   7    8   9     10    11     12     13],...
    'h ar trunc  occ cent  dist ori vmag  vori  evmag  evori  id'};

%%
%Extract to table. choose best perf. 
restable = [];
for obj_i = 1:size(evalRes,3);
for ft_i=1:size(evalRes,1);
    alltempres = [];
    for i_cval = 1:size(evalRes,2)
        tempres = evalRes{ft_i,i_cval,obj_i,1,1}.mres;
        alltempres=[alltempres  tempres];
    end
    currmax = max(alltempres);
    restable(ft_i,obj_i) = currmax;
end
end
%%
close all
A = restable';
bar(100*A')
colormap(linspecer(4))
xlim([0 13.7])
fsz = 25;
ylabel('mAP','fontsize',fsz);
set(gca,'fontsize',fsz);

xlabels = {'height', 'aspect', 'trunc', 'occ','x' ,'z','dist','ori','|V|','\angle V','ego |V|','ego \angle V','comb'};

set(gca, 'XTick', 1:size(A,2), 'XTickLabel',xlabels,'fontsize',fsz)
rotateXLabelsnew(gca,90)
legend({'Vehicle','Pedestrian','Cyclist','All'},'fontsize',fsz,'location','northwest','orientation','horizontal');
%set(gca, 'YTick', 0:30:100);
ylim([0 55]);
grid on

end