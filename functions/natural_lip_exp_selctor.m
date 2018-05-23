% natural lip expression selector with eye brow expression
function y = natural_lip_exp_selctor(output_eyebrow)
switch output_eyebrow
    case 1
        y = [1,2,11];
    case 6
        y = [1,2,7,11];
    case 9
        y = [1,2,3,4,6,7,8,11];
    case 10
        y = [1,2,7,11];
    case 11
        y = [1,11];
end
end