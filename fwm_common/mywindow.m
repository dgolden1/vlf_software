function y=mywindow(x)
% Window function
y=x;
y(find(abs(x)>1))=0;
ii=find(abs(x)<=1);
y(ii)=cos(x(ii)*pi)+1;
