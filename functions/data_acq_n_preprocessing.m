%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
% 2017.09.20 main timer function 데이터를 실시간으로 queue로 넣는 코드.
%--------------------------------------------------------------------------
function data_acq_n_preprocessing(  )
global GUI;
global exp_inform;
global p;
global DB_backup
global bdf;
global cq
global timer_obj;

% timeStart = toc(timer_obj.data_acq_n_preprocessing.UserData)

try
    %data input
    if GUI.prog_mode ==0
        if DB_backup.curr_pos+exp_inform.sf_of_timer-1 > size(bdf.data,2)
            myStop();
            return;
        end
        seg = bdf.data(1:10,DB_backup.curr_pos:DB_backup.curr_pos+exp_inform.sf_of_timer-1);
        seg = double(seg)';
        trg_seg = bdf.trg(DB_backup.curr_pos:DB_backup.curr_pos+exp_inform.sf_of_timer-1);
        DB_backup.curr_pos = DB_backup.curr_pos+ exp_inform.sf_of_timer;
    elseif GUI.prog_mode ==1
        if (GUI.use_biosmix ==1)
            try
                seg = biosemi_signal_recieve(exp_inform.n_ch_rawdata);
            catch me
                if strfind(me.message,'biosemix')
                    errordlg('Please check you are using matlab 32bit version. and please Stop now');
                end
            end
        elseif (GUI.use_biosmix ==0)
%             if cq.TCP_buffer.datasize<exp_inform.sf_of_timer % TCP 버퍼가 아직 안쌓였으면 return 시킴
%                 seg = cq.TCP_buffer.getLastN(cq.TCP_buffer.datasize);
%             else
%                 seg = cq.TCP_buffer.getLastN(exp_inform.sf_of_timer);
%             end
            seg = TcpIpClientMatlabV1();
%             seg = seg(:,1:12);
        end
    end
    
    % raw data 및 표정 인스트럭션 시점 저장
    if ~exist('seg','var')
        return;
    end
    seg_size = size(seg,1);
%     disp(seg_size);
    if seg_size == 0
%         myStop;
        return;
    end
%     myStop;
    DB_backup.rawdata(DB_backup.raw_pos:DB_backup.raw_pos+seg_size-1,1:exp_inform.n_ch_rawdata)...
        = seg;
    if(GUI.id_start_fe)        
        DB_backup.rawdata(DB_backup.raw_pos:DB_backup.raw_pos+seg_size-1,exp_inform.n_ch_rawdata+1)...
            = ones(seg_size,1);
    else
        DB_backup.rawdata(DB_backup.raw_pos:DB_backup.raw_pos+seg_size-1,exp_inform.n_ch_rawdata+1)...
            = zeros(seg_size,1);
    end
    DB_backup.raw_pos = DB_backup.raw_pos + seg_size;
    
    % channel configuration
%     temp_chan = cell(1,6);
%     temp_chan{1} = seg(:,1) - seg(:,2); %Right_Temporalis
%     temp_chan{2} = seg(:,3) - seg(:,4);%Left_Temporalis
%     temp_chan{3} = seg(:,5) - seg(:,6);%Right_Frontalis
%     temp_chan{4} = seg(:,7) - seg(:,8);%Left_Corrugator
%     temp_chan{5} = seg(:,9) - seg(:,10);%Left_Zygomaticus
%     temp_chan{6} = seg(:,11) - seg(:,12);%Right_Zygomaticus
%     emg_bip.RZ= OUT.data(p_emg.rc_matrix(i_comb,1),:) - ...
%                 OUT.data(p_emg.rc_matrix(i_comb,2),:);
%             emg_bip.RF= OUT.data(4,:) - OUT.data(5,:);
%             emg_bip.LF= OUT.data(6,:) - OUT.data(7,:);
%             emg_bip.LZ= OUT.data(p_emg.lc_matrix(i_comb,1),:) - ...
%                 OUT.data(p_emg.lc_matrix(i_comb,2),:);
        
    temp_chan{1}= seg(:,1) - seg(:,3);%Right_Zygomaticus
    temp_chan{2}= seg(:,4) - seg(:,5); %Right_Frontalis
    temp_chan{3}= seg(:,6) - seg(:,7); %Left_Corrugator
    temp_chan{4}= seg(:,10) - seg(:,8); %Right_Zygomaticus
            
    segs = cell2mat(temp_chan);

    
    % filtering notch, BPF
    if isempty(p.f.nZn)
        [segs,p.f.nZn] = filter(p.f.nB,p.f.nA,...
           segs,[],1);
    else
        [segs,p.f.nZn] = filter(p.f.nB,p.f.nA,segs,p.f.nZn,1);
    end    
    if isempty(p.f.bZn)
        [segs,p.f.bZn] = filter(p.f.bB,p.f.bA,...
            segs,[],1);
    else
        [segs,p.f.bZn] = filter(p.f.bB,p.f.bA,segs,p.f.bZn,1);
    end
    cq.emg_procc.addArray(segs); % 그림 출력 데이터
    
    Process_EMG(); % EMG 신호 처리 및 분류
catch ex
    struct2cell(ex.stack)'
    myStop;
    keyboard;
end
% timeEnd = toc(info.timer.online_code.UserData)
end

