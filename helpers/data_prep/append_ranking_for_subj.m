function [ tracklets ] = append_ranking_for_subj(tracklets, subi,subjlist,i_vid,vids,MAXFRAMES,framesexp )
currsubj = subjlist{subi};   
currname = vids{i_vid};

%READS IMPORTANCE ANNOTATIONS, latest takes precedence in the list
[ cleanedup ] = getAnnohelper( currname,['annontations/' currsubj],MAXFRAMES,framesexp );


%%
tracklets = append_ranking(tracklets,cleanedup);

end

