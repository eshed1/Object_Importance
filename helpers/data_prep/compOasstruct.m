function out = compOasstruct(in1,in2)
%Given array or two instances
out = [];
for i_1 = 1:length(in1)
    for j_1 = 1:length(in2)
    out(i_1,j_1) = bbGt('compOas',...
        [in1(i_1).x in1(i_1).y in1(i_1).w in1(i_1).h],...
        [in2(j_1).x in2(j_1).y in2(j_1).w in2(j_1).h]);
    end
end
end