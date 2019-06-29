
% Qテーブルを更新する関数
function q_table = update_Qtable(q_table, state, action, reward, next_state,A,B,C,D)
gammma = 0.99;
alpha  = 0.5 - 0.5*A*B/(C*D);
next_Max_Q=max(q_table(next_state,:)); % 次の状態を仮定し，さらに次の行動で最大の報酬を得られるQを選ぶ
q_table(state,action) = (1-alpha)*q_table(state, action) + alpha * (reward + gammma * next_Max_Q);