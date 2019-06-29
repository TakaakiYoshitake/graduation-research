% s“®a(t)‚ğ‹‚ß‚éŠÖ”(ƒÃ-greedy)
function [next_action]= get_action(q_table,episode,next_state,E_batt)
epsilon = 0.5*(1/(episode + 1));
x=rand;
if epsilon <= x
    M=q_table(next_state,(1:10));
    [~,I]=max(M(:));
    [~,next_action]=ind2sub(size(M),I);
    if E_batt ==0
        next_action = 1;
    end
%     [M, I]=max(q_table(:));
%     [I_row,next_action]  = ind2sub(size(q_table),I);
else next_action = randi([1,10],1,1);
        if E_batt ==0
        next_action = 1;
        end
end
end