function output = possible_fe_selector(score_matrix,output_matrix,name_gesture,name_gesture_c1,n_part)
output = cell(n_part,1);

class_selector = NaN(n_part,1);
score_selcted = NaN(n_part,1); 
for i_part = 1 : n_part
    [score_selcted(i_part),class_selector(i_part)] = max(score_matrix(i_part,:));
end
[~,idx_score_sorted] = sort(score_selcted,'descend');
part_selected = idx_score_sorted(1);
part_to_be_checked = idx_score_sorted(2);

gesture_group_selected = ...
    name_gesture{part_selected,class_selector(part_selected)};
gesture_selected = ...
    gesture_group_selected{output_matrix(part_selected,class_selector(part_selected))};

gesture_group_to_be_checked...
    = name_gesture{part_to_be_checked,class_selector(part_to_be_checked)};
gesture_to_be_checked = ...
    gesture_group_to_be_checked{...
    output_matrix(...
    part_to_be_checked,class_selector(part_to_be_checked))};

gesture_possible_other_part= name_gesture_c1{part_to_be_checked}( ...
     ~cellfun(@isempty,strfind(name_gesture_c1{part_selected},gesture_selected)));
gesture_possible_other_part = unique(gesture_possible_other_part);


    if any(ismember(gesture_possible_other_part,gesture_to_be_checked)==1)
        gesture_checked = gesture_possible_other_part...
            {ismember(gesture_possible_other_part,gesture_to_be_checked)};
    else
        gesture_checked = gesture_possible_other_part...
            {randi(length(gesture_possible_other_part))};
%         gesture_checked = 'neutral';
    end

output{part_selected} = gesture_selected;
output{part_to_be_checked} = gesture_checked;
end