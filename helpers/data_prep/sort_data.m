%This function just concatentes and sorts labels by order...
function [l_tr_s,d_tr_s,l_te,d_te] = sort_data(prm,allfts,alllabs)
tr_vidsi = prm.tr_vidsi;
te_vidsi = prm.te_vidsi;

d_tr = [allfts(tr_vidsi)]; d_tr = [d_tr{:}]; d_tr = cat(1,d_tr{:});
l_tr = [alllabs(tr_vidsi)]; l_tr = [l_tr{:}]; l_tr = cat(1,l_tr{:});

d_te = [allfts(te_vidsi)]; d_te = [d_te{:}]; d_te = cat(1,d_te{:});
l_te = [alllabs(te_vidsi)]; l_te = [l_te{:}]; l_te = cat(1,l_te{:});

idxtorem = l_tr(:,1)==-2;  %Removes ignored boxes. not for training. heavy occ etc.
l_tr(idxtorem,:) = [];
d_tr(idxtorem,:) = [];

%Order by 1 2 3 4.
labtypes = unique(l_tr(:,1)); d_tr_s = []; l_tr_s=[]; %Sort
for i_l = 1:length(labtypes)
    idxs = find(l_tr(:,1)==labtypes(i_l));
    d_tr_s = [d_tr_s;d_tr(idxs,:)];
    l_tr_s = [l_tr_s;l_tr(idxs,:)];
end

idxnan = find(isnan(l_tr_s(:,10)));
d_tr_s(idxnan,:) = [];
l_tr_s(idxnan,:) = [];

idxnan = find(isnan(l_te(:,10)));
d_te(idxnan,:) = [];
l_te(idxnan,:) = [];

%Sanity checks
if(sum(sum(isnan(l_tr_s)))>0); pause; end
if(sum(sum(isnan(l_te)))>0); pause; end

%Remove ignore
iglist = []; iglist = l_tr_s(:,1)==-1; l_tr_s(iglist,:) = []; d_tr_s(iglist,:) = [];
iglist = []; iglist = l_te(:,1)==-1; l_te(iglist,:) = []; d_te(iglist,:) = [];



end