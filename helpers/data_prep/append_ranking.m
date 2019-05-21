function [ tracklets ] = append_ranking( tracklets,cleanedup)
%Adds interpolated rankings to tracklets. see prepare_data.m
%tracklets are cells
%cleanedup is importance annotation reading, outputted by getAnnohelper
%Doesn't use ids explicitly, but assumes order in tracklets is by id (i.e.
%id=1 in first one, and so on... 0-based has been added 1 to). 
%%
for i_t = 1:length(tracklets)
    if(~isempty(tracklets{i_t}))
    %Prepare for interpolation
    currframes = double([cat(1,tracklets{i_t}.frame)']);
    
    currID = i_t;
    currarray = [];
    
    for l1 = 1:length(cleanedup) %Increments over frames
        for j1 = 1:length(cleanedup{l1}) %Increments over instances.
            testID = cleanedup{l1}(j1).id;
            testRank = cleanedup{l1}(j1).rank;
            if(testID==currID)
                %Curr record is added...
                currarray = [currarray;l1-1 testRank]; %Frame rank. Frames are 0-based
            else
                
            end
        end
    end
    
    %%
    
    %Interpolate up, without changing annotations. 
    if(size(currarray,1)==1)
        %Can't interpolate with one dot. Want just to make it constant
        outinterp2=[currframes' currarray(1,2)*ones(length(currframes),1)];
    elseif(size(currarray,1)<1)
        %Sometimes, objects were not shown at all (but exist in
        %tracklets. such as always truncated. we ignore these.
        %outinterp2=[currframes' -1*ones(length(currframes),1)];
        %disp('NaN!');
        outinterp2=[currframes' NaN(length(currframes),1)];
    else
        outinterp = interp1(currarray(:,1),currarray(:,2),currframes,'pchip'); %same as cubic
        outinterp2=[currframes' round(outinterp)']; %Looks good! Next, organize and visualize.
    end
    
    %Quantize into 1-3. 
    for tt = 1:length(tracklets{i_t})
        %Sanity
        if(outinterp2(tt,2)>3); outinterp2(tt,2) = 3; end
        if(outinterp2(tt,2)<1); outinterp2(tt,2) = 1; end
        
        
        tracklets{i_t}(tt).ranks =outinterp2(tt,2);
    end
end
end
end

