% clear
% clc
%% �p�����[�^�݌v
B_full = 20000 ;%�o�b�e���[�e��
harvest_full = 2500; % ���d�e��
e_maxh = 3000 ;%�ő唭�d��
e_minh = 0   ;%�ŏ����d��
E_harvest_table = xlsread('datafile15'); %excel�t�@�C������S�V���˗ʓǂݍ���
q_table = rand(1000,10); %0�`1�̗�����Qtabel�̏����l
% q_table = randi(100,1000,10);
max_number_of_steps = 261;%1���s�̃X�e�b�v��
num_episodes =336;%�����s��)
bin=85;
batt_bins=bins(0,B_full,bin) ;%���U�l�ƂȂ铙������x�N�g���쐬
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
%% ���C���֐�
%���s�񐔕��J��Ԃ�
for episode = 1:1:num_episodes, 
%     q(1,episode)=q_table(1,1)
    % ���̏�����
    E_batt = randi([0 20000],1,1);
    S_batt = digitize(batt_bins,bin,E_batt,B_full);
    E_harvest = E_harvest_table((episode-1)*max_number_of_steps + 1,1) *1000*2.25*0.85/3.6; %�S�V���˗ʂ𔭓d�ʂɊ��Z
    S_harvest = digitize(harvest_bins,5,E_harvest,harvest_full); %���d�ʂ𗣎U�l�ɕϊ�
    state  = S_batt * 5 - ( 5 - S_harvest); %Q�e�[�u���̉��s�ڂ��v�Z
    [M, I]=max(q_table(:)); %q_table(:)�́Cq�e�[�u�����P��ɕϊ��CM�͂��̒��̍ő�l�CI�͈��ɂ����Ƃ����s�ڂɍő�l�����邩��\��
    [I_row,action]  = ind2sub(size(q_table),I); %[I_row,action]��q_table�̍ő�v�f�ɑΉ�����s�Ɨ��\���D�܂�ő�v�f�̂���񂪂��̂܂܍s���ƂȂ�D
%        if episode==1
%            E_batt
%        end

    %1���s�̃��[�v
    for j = 1:1:max_number_of_steps, 
%        if episode==1
%            E_batt
%        end
    E_harvest = E_harvest_table((episode-1)*max_number_of_steps + j,1)*1000*2.25*0.85/3.6; %�S�V���˗ʂ𔭓d�ʂɊ��Z
    S_harvest = digitize(harvest_bins,5,E_harvest,harvest_full);%���U��
    E_node = 50 * action ; %�f���[�e�B�[�T�C�N���ɉ������G�l���M�[����
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
    E_batt = E_batt + E_harvest - E_node ; %�o�b�e���[�c�ʍX�V
    if E_batt > 20000
       E_batt = 20000;
    end
    if E_batt <0
           E_batt = 0;
    end
    %�Ō�̃G�s�\�[�h�̑S�X�e�b�v�i�w�K���ʁj��`�ʂ��邽�߂Ɋe�l���i�[
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

%�Ō�̃G�s�\�[�h�̑S�X�e�b�v�i�w�K���ʁj��`�ʂ��邽�߂Ɋe�l���i�[
    if episode == num_episodes
     nodematrix(1,j)=E_node;
     epoch(1,j)=j;
    end
        S_batt = digitize(batt_bins,bin,E_batt,B_full); %���U��
        S_batt_percent = S_batt/bin*100;
    reward=5.82516339914132*10^(-9)*(S_batt_percent)^6-1.52479260947212*10^(-6)*S_batt_percent^5+0.000134280103083917*S_batt_percent^4-0.00491340583545252*S_batt_percent^3+0.0939121338174118*S_batt_percent^2- 0.305120664917922*S_batt_percent- 0.111476716752804;
    next_state  = S_batt * 5 - ( 5 - S_harvest); %���̏��
%         if episode == 1
%         E_batt
%         E_harvest
%         E_node
%         end

if episode == num_episodes
    reward;
end
    
    q_table = update_Qtable(q_table, state, action, reward, next_state,episode,j,max_number_of_steps,num_episodes);%Q_table�̍X�V
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
%      xlabel('�G�|�b�N[t]')
%      ylabel('���d��')
%      title('���d�ʐ���')
%      grid
%      subplot(2,2,2)
%      plot(epoch,actionmatrix,'r-.')
%      axis([1 max_number_of_steps 10 100])
%      xlabel('�G�|�b�N[t]')
%      ylabel('�f���[�e�B�[��')
%      title('�f���[�e�B�[�䐄��')
%      grid
%  
%      subplot(2,2,3)
%      plot(epoch,nodematrix,'r-.')
%      axis([1 max_number_of_steps 50 500 ])
%      xlabel('�G�|�b�N[t]')
%      ylabel('�m�[�h�����')
%      title('�m�[�h����ʐ���')
%      grid
%      subplot(2,2,4)
%      plot(epoch,Ematrixd,'r-.')
%      axis([1 max_number_of_steps 0 100])
%      xlabel('�G�|�b�N[t]')
%      ylabel('�G�l���M�[�c��(episode48)[%]')
%      title('�o�b�e���[�c�ʐ���')
%      grid
% figure
% plot(aqd,aqa,'r-',aqd,aqb,'b-',aqd,aqc,'k-')
% axis([1 max_number_of_steps * num_episodes 0 1 ])
%      xlabel('���s��')
%      ylabel('Q�l')
%      grid