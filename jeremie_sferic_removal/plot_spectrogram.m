function plot_spectrogram(data,fs,fset,stepsize)
axes('Fontsize',14);
if(nargin ~= 4)
    stepsize = 2048;
end
F = (fset-1500):10:(fset+1500);
[Y,F,T,P] = spectrogram(data,1024,750,2048,fs,'yaxis');
maxlim = max(max(10*log10(abs(P))));
minlim = min(min(10*log10(abs(P))));
colormap(jet);

surf(T,F,10*log10(abs(P)),'EdgeColor','none');
caxis([-40 .8*maxlim]);
% axis xy; 
if(nargin > 2 )
    axis([0 length(data)/fs fset-1100 fset + 1100]);  
else
    axis tight
end


    
view(0,90);
xlabel('Time');
ylabel('Frequency (Hz)');
h = colorbar;
set(get(h,'xlabel'),'string','Power (dB rel.)')
set(get(h,'xlabel'),'Fontsize',14)
set(h,'xaxislocation','Top')

