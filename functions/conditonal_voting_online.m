function y_corrected = conditonal_voting_online(xtest,model,template_c3)
global pred
global pred_corrected
global count
global non_exp_activated;


pred.add(predict(model,xtest));

% condition #1
if pred.datasize<5
    y_corrected = NaN;
    return;
end
if ~range(pred.getLastN(5))
%     myStop;
    pred_corrected.add(pred.getLast);
else
    pred_corrected.add(pred_corrected.get(2));
end

% condition #3
if pred.datasize<pred.length
    y_corrected = NaN;
    return;
end

% myStop;
temp = pred.getLastN(13);
temp = temp(template_c3);
if ~range(temp(1:3))&&temp(4)==9&&temp(1)~=9
    non_exp_activated = true;
end

if non_exp_activated
    count = count + 1;
end

if count > 0 && count <=10
    pred_corrected.add(9);
end

if count == 10
    count = 0;
    non_exp_activated = false;
end

y_corrected = pred_corrected.getLast;

if y_corrected== 0
    y_corrected = NaN;
end
   
end