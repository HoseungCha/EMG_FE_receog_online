%--------------------------------------------------------------------------
% train LDA when train is finisehd
%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------
function find_feat_and_train()
global exp_inform;
global path;
global DB_backup;
try
tic;

%--------------------------experiment infromation-------------------------%
% feature indexing when using DB of ch4 ver
clear idx_feat;
idx_feat.RMS = 1:4;
idx_feat.WL = 5:8;
idx_feat.SampEN = 9:12;
idx_feat.CC = 13:28;
n_feat = 28;

% feat names and indices
name_feat = fieldnames(idx_feat);
idx_feat = struct2cell(idx_feat);
n_ftype = length(name_feat);
n_seg = 30;
n_FE = length(exp_inform.name_FE);
n_transforemd = 1;
%-------------------------------------------------------------------------%

%----------------------------------load DB--------------------------------%
% load new feature set whose order of facial expression was corrected
feat = cell(exp_inform.n_fe,1);
for i_fe = 1 : exp_inform.n_fe
    feat{i_fe} = DB_backup.FeatSet{exp_inform.order_fe(i_fe)};
end
% change the format of this features as [n_seg, n_feat, n_FE]
feat = cat(3,feat{:});

% load feature set from DB
tmp = load(fullfile(path.research,'EMG_FE_recognition_emotion','Code','DB',...
    'DB_processed','feat_set_seg_30.mat'));
tmp_name = fieldnames(tmp);
feat_DB = getfield(tmp,tmp_name{1}); %#ok<GFLD>
%  30    28     8    20    15     3
%-------------------------------------------------------------------------%

%--------------------------train-less algorithm---------------------------%
timerVal = tic;
% memory allocation similarily transformed feature set
feat_t = cell(n_seg,n_FE);
count = 0;
for i_seg = 1 : n_seg
for i_FE = 1 : n_FE      
% memory allocation feature set from other experiment
feat_t{i_seg,i_FE} = cell(1,n_ftype);   

% you should get access to DB of other experiment with each features    
for i_FeatName = 1 : n_ftype
    count = count + 1;
    % number of feature of each type
    n_feat_each = length(idx_feat{i_FeatName});

    % feat from this experiment [Seg, FE]
    feat_ref = feat(i_seg,idx_feat{i_FeatName} ,i_FE)';
    
    % feat to be compared from other experiment [1,4,1,20,45]
    feat_compare_DB = feat_DB(i_seg,idx_feat{i_FeatName},i_FE,:,:);
                    
    % permutation giving [n_feat, n_FE, n_trl, n_sub ,n_seg]
    feat_compare_DB = permute(feat_compare_DB,[2 3 4 5 1]);   
    
    % reshape it as [n_feat_each, ALL], cf:size(2):FE, size(5):seg
%     feat_compare_DB = reshape(feat_compare_DB,...
%         [n_feat_each, size(feat_compare_DB,2)*n_trl*n_sub_DB*...
%         size(feat_compare_DB,5)]);
    feat_compare_DB = reshape(feat_compare_DB,n_feat_each,[]);
    
    % get similar features by determined number of transformed DB
    feat_t{i_seg,i_FE}{i_FeatName} = ...
        dtw_search_n_transf(feat_ref, feat_compare_DB, n_transforemd)';
    fprintf('%0.2f of 1 has been done\n', count/(n_seg*n_FE*n_ftype));
end
end
end

%-------------------------------------------------------------------------%

% arrange feat transformed and target
% concatinating features with types
feat_t = cellfun(@(x) cat(2,x{:}),feat_t,'UniformOutput',false);
                    
% % get feature-transformed with number you want
feat_trans = cellfun(@(x) x(1:n_transforemd,:),feat_t,'UniformOutput',false); 

% get size to have target
size_temp = cell2mat(cellfun(@(x) size(x,1),feat_trans(:,1),'UniformOutput',false));

% feature transformed 
feat_trans = cell2mat(feat_trans(:));

% target for feature transformed 
target_feat_trans = repmat(1:n_FE,sum(size_temp,1),1);
target_feat_trans = target_feat_trans(:); 

% change feat for anlaysis into [n_seg, n_feat, n_FE]  by [n_seg, n_feat, n_FE]
feat_ref = reshape(permute(feat,[1 3 2]),[n_seg*n_FE,n_feat]);

% target for feature  
target_feat_ref = repmat(1:n_FE,n_seg,1);
target_feat_ref = target_feat_ref(:);
            
% get input and targets for train DB
input_train = cat(1,feat_ref,feat_trans);
target_train = cat(1,target_feat_ref,target_feat_trans);                

% train
model.lda = fitcdiscr(input_train,target_train);

% display of training time
elapsedTime = toc(timerVal);
fprintf('Elapsed Time is %0.2f s\n', elapsedTime)

%-----------------------------save model and DB---------------------------%
uisave({'model','DB_backup','exp_inform'},fullfile(path.code,'model',datestr(now,'yymmdd_')));

% get rid of useless feat
DB_backup = rmfield(DB_backup,'FeatSet');

% save feature transforemd in DB back up
DB_backup.feat_trans = feat_trans;
DB_backup.feat_ref = feat_ref;
%-------------------------------------------------------------------------%
catch ex
struct2cell(ex.stack)'
myStop;
keyboard;
end
end




