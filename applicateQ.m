%% �p�����[�^�݌v
B_full = 20000 ;%�o�b�e���[�e��
harvest_full = 2500; % ���d�e��
e_maxh = 3000 ;%�ő唭�d��
e_minh = 0   ;%�ŏ����d��
E_harvest_table = xlsread('new2017-2018data'); %excel�t�@�C������S�V���˗ʓǂݍ���
Q_table=q_table;
max_number_of_steps =8700 ;%1���s�̃X�e�b�v��
bin=85;
batt_bins=bins(0,B_full,bin);%���U�l�ƂȂ铙������x�N�g���쐬
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
%% ���C���֐�
% ���̏�����
    E_batt = 10000;
    S_batt = digitize(batt_bins,bin,E_batt,B_full);
    
    for j = 1:1:max_number_of_steps,
    E_harvest = E_harvest_table(j+1,1) *1000*2.25*0.85/3.6; %�S�V���˗ʂ𔭓d�ʂɊ��Z
    S_harvest = digitize(harvest_bins,5,E_harvest,harvest_full); %���d�ʂ𗣎U�l�ɕϊ�
    state  = S_batt * 5 - ( 5 - S_harvest); %Q�e�[�u���̉��s�ڂ��v�Z
    M=q_table(state,(1:10));
    [~, I]=max(M(:)); %q_table(:)�́Cq�e�[�u�����P��ɕϊ��CM�͂��̒��̍ő�l�CI�͈��ɂ����Ƃ����s�ڂɍő�l�����邩��\��
    [~,action]  = ind2sub(size(M),I); %[I_row,action]��q_table�̍ő�v�f�ɑΉ�����s�Ɨ��\���D�܂�ő�v�f�̂���񂪂��̂܂܍s���ƂȂ�D
    E_node = 50 * action ; %�f���[�e�B�[�T�C�N���ɉ������G�l���M�[����
     E_batt = E_batt + E_harvest - E_node ; %�o�b�e���[�c�ʍX�V
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
     S_batt = digitize(batt_bins,bin,E_batt,B_full); %���U��
    next_state  = S_batt * 5 - ( 5 - S_harvest); %���̏��

    
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
%      xlabel('����[t]')
%      ylabel('���d��')
%      title('���d�ʐ���')
%      grid
%      subplot(2,2,2)
%      plot(epoch,actionmatrix,'k-')
%      axis([1 max_number_of_steps 10 100])
%      xlabel('����[t]')
%      ylabel('�f���[�e�B�[��[%]')
%      title('�f���[�e�B�[�䐄��')
%      grid
%  
%      subplot(2,2,3)
%      plot(epoch,nodematrix,'k-')
%      axis([1 max_number_of_steps 50 500 ])
%      xlabel('����[t]')
%      ylabel('�m�[�h�����')
%      title('�m�[�h����ʐ���')
%      grid
%      subplot(2,2,4)
%      plot(epoch,Ematrixd,'k-')
%      axis([1 max_number_of_steps 0 100])
%      xlabel('����[t]')
%      ylabel('�o�b�e���c��[%]')
%      title('�o�b�e���[�c�ʐ���')
%      grid
%      
     figure
     plot(epoch,actionmatrix,'k-',epoch,Ematrixd,'r-',epoch,harvest,'b-.')
     axis([0 1000 0 100])
     legend('�f���[�e�B��','�o�b�e���c��','���d��')
     xlabel('����[t]')
     ylabel('����[%]')
     title('�f���[�e�B��ƃo�b�e���c�ʂ̐���')
%      figure
%      plot(epoch,Ematrixd,'r-')
%      axis([0 1000 0 100])
%      legend('�o�b�e���c��')
%      xlabel('����[t]')
%      ylabel('����[%]')
%      title('�o�b�e���c�ʂ̐���')
% 
%      figure
%      bar(AVE)
%      axis([0 13 10 85])
%      xlabel('��')
%      ylabel('���σf���[�e�B��')
%      title('���ʕ��σf���[�e�B��')
%      grid