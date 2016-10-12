function [ seq ] = calculateSEQ_FFT( x, windowWidth )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    numSamples = length( x );

    % vector of tokens observed in each window
    % 1 ... zero 
    % 2 ... low
    % 3 ... medium
    % 4 ... high
    % 5 ... very high
    seq = ones( 1, numSamples );
    
    for i = 1 : numSamples
        if ( i + windowWidth - 1 > numSamples )
            break;
        end
        
        observation = 1;
        
        %Window length (number of samples)
        m = numSamples;
        % Transform length
        n = pow2(nextpow2(m));
        % Samples/unit time: one sample every 30 seconds
        fs = 0.03;
        % Discrete Fourier transform (DFT)
        y = fft(x,n);
        % Power of the DFT
        % power = (abs(y).^2)/n;
        power = y.*conj(y)/n; 
        % Frequency increment
        fInc = fs/n;
        % Frequency range
        f = (0:n-1)*fInc;

%         figure;
%         plot(f,power);
%         xlabel('Frequency (Hz)');
%         ylabel('Power');
%         title( sprintf( 'Periodogram for %s ', dsout.Sensors.vnames{ :, i } ) );

        [ B, I ] = sort( power, 'descend' );
        f( I( 1 : 3 ) );
        
        dominantFreq = f( I( 1 ) );
        
        if ( 0.0001 > dominantFreq )
            observation = 1;
        elseif ( 0.0001 <= dominantFreq && 0.29 > dominantFreq )
            observation = 2;
        elseif ( 0.29 <= dominantFreq )
            observation = 3;
        else 
            observation = 1;
        end
        
        seq( i ) = observation;
    end
end
