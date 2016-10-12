function [ p ] = spectralAnalysisPlot( msrData, channel, range )
%SPECTRALANALYSIS Summary of this function goes here
%   Detailed explanation goes here

    from = range( 1 );
    to = range( 2 );
    
    t = msrData( 1, from : to ); % time base
    % estimate frequency: timestamps start with 0.0 and increase in fractions
    % of seconds. thus the index where the time is >= 1.0 is the frequency
    fs = find( t >= 1.0, 1, 'first');
    %Window length (number of samples)
    sampleCount = length( t );
    % Transform length
    n = pow2(nextpow2(sampleCount));
    
        x = msrData( channel, from : to );
        % Discrete Fourier transform (DFT)
        y = fft(x,n);
        % Amplitude of the DFT
        amp = abs(y);
        % Power of the DFT
        % power = (abs(y).^2)/n;
        power = y.*conj(y)/n; 
        % Frequency increment
        fInc = fs/n;
        % Frequency range
        f = (0:n-1)*fInc;
        % Nyquist frequency
        nyquist = fs/2;

        y0 = fftshift(y);          % Rearrange y values
        f0 = (-n/2:n/2-1)*(fs/n);  % 0-centered frequency range
        power0 = y0.*conj(y0)/n;   % 0-centered power

%         p = plot(f,power);
%         xlabel('Frequency (Hz)');
%         ylabel('Power');
%         % title( sprintf( 'Periodogram for %s ', dsout.Sensors.vnames{ :, i } ) );
%         title( 'Periodogram' );

        p = plot(f0,power0);
        xlabel('Frequency (Hz)');
        ylabel('Power');
        %title( sprintf( '0-Centered Periodogram for %s ', dsout.Sensors.vnames{ :, i } ) );
        title( '0-Centered Periodogram' );

%          [ B, I ] = sort( power, 'descend' );
%          f( I( 1 : 3 ) )

    %     [ B0, I0 ] = sort( power0, 'descend' );
    %     f0( I0( 1 : 3 ) );
    %     
    %     f( I( 1 : end ) ) - f0( I0( 1 : end ) )
end

