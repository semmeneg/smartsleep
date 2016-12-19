function [ output_args ] = fftTransform( msrData )
%FFTTRANSFORM Summary of this function goes here
%   Detailed explanation goes here

    axisIndices = [ 4 5 6 ];
    t = msrData( 1, : ); % time base
    % estimate frequency: timestamps start with 0.0 and increase in fractions
    % of seconds. thus the index where the time is >= 1.0 is the frequency
    f = find( t >= 1.0, 1, 'first');

    sampleCount = length( t );
    
    for i = 1:3
        axisIndex = axisIndices( i );
        x = msrData( axisIndex, : );
        
        figure
        plot(t,x);
        title(['Sine Wave f=', num2str(f), 'Hz']);
        xlabel('Time(s)');
        ylabel('Amplitude');
        
        NFFT=pow2(nextpow2(sampleCount)); %NFFT-point DFT	 	 
        X=fft(x,NFFT); %compute DFT using FFT	 	 
        nVals=0:NFFT-1; %DFT Sample points	 	 
        plot(nVals,abs(X));	 	 
        title('Double Sided FFT - without FFTShift');	 	 
        xlabel('Sample points (N-point DFT)')	 	 
        ylabel('DFT Values');
    end
end

