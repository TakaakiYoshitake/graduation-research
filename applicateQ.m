%% パラメータ設計
B_full = 20000 ;%バッテリー容量
harvest_full = 2500; % 発電容量
e_maxh = 3000 ;%最大発電量
e_minh = 0   ;%最小発電量
E_harvest_table = xlsread('new2017-2018data'); %excelファイルから全天日射量読み込み
Q_table=q_table;
max_number_of_steps =8700 ;%1試行のステップ数
bin=85;
batt_bins=bins(0,B_full,bin);%離散値となる等差数列ベクトル作成
harvest_bins=bins(0,harvest_full,5);
Ematrixa = zeros(1,max_number_of_steps);
Emaharvest_bins=bins(0,harvest_full,5);
trixb = zeros(1,max_number_of_steps);
Ematrixc = zeros(1,max_number_of_steps);
Ematrixd = zeros(1,max_number_of_steps);
harvest = zeros(1,max_number_of_steps);
nodematrix=zeros(1,max_number_of_steps);
actionmatrix=zeros(1,max_number_of_steps);
epoch = zeros(1,max_number_of_steps);
sum=0;
average=zeros(1,12);
mounth=1:12;
%% メイン関数
% 環境の初期化
    E_batt = 10000;
    S_batt = digitize(batt_bins,bin,E_batt,B_full);
    
    for j = 1:1:max_number_of_steps,
    E_harvest = E_harvest_table(j+1,1) *1000*2.25*0.85/3.6; %全天日射量を発電量に換算
    S_harvest = digitize(harvest_bins,5,E_harvest,harvest_full); %発電量を離散値に変換
    state  = S_batt * 5 - ( 5 - S_harvest); %Qテーブルの何行目か計算
    M=q_table(state,(1:10));
    [~, I]=max(M(:)); %q_table(:)は，qテーブルを１列に変換，Mはその中の最大値，Iは一列にしたとき何行目に最大値があるかを表す
    [~,action]  = ind2sub(size(M),I); %[I_row,action]はq_tableの最大要素に対応する行と列を表す．つまり最大要素のある列がそのまま行動となる．
    E_node = 50 * action ; %デューティーサイクルに応じたエネルギー消費
     E_batt = E_batt + E_harvest - E_node ; %バッテリー残量更新
    if E_batt > 20000
       E_batt = 20000;
    end
    if E_batt <0
           E_batt = 0;
    end 
     harvest(1,j)=E_harvest*100/2500;   
     Ematrixd(1,j)=E_batt*100/20000;
     epoch(1,j)=j;
     nodematrix(1,j)=E_node;
     S_batt = digitize(batt_bins,bin,E_batt,B_full); %離散化
    next_state  = S_batt * 5 - ( 5 - S_harvest); %次の状態

    
    action = get_Agreedy(q_table,next_state,E_batt);
    actionmatrix(1,j)=action * 10;
    
    state=next_state;
    end
%     for a=1:1:12
%         sum=0;
%     for b=1:1:720
%         sum = sum + actionmatrix(1,720*(a-1)+b);
%     end
%     average(1,a)=sum/720;
%     end
%      figure
%     subplot(2,2,1)
%      plot(epoch,harvest,'k-')
%      axis([1 max_number_of_steps 0 100])
%      xlabel('時間[t]')
%      ylabel('発電量')
%      title('発電量推移')
%      grid
%      subplot(2,2,2)
%      plot(epoch,actionmatrix,'k-')
%      axis([1 max_number_of_steps 10 100])
%      xlabel('時間[t]')
%      ylabel('デューティー比[%]')
%      title('デューティー比推移')
%      grid
%  
%      subplot(2,2,3)
%      plot(epoch,nodematrix,'k-')
%      axis([1 max_number_of_steps 50 500 ])
%      xlabel('時間[t]')
%      ylabel('ノード消費量')
%      title('ノード消費量推移')
%      grid
%      subplot(2,2,4)
%      plot(epoch,Ematrixd,'k-')
%      axis([1 max_number_of_steps 0 100])
%      xlabel('時間[t]')
%      ylabel('バッテリ残量[%]')
%      title('バッテリー残量推移')
%      grid
%      
     figure
     plot(epoch,actionmatrix,'k-',epoch,Ematrixd,'r-',epoch,harvest,'b-.')
     axis([0 1000 0 100])
     legend('デューティ比','バッテリ残量','発電量')
     xlabel('時間[t]')
     ylabel('割合[%]')
     title('デューティ比とバッテリ残量の推移')
%      figure
%      plot(epoch,Ematrixd,'r-')
%      axis([0 1000 0 100])
%      legend('バッテリ残量')
%      xlabel('時間[t]')
%      ylabel('割合[%]')
%      title('バッテリ残量の推移')
% 
%      figure
%      bar(AVE)
%      axis([0 13 10 85])
%      xlabel('月')
%      ylabel('平均デューティ比')
%      title('月別平均デューティ比')
%      grid