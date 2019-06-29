% s“®a(t)‚ğ‹‚ß‚éŠÖ”(greedy)
function [next_action]= get_Agreedy(q_table,next_state,E_batt)
    M=q_table(next_state,(1:10));
    [~,I]=max(M(:));
    [~,next_action]=ind2sub(size(M),I);
        if E_batt ==0
        next_action = 1;
    end
end