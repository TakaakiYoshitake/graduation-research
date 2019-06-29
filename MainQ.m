% clear
% clc
%% パラメータ設計
B_full = 20000 ;%バッテリー容量
harvest_full = 2500; % 発電容量
e_maxh = 3000 ;%最大発電量
e_minh = 0   ;%最小発電量
E_harvest_table = xlsread('datafile15'); %excelファイルから全天日射量読み込み
q_table = rand(1000,10); %0～1の乱数がQtabelの初期値
% q_table = randi(100,1000,10);
max_number_of_steps = 261;%1試行のステップ数
num_episodes =336;%総試行回数)
bin=85;
batt_bins=bins(0,B_full,bin) ;%離散値となる等差数列ベクトル作成
Ematrixa = zeros(1,max_number_of_steps);
harvest_bins=bins(0,harvest_full,5);
Ematrixb = zeros(1,max_number_of_steps);
Ematrixc = zeros(1,max_number_of_steps);
Ematrixd = zeros(1,max_number_of_steps);
harvest = zeros(1,max_number_of_steps);
nodematrix=zeros(1,max_number_of_steps);
actionmatrix=zeros(1,max_number_of_steps);
epoch = zeros(1,max_number_of_steps);
q=zeros(1,max_number_of_steps);
aqa=zeros(1,max_number_of_steps * num_episodes);
aqb=zeros(1,max_number_of_steps * num_episodes);
aqc=zeros(1,max_number_of_steps * num_episodes);
aqd=zeros(1,max_number_of_steps * num_episodes);
%% メイン関数
%試行回数分繰り返す
for episode = 1:1:num_episodes, 
%     q(1,episode)=q_table(1,1)
    % 環境の初期化
    E_batt = randi([0 20000],1,1);
    S_batt = digitize(batt_bins,bin,E_batt,B_full);
    E_harvest = E_harvest_table((episode-1)*max_number_of_steps + 1,1) *1000*2.25*0.85/3.6; %全天日射量を発電量に換算
    S_harvest = digitize(harvest_bins,5,E_harvest,harvest_full); %発電量を離散値に変換
    state  = S_batt * 5 - ( 5 - S_harvest); %Qテーブルの何行目か計算
    [M, I]=max(q_table(:)); %q_table(:)は，qテーブルを１列に変換，Mはその中の最大値，Iは一列にしたとき何行目に最大値があるかを表す
    [I_row,action]  = ind2sub(size(q_table),I); %[I_row,action]はq_tableの最大要素に対応する行と列を表す．つまり最大要素のある列がそのまま行動となる．
%        if episode==1
%            E_batt
%        end

    %1試行のループ
    for j = 1:1:max_number_of_steps, 
%        if episode==1
%            E_batt
%        end
    E_harvest = E_harvest_table((episode-1)*max_number_of_steps + j,1)*1000*2.25*0.85/3.6; %全天日射量を発電量に換算
    S_harvest = digitize(harvest_bins,5,E_harvest,harvest_full);%離散化
    E_node = 50 * action ; %デューティーサイクルに応じたエネルギー消費
%     if episode==1
%         E_batt
%         E_harvest
%         action
%         E_node
%     end
    E_waste = E_batt + E_harvest -E_node -B_full;
    if E_waste < 0;
        E_wasete=0;
    end
    E_batt = E_batt + E_harvest - E_node ; %バッテリー残量更新
    if E_batt > 20000
       E_batt = 20000;
    end
    if E_batt <0
           E_batt = 0;
    end
    %最後のエピソードの全ステップ（学習結果）を描写するために各値を格納
    if episode == num_episodes  
     harvest(1,j)=E_harvest;   
     Ematrixd(1,j)=E_batt*100/20000;
     epoch(1,j)=j;
    end
%     if episode == 1  
%      Ematrixa(1,j)=E_batt;
%      epoch(1,j)=j;
%     end
%     if episode == 46
%      Ematrixb(1,j)=E_batt;
%      epoch(1,j)=j;
%     end

%最後のエピソードの全ステップ（学習結果）を描写するために各値を格納
    if episode == num_episodes
     nodematrix(1,j)=E_node;
     epoch(1,j)=j;
    end
        S_batt = digitize(batt_bins,bin,E_batt,B_full); %離散化
        S_batt_percent = S_batt/bin*100;
    reward=5.82516339914132*10^(-9)*(S_batt_percent)^6-1.52479260947212*10^(-6)*S_batt_percent^5+0.000134280103083917*S_batt_percent^4-0.00491340583545252*S_batt_percent^3+0.0939121338174118*S_batt_percent^2- 0.305120664917922*S_batt_percent- 0.111476716752804;
    next_state  = S_batt * 5 - ( 5 - S_harvest); %次の状態
%         if episode == 1
%         E_batt
%         E_harvest
%         E_node
%         end

if episode == num_episodes
    reward;
end
    
    q_table = update_Qtable(q_table, state, action, reward, next_state,episode,j,max_number_of_steps,num_episodes);%Q_tableの更新
    action = get_action(q_table,episode,next_state,E_batt);
%     aqa(1,(episode-1)*max_number_of_steps + j)=q_table(1,1);
%     aqb(1,(episode-1)*max_number_of_steps + j)=q_table(1,5);
%     aqc(1,(episode-1)*max_number_of_steps + j)=q_table(1,10);
%     aqd(1,(episode-1)*max_number_of_steps + j)=(episode-1)*max_number_of_steps + j;
%     if episode ==num_episodes
%             actionmatrix(1,j)=action * 10;
%     end
    state = next_state;
    end 
a=E_harvest - E_node;
    
end
q_table;

% figure
% subplot(2,2,1)
%      plot(epoch,harvest,'r-.')
%      axis([1 max_number_of_steps 0 2500])
%      xlabel('エポック[t]')
%      ylabel('発電量')
%      title('発電量推移')
%      grid
%      subplot(2,2,2)
%      plot(epoch,actionmatrix,'r-.')
%      axis([1 max_number_of_steps 10 100])
%      xlabel('エポック[t]')
%      ylabel('デューティー比')
%      title('デューティー比推移')
%      grid
%  
%      subplot(2,2,3)
%      plot(epoch,nodematrix,'r-.')
%      axis([1 max_number_of_steps 50 500 ])
%      xlabel('エポック[t]')
%      ylabel('ノード消費量')
%      title('ノード消費量推移')
%      grid
%      subplot(2,2,4)
%      plot(epoch,Ematrixd,'r-.')
%      axis([1 max_number_of_steps 0 100])
%      xlabel('エポック[t]')
%      ylabel('エネルギー残量(episode48)[%]')
%      title('バッテリー残量推移')
%      grid
% figure
% plot(aqd,aqa,'r-',aqd,aqb,'b-',aqd,aqc,'k-')
% axis([1 max_number_of_steps * num_episodes 0 1 ])
%      xlabel('試行回数')
%      ylabel('Q値')
%      grid