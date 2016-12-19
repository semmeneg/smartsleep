function [fall Yall] = seg2FFT(seg, animate, h)
% [fall Yall] = seg2FFT(seg)
% [fall Yall] = seg2FFT(seg, animate)
% [fall Yall] = seg2FFT(seg , animate, h)
% 
% Will return the frequency vector and FFT vector for signal SEG. 
% ANIMATE is true or false. Default: false. Will scan SEG with window width h and step size h. 
% 
% EXAMPLE: 
% [f Y] = seg2FFT(seg, true)
% plot(f, Y);
%
% Created by Martin Längkvist, 2012

if nargin==1
    animate=false;
end

if nargin==2
    try
        HDR=evalin('base','HDR');
        h=HDR.SampleRate;
    catch
        h=128;
    end
elseif nargin==1
    try
        HDR=evalin('base','HDR');
        h=HDR.SampleRate;
    catch
        h=128;
    end
    animate=false;
end

T=1/h;
res = 20;
Nall = length(seg)*res;

Yall = T/Nall*abs(fft([seg; zeros((res-1)*length(seg),1)])).^2;
fall = (0:Nall-1)/Nall/T;

if animate
    width=h;
    ss=h;
    N = width*res;
    t = 0:T:(length(seg)-1)*T;
    f = (0:N-1)/N/T;
    nt = floor((length(seg)-width)/ss) + 1;
    Y = zeros(nt,N);

    for i=1:nt
        b = seg(1+ss*(i-1):width+ss*(i-1));
        Y(i,:)=T/N*abs(fft([b; zeros((res-1)*length(b),1)])).^2';
        disp(num2str(sum(Y(i,f <= 0.5))/sum(Y(i,:))))
    end
    
    figure; subplot(3,1,1); hold on; ax1 = gca;
    plot(t,seg);
    axis tight; grid on;
    h1a=plot([t(1) t(1)],get(gca,'YLim'),'r', 'LineWidth', 2);
    h1b=plot([t(width) t(width)],get(gca,'YLim'),'r', 'LineWidth', 2);
    xlabel('Time [s]'); ylabel('Signal'); title('Time-domain');
    
    subplot(3,1,2); hold on; ax2 = gca;
    h2=stem(f, Y(1,:),'b');
    xlabel('Hertz [Hz]'); ylabel('Signal'); title('FFT');
    axis tight; 
    %xlim([0 h/2]); 
    xlim([0 5]);
    grid on;
    
    subplot(3,1,3); hold on; ax3 = gca;
    stem(fall, Yall,'b');
    xlabel('Hertz [Hz]'); ylabel('Signal'); title('FFT');
    axis tight; xlim([0 h/2]); grid on;
    
    for i=2:nt
        set(h1a,'Xdata',[t(1+ss*(i-1)) t(1+ss*(i-1))]);
        set(h1b,'Xdata',[t(width+ss*(i-1)) t(width+ss*(i-1))]);
        set(h2,'Ydata',Y(i,:));
        set(gcf,'CurrentAxes',ax1); axis tight;
        set(gcf,'CurrentAxes',ax2); axis tight; xlim([0 5]);
        set(gcf,'CurrentAxes',ax3); axis tight;
        %pause(max(5/nt,0.01))
        pause(1);
        %axis tight;
    end
end



end