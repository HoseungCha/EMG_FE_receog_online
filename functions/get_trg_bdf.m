function [lat_trg,idx_seq_FE]  = get_trg_bdf(trg)
% load trigger
tmp_trg = cell2mat(permute(struct2cell(trg),[1 3 2]))';

% check which DB type you are working on
% total number of trigger 33: Myoexpression1
% total number of trigger 23: Myoexpression2

switch length(tmp_trg)
    case 33
        [lat_trg,idx_seq_FE] = get_trg_myoexp1(tmp_trg);
    case 23
        [lat_trg,idx_seq_FE] = get_trg_myoexp2(tmp_trg);
end
        
end

function [lat_trg,idx_seq_FE] = get_trg_myoexp1(trg)
%Trigger latency ¹× FE ¶óº§
if ~isempty(find(trg(:,1)==16385, 1)) || ...
        ~isempty(find(trg(:,1)==16384, 1))
    trg(trg(:,1)==16384,:) = [];
    trg(trg(:,1)==16385,:) = [];
end

idx_seq_FE = trg(2:3:33,1);
lat_trg = trg(2:3:33,2);

% idx2use_fe = zeros(11,1);
% for i_fe = 1 : 11
%     tmp_fe = find(trg_cell(:,1)==i_fe);
%     idx2use_fe(i_fe) = tmp_fe(2);
% end
% [~,idx_seq_FE] = sort(idx2use_fe);
% lat_trg = trg_cell(idx2use_fe,2);
% lat_trg = lat_trg(idx_seq_FE);
end

function [lat_trg,idx_seq_FE] = get_trg_myoexp2(trg)
% get trigger latency when marker DB acquasition has started
trg_camera_onset = trg(1,1);

trg = trg-trg_camera_onset;

% check which triger is correspoing to each FE and get latency
tmp_emg_trg = trg(2:end,:);
Idx_trg_obtained = reshape(tmp_emg_trg(:,1),[2,size(tmp_emg_trg,1)/2])';
tmp_emg_trg = reshape(tmp_emg_trg(:,2),[2,size(tmp_emg_trg,1)/2])';
lat_trg = tmp_emg_trg(:,1);

% get sequnece of facial expression in this trial
[~,idx_in_order] = sortrows(Idx_trg_obtained);    
tmp_emg_trg = sortrows([idx_in_order,(1:length(idx_in_order))'],1); 
idx_seq_FE = tmp_emg_trg(:,2); 
end
