function temp = get_labels(dim_left,n_class, dim_right)
   
if size(n_class,1)==1 && size(n_class,2)==1
    temp = repmat(1:n_class,dim_left,1);
else
    temp = repmat(n_class,dim_left,1);
end
        temp = temp(:);
        temp = repmat(temp,dim_right,1);
end