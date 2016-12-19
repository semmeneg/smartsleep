function E = seg2E(seg, width, ss, mode, userpara)
% E = seg2E(seg, width, ss, mode, userpara)
%
% Converts a segment of data into a feature extraction matrix.
%
% INPUTS:
% SEG is a N x 2 matrix for MODE 'eyecorr', otherwise it's a N X 1 vector.
% WIDTH is the window width. SS is the step size for the window.
% MODE can be 'fft', 'fft2', 'smean', 'fractalexp', 'deltabeta', 
% 'deltagamma', 'deltaalpha', 'sigmabeta', 'dwt', 'eyecorr', 'off', 
% 'recovery', 'highamp', 'entropy', 'sef95', 'std', 'median', 'mean', 
% 'sweat', 'kurtosis', 'amp'.
% USERPARA is a user parameter used for certain modes for example thresholding.
%
% OUTPUT: 
% E is a nt X M matrix, where nt is (floor((size(seg,1) - width) / ss)+1) 
% and M depends on MODE. 

% EXAMPLE:
% E = seg2E(s(n,chan), 400, 100, 'dwt')
%
% Created by Martin Längkvist, 2012

if nargin < 5
    userpara=[];
end

if size(seg,1) < width
    disp('WARNING: seg is less than window width')
end

HDR = evalin('base','HDR');
h = HDR.SampleRate; %sample frequency of data
nt = floor((size(seg,1) - width) / ss)+1;

switch mode
    case 'fft'
        E=zeros(nt,5);
    case 'fft2'
        E=zeros(nt,10);
    case 'smean'
        E=zeros(nt,1);
    case 'fractalexp'
        E=zeros(nt,1);
    case 'deltabeta'
        E=zeros(nt,1);
    case 'deltagamma'
        E=zeros(nt,1);
    case 'deltaalpha'
        E=zeros(nt,1);
    case 'sigmabeta'
        E=zeros(nt,1);
    case 'dwt'
        E=zeros(nt,4);
        w = 'sym3';     % Wavelet mother function
        l = 1;          % DWT-level
    case 'eyecorr'
        E=zeros(nt,1);
    case 'off'
        E=zeros(nt,size(seg,2));
    case 'recovery'
        E=zeros(nt,size(seg,2));
    case 'highamp'
        E=zeros(nt,size(seg,2));
    case 'entropy'
        E=zeros(nt,1);
    case 'sef95'
        E=zeros(nt,1);
    case 'std'
        E=zeros(nt,size(seg,2));
    case 'median'
        E=zeros(nt,size(seg,2));
    case 'mean'
        E=zeros(nt,size(seg,2));
    case 'sweat'
        E=zeros(nt,2);
    case 'kurtosis'
        E=zeros(nt,1);
    case 'amp'
        E=zeros(nt,size(seg,2));
        
end

