function [ outfix ] = lr_border( out )
%FIXES LEFTRIGHT MECHANICAL TURK LR
%SEE prepare_data.m

outfix = out;
as=[];
for i_fix = 1:length(out)
    % disp('just first frame')
    % I = imread([base_dir '/image_02/data/' sprintf('%.10d',i_fix-1) '.png']);
    %375 1242
    ImSize = [375 1242]; 
    
    if(~isempty(out{i_fix}))
        for j_fix = 1:size(out{i_fix}.currborder,1)
            %%
            
            if(out{i_fix}.currborder(j_fix,1) == 0 || out{i_fix}.currborder(j_fix,1) == -1)
            else
                %%
                bbox2 = out{i_fix}.currbb(j_fix,:);
                %convert w h to x2 y2
                bbox2(3:4) = bbox2(1:2) + bbox2(3:4)-1;
                midpt = 0.5*(bbox2(1)+bbox2(3));
                
                wid = bbox2(3)-bbox2(1);
                bbox2(3) = bbox2(1) + wid(1).*out{i_fix}.currborder(j_fix,2);
                bbox2(1) = bbox2(1) + wid(1).*out{i_fix}.currborder(j_fix,1);
                outfix{i_fix}.currbb(j_fix,:) = [bbox2(1) bbox2(2) bbox2(3)-bbox2(1)+1 bbox2(4)-bbox2(2)+1];
            end
            
            %    currbbtemp = outfix{i_fix}.currbb(j_fix,:);
            %currbbtemp(3:4) = currbbtemp(1:2) + currbbtemp(3:4)-1;
            %    as=[as; currbbtemp(:,3).*currbbtemp(:,4) ];
            %Sometimes outside of the image?
            %ImSize(1);
            
            %Sometimes outside the image on the bottom.
            tempy2 = outfix{i_fix}.currbb(j_fix,2)+outfix{i_fix}.currbb(j_fix,4)-1;
            tempy2 = tempy2+min(0,ImSize(1)-tempy2+1); %either don't add, or if negative, add that amount
            outfix{i_fix}.currbb(j_fix,4) = tempy2-outfix{i_fix}.currbb(j_fix,2);
            
            %Same for left/right boundaries. this has been resolved in
            %tracking annotations, but not in raw. do next.
            tempx2 = outfix{i_fix}.currbb(j_fix,1)+outfix{i_fix}.currbb(j_fix,3)-1;
            tempx2 = tempx2+min(0,ImSize(2)-tempx2+1); %either don't add, or if negative, add that amount
            outfix{i_fix}.currbb(j_fix,3) = tempx2-outfix{i_fix}.currbb(j_fix,1);
            
            %And on the right. careful! Can't just change! if -3,
            %change to 1 and remove 4.
            tempx1 = outfix{i_fix}.currbb(j_fix,1);
            if(tempx1<1)
                tempw1 = outfix{i_fix}.currbb(j_fix,3)-abs(tempx1);
                tempx1 = 1;
                outfix{i_fix}.currbb(j_fix,1) = tempx1;
            end
            
            
        end
    end
end

end

