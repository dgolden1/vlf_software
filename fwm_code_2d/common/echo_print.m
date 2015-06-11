function echo_print(save_plots,fname)
if save_plots
    disp(['Saving picture ''' fname ''' ...']);
    print('-depsc2',[fname '.eps'])
    hgsave([fname '.fig']);
end
