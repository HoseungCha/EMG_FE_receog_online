% natural eye-brow expression selector with lip expression
function y = natural_eye_brow_exp_selctor(ouput_lips)
switch ouput_lips
    case 1
        y = [1,6,9,10,11];
    case 2
        y = [1,6,9,10];
    case 3
        y = 9;
    case 4
        y = 9;
    case 6
        y = [6,9,10];
    case 7
        y = [6,9,10];
    case 8
        y = 9;
    case 9
        y = [1,6,9,10,11];
    case 11
        y = [1,6,9,10,11];
end

end