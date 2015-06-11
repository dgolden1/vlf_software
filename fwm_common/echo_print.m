function echo_print(save_plots,fname)
if ischar(save_plots)
    save_plots={save_plots};
end
if iscell(save_plots)
    s=0;
    n=length(save_plots);
    for k=1:n
        switch save_plots{k}
            case 'EPS'
                s=bitor(s,2^0);
            case 'FIG'
                s=bitor(s,2^1);
            case 'PNG'
                s=bitor(s,2^2);
            case 'PDF'
                s=bitor(s,2^3);
        end
    end
    save_plots=s;
end
if save_plots
    disp(['Saving picture ''' fname ''' ...']);
end
if bitget(save_plots,1)
    print('-depsc2',[fname '.eps'])
    disp(' EPS');
end
if bitget(save_plots,2)
    hgsave([fname '.fig']);
    disp(' FIG');
end
if bitget(save_plots,3)
    print('-dpng',[fname '.png'])
    disp(' PNG');
end
if bitget(save_plots,4)
    print('-dpdf',[fname '.pdf'])
    disp(' PDF');
end
