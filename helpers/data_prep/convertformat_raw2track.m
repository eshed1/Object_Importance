function [ tracklets ] = convertformat_raw2track( outfix )
%TAKES IN RAW format (per frame) and outputs tracklet (per ID)

tmp=[outfix{:}];
maxids = max(cat(1,tmp.ids));

tracklets = cell(1,maxids);

for itt = 1:length(outfix)
    if(~isempty(outfix{itt}))
        for jtt=1:length(outfix{itt}.ids)
            
            tempstruct = struct;
            tempstruct.frame = itt-1;
            tempstruct.id = outfix{itt}.ids(jtt); %For consistency, to be 1-based. already 1 based
            tempstruct.type = outfix{itt}.currtypes{jtt};
            tempstruct.truncation = outfix{itt}.currtrunc(jtt);
            tempstruct.occlusion = outfix{itt}.currocc(jtt);
            tempstruct.ry = outfix{itt}.currori(jtt,1); 
            tempstruct.alpha = outfix{itt}.currori(jtt,2); %ry and alpha
            tempstruct.x1 = outfix{itt}.currbb(jtt,1);
            tempstruct.y1 = outfix{itt}.currbb(jtt,2);
            tempstruct.x2 = outfix{itt}.currbb(jtt,1)+outfix{itt}.currbb(jtt,3);
            tempstruct.y2 = outfix{itt}.currbb(jtt,2)+outfix{itt}.currbb(jtt,4);
            tempstruct.t  = outfix{itt}.currcentroid(jtt,:);
            tempstruct.egovel = outfix{itt}.egovel;
            tempstruct.currabsvel =outfix{itt}.currabsvel(jtt,:);
            
            currID = tempstruct.id;
            %%
            %try
                tracklets{currID} = [tracklets{currID};tempstruct];
            %catch err
            %    tracklets{currID} = tempstruct;
            %end
        end
    end
    
end

end

