function house_price=plot_realestate(varargin)
%PLOT_REALESTATE Real estate calculations
% Usage:
%   house_price=plot_realestate[(options)]
% Options:
%   loan_rate     -- default==[0.04:.001:.16]
%   max_term      -- default=15, use 0 for infinite term
%   inflation     -- default=0.05
%   stock_return  -- default=0.11
%   required_down -- default=0.2
%   expenses      -- default=0.02 (property tax + maintenance)
%   monthly_rent  -- default=1000
%   do_plot       -- default=1 (boolean)

keys={'loan_rate','max_term','inflation','stock_return','required_down', ...
    'expenses','monthly_rent','do_plot'};
options=parsearguments(varargin,0,keys);
% n - mortgage term (years)
% r - mortgage rate (annual) (can include mortgage insurance)
% s - stock market returns
% i - inflation rate
% f - fraction for down payment
r=getvaluefromdict(options,'loan_rate',[0.04:.001:.16]);
n=getvaluefromdict(options,'max_term',15);
i=getvaluefromdict(options,'inflation',0.05);
s=getvaluefromdict(options,'stock_return',0.11);
flaw=getvaluefromdict(options,'required_down',0.2);
monthlyrent=getvaluefromdict(options,'monthly_rent',1000);
expenses=getvaluefromdict(options,'expenses',0.02); % property tax + maintenance
do_plot=getvaluefromdict(options,'do_plot',1);
if length(r)==1
    do_plot=0
end

% Rates adjusted for n-year term are with a bar
if n>0
    rbar=r./(1-(1+r).^(-n));
else
    rbar=r;
end
if n>0
    sbar=s./(1-(1+s).^(-n));
else
    sbar=s;
end
% s1 - inflation-corrected stocks return
s1=(1+s)./(1+i)-1;
if n>0
    deltas1=(1+s1).^(-n);
else
    deltas1=0;
end
s1bar=s1./(1-deltas1);
% l - the leasing rate, at which profit from real estate is the same as
% from stocks (everything is inflation-adjusted).
% The result, l is rent minus expenses (disposable income from rent).
% It is also the inverse P/E ratio.
% All calculations are done by auxiliary function GET_INVERSE_PE (see
% below)
lfixed=get_inverse_pe(s1,flaw,rbar,sbar); % 20% down, 15 year term
l0=get_inverse_pe(s1,0,r,s); % zero down, inf term
l=get_inverse_pe(s1,flaw,r,s); % 20% down, inf term

rentrate=[l0;l;lfixed]+expenses;

hprice=monthlyrent./(rentrate/12);
if nargout>0
    house_price=hprice;
end

if do_plot
    subplot(2,1,1);
    plot(r*100,hprice/1000); grid on;
    xlabel('Loan rate, %');
    ylabel('House price, $1000');
    title(['Monthly rent=$' num2str(monthlyrent) ', expenses=' num2str(expenses*100) '%']);
    legend('No max term, 0 down', ...
        ['No max term, min ' num2str(flaw*100) '% down'], ...
        [num2str(n) ' year term max + min ' num2str(flaw*100) '% down'])
    
    subplot(2,1,2);
    plot(r*100,(repmat(r,3,1)+expenses)./rentrate); grid on;
    xlabel('Loan rate, %');
    ylabel('Initial ownership cost / rent');
    title('Assuming zero down and interest-only')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Auxiliary function
function l=get_inverse_pe(s1,flaw,rbar,sbar)
f=flaw*ones(size(rbar)); % 20% down is mandated by law for investment property
f(find(rbar>sbar))=1; % optimization
l=s1.*(f+(rbar./sbar).*(1-f));
