function l1=truncpad(l,n)
if length(l)<n
    l1=[l blanks(n-length(l))];
else
    l1=l(1:n);
end
