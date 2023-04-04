function fig = cj_showcourtshipaudiodata(data,fs)
%%function to plot all mic data from 1 file 

    s = get(0,'ScreenSize');
    t = (1:length(data))/(fs*10);
    figure('Position',[0 0 s(3) s(4)]);
    
    fig = tiledlayout(12,2,'TileSpacing','tight','Padding','tight');
    k = 1;
    for i = 1:2:11
        ax1 = nexttile(k);
        showAudioSpectrogram(data(:,i),fs)
        if i>1
            linkaxes([ax4,ax1],'x')
        end
        
        ax2 = nexttile(k+1);
        plot(t,data(:,i))
        set(gca,'Color','None')
        set(gca,'XTick',[])
        set(gca,'Xcolor','none');
        ylim([-0.1 0.1])
        box off
        linkaxes([ax1,ax2],'x')
        
        ax3 = nexttile(k+2);
        showAudioSpectrogram(data(:,i+1),fs)
        linkaxes([ax2,ax3],'x')
        %set(gca,'XTick',[])

        ax4 = nexttile(k+3);
        plot(t,data(:,i+1))
        set(gca,'Color','None')
        set(gca,'XTick',[])
        set(gca,'Xcolor','none');
        ylim([-0.1 0.1])
        box off
        k = k+4;
        linkaxes([ax3,ax4],'x')
        
    end
    
end