for i=1:nt
    
    b = seg(1+ss*(i-1):width+ss*(i-1),:);
    
    switch mode
        case 'fft'
            [f Y] = seg2FFT(b,false);
            nP1=Y(f>=0.5 & f<4);  % delta
            nP2=Y(f>=4 & f<8);    % theta
            nP3=Y(f>=8 & f<13);   % alpha
            nP4=Y(f>=13 & f<20);  % beta
            nP5=Y(f>=20 & f<h/2); % high freq
            nP=sum([nP1; nP2; nP3; nP4; nP5]);
            E(i,:)=[sum(nP1)/nP sum(nP2)/nP sum(nP3)/nP sum(nP4)/nP sum(nP5)/nP];
            
        case 'fft2'
            [f Y] = seg2FFT(b,false);
            nP1=Y(f>=0.5 & f<2);  % delta1
            nP2=Y(f>=2 & f<4);    % delta2
            nP3=Y(f>=4 & f<6);   % theta1
            nP4=Y(f>=6 & f<8);  % theta2
            nP5=Y(f>=8 & f<10);  % alpha1
            nP6=Y(f>=10 & f<12);    % alpha2
            nP7=Y(f>=12 & f<14);   % sigma1
            nP8=Y(f>=14 & f<16);  % sigma2
            nP9=Y(f>=16 & f<30);  % beta
            nP10=Y(f>=30 & f<h/2); % gamma
            nP=sum([nP1; nP2; nP3; nP4; nP5; nP6; nP7; nP8; nP9; nP10;]);
            E(i,:)=[sum(nP1)/nP sum(nP2)/nP sum(nP3)/nP sum(nP4)/nP sum(nP5)/nP sum(nP6)/nP sum(nP7)/nP sum(nP8)/nP sum(nP9)/nP sum(nP10)/nP];
            
        case 'smean'
            [f Y] = seg2FFT(b,false);
            nP1=Y(f>=0.5 & f<4);  % delta
            nP2=Y(f>=4 & f<8);    % theta
            nP3=Y(f>=8 & f<13);   % alpha
            nP4=Y(f>=13 & f<20);  % beta
            nP5=Y(f>=20 & f<h/2); % high freq
            nP=sum([nP1; nP2; nP3; nP4; nP5]);
            E(i,:)=sum([3.5 4 5 7 h/2-20].*[sum(nP1)/nP sum(nP2)/nP sum(nP3)/nP sum(nP4)/nP sum(nP5)/nP])/(h/2-0.5);
            
        case 'fractalexp'
            [f Y]=seg2FFT(b,false);
            f=f(f>=0.5 & f<h/2);
            Y=Y(f>=0.5 & f<h/2);
            
            P=polyfit(log(f'),log(Y),1);
            E(i,:) = P(1);

        case 'deltabeta'
            [f Y] = seg2FFT(b,false);
            nP1=Y(f>=0.5 & f<4);  % delta
            nP4=Y(f>=16 & f<30);  % beta
            E(i,:)=sum(nP1)/sum(nP4);
            
        case 'deltagamma'
            [f Y] = seg2FFT(b,false);
            nP1=Y(f>=0.5 & f<4);  % delta
            nP4=Y(f>=30 & f<40);  % gamma
            E(i,:)=sum(nP1)/sum(nP4);
            
        case 'deltaalpha'
            [f Y] = seg2FFT(b,false);
            nP1=Y(f>=0.5 & f<4);  % delta
            nP4=Y(f>=8 & f<12);  % alpha
            E(i,:)=sum(nP1)/sum(nP4);
            
        case 'sigmabeta'
            [f Y] = seg2FFT(b,false);
            nP1=Y(f>=12 & f<16);  % sigma
            nP4=Y(f>=16 & f<30);  % beta
            E(i,:)=sum(nP1)/sum(nP4);
            
        case 'dwt'
            [C, L] = wavedec(b,l,w);
            A1=C(1:L(1));
            %D1=C(L(1)+1:L(3));
            E(i,:)=[max(A1) min(A1) mean(A1) std(A1)]; % max(D1) min(D1) mean(D1) std(D1)];
        case 'eyecorr'
            E(i,1) = xcorr(b(:,1),b(:,2),0,'coef');
        case 'off'
            E(i,max(b) < userpara & min(b) > -userpara) = 1;
        case 'recovery'
            E(i,max(b) > userpara | min(b) < -userpara) = 1;
        case 'highamp'
            E(i,max(b) > userpara | min(b) < -userpara) = 1;
        case 'entropy'
            %E(i,:) = wentropy(b,'shannon');
            n = length(b);
            P = hist(b,ceil(sqrt(n)))/n;
            E(i,:) = -nansum(P.*log(P));
        case 'sef95'
            bfilt=bpfilter(b,[1 h/2]);
            [f Y] = seg2FFT(bfilt,false);
            Yhalf=Y(1:end/2);
            fhalf=f(1:end/2);
            Etot=sum(Yhalf.^2);
            N=length(Yhalf);
            psi=zeros(N,1);
            
            for n=1:N
                psi(n)=sum(Yhalf(1:n).^2)/Etot;
            end
            
            temp=find(psi>0.95);
            
            E(i)=fhalf(temp(1));
            
        case 'std'
            E(i,:) = std(b);
            
        case 'median'
            E(i,:) = median(abs(b));
            
        case 'mean'
            E(i,:) = mean(b);
            
        case 'sweat'
            [f Y] = seg2FFT(b,false);
            [maxY loc] = max(Y);
            E(i,:) = [maxY f(loc)];
            
        case 'kurtosis'
            E(i,:) = kurtosis(b);
            
        case 'amp'
            E(i,:) = abs(max(b)-min(b));
            
    end
end

end

