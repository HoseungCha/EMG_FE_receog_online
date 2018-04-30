%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
% process EMG 함수

function Process_EMG()   
global GUI;
global exp_inform;
global DB_backup;
global cq;
try
    
% timeStart = toc(info.timer.process_emg.UserData);  %for debugging
    % get segment
    curr_win =cq.emg_procc.getLastN(exp_inform.sf_of_timer);

    % feat extracion
    temp_rms = sqrt(mean(curr_win.^2)); % RMS
    temp_CC = featCC(curr_win,4); % CC
    temp_WL = sum(abs(diff(curr_win,2))); % WL
    temp_SampEN = SamplEN(curr_win,2); % Sample EN
    
    % train mode
    if GUI.handles.radiobutton_train.Value  
        
        if(GUI.id_start_fe==1)
            % inqueue of feature extracted
           cq.featset.addArray([temp_rms,temp_WL,temp_SampEN,temp_CC]);
           disp(cq.featset.datasize); % for checking if features entered
           if cq.featset.length == cq.featset.datasize % when all features are entered
               % go to next facial expression instruction
               temp_FE_order = circshift(exp_inform.order_fe4GUI,1,2); 
               % set index
               i_trl = find(exp_inform.order_fe==temp_FE_order(1));
               DB_backup.FeatSet{i_trl} = cq.featset.data;
               
               % feature buffer init
               cq.featset = circlequeue(exp_inform.n_win,...
                   exp_inform.n_bip_ch*3+exp_inform.n_bip_ch*4);
                
               % for FE GUI
               GUI.id_start_fe = 0;
           end
        end
    end
    
    %----------------------------test mode--------------------------------%
    if GUI.handles.radiobutton_test.Value 
        
        % feat construction
        test = [temp_rms,temp_WL,temp_SampEN,temp_CC];
        
        % classification        
        pred_lda = predict(getfield(exp_inform.model,exp_inform.name_ml),test);
        
        % add outputs
        cq.output.addArray(pred_lda);

        % datasize
        if cq.output.datasize == cq.output.length
            
            myStop;
            temp_pd = cq.output.getLastN(cq.output.length);
            
           % majority voting
            [~,fp] = max(countmember(1:exp_inform.n_fe,temp_pd));
            % presentation of classfied facial expression
            GUI.handles.edit_classification.String = ...
                sprintf('Classfied: %s',exp_inform.name_FE{fp});
            for i_fe=1:exp_inform.n_fe
                GUI.h_image(i_fe).Visible='off';
            end
            % display image from test result
            GUI.h_image(fp).Visible = 'on'; 
            fprintf(exp_inform.PC_serial, num2str(fp));% 시리얼 명령 보내기(아바타 표정 조정)
        end 
        % 표정을 짓는 구간에서 결과 저장
        if(GUI.id_start_fe)
           % saving predicted
            cq.test_result.addArray(pred_lda); 
           % saving featureset for backup
           cq.featset.addArray([temp_rms,temp_WL,temp_SampEN,temp_CC]);

           if cq.featset.length == cq.featset.datasize
               % trl 순서파악
               temp_FE_order = circshift(exp_inform.order_fe4GUI,1);
               i_trl = find(exp_inform.order_fe==temp_FE_order(1));
               % 결과 저장 및 init
               cq.test_result{i_trl} = cq.test_result.data;
               cq.test_result = circlequeue(exp_inform.n_win,1);%초기화
               % Feat 저장 및 init
               DB_backup.FeatSet_test{i_trl} = cq.featset.data;
               cq.featset = circlequeue(exp_inform.n_win,exp_inform.n_bip_ch*3+exp_inform.n_bip_ch*4);%초기화
               % when somithing error occurs
               if isempty(cq.test_result{i_trl}) 
                   myStop; 
                   keyboard;
               end
           end
        end
            
        
    end
catch ex
    struct2cell(ex.stack)'
    myStop;
    keyboard;
end
end

function f = featCC(curwin,order)
   cur_xlpc = real(lpc(curwin,order)');
   cur_xlpc = cur_xlpc(2:(order+1),:);
   Nsignals = size(curwin,2);
   cur_CC = zeros(order,Nsignals);
   for i_sig = 1 : Nsignals
      cur_CC(:,i_sig)=a2c(cur_xlpc(:,i_sig),order,order)';
   end
   f = reshape(cur_CC,[1,order*Nsignals]);
end

function c=a2c(a,p,cp)
%Function A2C: Computation of cepstral coeficients from AR coeficients.
%
%Usage: c=a2c(a,p,cp);
%   a   - vector of AR coefficients ( without a[0] = 1 )
%   p   - order of AR  model ( number of coefficients without a[0] )
%   c   - vector of cepstral coefficients (without c[0] )
%   cp  - order of cepstral model ( number of coefficients without c[0] )

%                              Made by PP
%                             CVUT FEL K331
%                           Last change 11-02-99

for n=1:cp
  sum=0;
  if n<p+1
    for k=1:n-1
      sum=sum+(n-k)*c(n-k)*a(k);
    end
    c(n)=-a(n)-sum/n;
  else
    for k=1:p
      sum=sum+(n-k)*c(n-k)*a(k);
    end
    c(n)=-sum/n;
  end
end
end

function f = SamplEN(curwin,dim)
    N_sig = size(curwin,2);
    f = zeros(1,N_sig);
    R = 0.2*std(curwin);
    for i_sig = 1 : N_sig
       f(i_sig) = sampleEntropy(curwin(:,i_sig), dim, R(i_sig),1); %%   SampEn = sampleEntropy(INPUT, M, R, TAU)
    end
end

function yp = majority_vote(xp)
% final decision using majoriy voting
% yp has final prediction X segments(times)
[N_Seg,N_trl,N_label] = size(xp);
yp = zeros(N_label*N_trl,1);
for n_seg = 1 : N_Seg
    maxv = zeros(N_label,N_trl); final_predict = zeros(N_label,N_trl);
    for i = 1 : N_label
        for j = 1 : N_trl
            [maxv(i,j),final_predict(i,j)] = max(countmember(1:8,...
                xp(1:n_seg,j,i)));
        end
    end
    yp(:,n_seg) = final_predict(:);
%     acc(n_seg,N_comp+1) = sum(repmat((1:label)',[N_trl,1])==final_predict)/(label*N_trial-label*n_pair)*100;
end
end