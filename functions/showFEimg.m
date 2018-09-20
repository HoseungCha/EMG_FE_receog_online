function showFEimg(idxFE,nFE)
global h_image
for i=1:nFE
    h_image(i).Visible='off';
end
h_image(idxFE).Visible = 'on'; % defualt image
end