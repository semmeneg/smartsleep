function [ magnitude, stepsIndicator, stepsCount, peaks, valleys ] = detectSteps( accelerationData )
%DETECTSTEPS Summary of this function goes here
%   Detailed explanation goes here

	% TODO: detects only about half of the steps. need to refine, see below

    magnitude = sqrt(sum(accelerationData.^2,1));

    % NOTE: implementation of step-detection algorithm as found in paper 
    % "Step Detection Robust against the dynamics of smartphones" found in
    % openaccess sensors
    muA = mean( magnitude );          % the average magnitude between a peak and a valley
    sigmaA = std( magnitude );        % the deviation of the magnitude of acceleration
  
    oldState = 0;               % the current state: either valley or peak. start as intermediate
    
    maxLocalPeakIdx = 1;        % index in timeseries of last peak-sample
    maxLocalPeak = [];          % acc-vec at the recent peak
    minLocalValleyIdx = 1;      % index in timeseries of last valley-sample
    minLocalValley = [];        % acc-vec at the recent valley 

    recentValleyWindowsIdx = 1;
    recentPeakWindowsIdx = 1;
    recentAccSamplesIdx = 1;
    
    recentValleyWindows = [];
    recentPeakWindows = [];
    recentAccSamples = [];
    
    % exogenous constants, defined in the paper
    ALPHA = 4;
    BETA = 1;
    M = 10;
    K = 25;

    stepsIndicator = zeros( 1, length( accelerationData ) );
    peaks = nan( 1, length( accelerationData ) );
    valleys = nan( 1, length( accelerationData ) );

    stepsCount = 0;
    
    for n = 2 : length( accelerationData ) - 1
        an = accelerationData( :, n );

        % the state of the candidate: either peak (1), valley (-1) or
        % intermediate (0)
        sampleState = detectCandidate( accelerationData( :, n - 1 ), an, ...
            accelerationData( :, n + 1 ), muA, sigmaA, ALPHA );

        % detected a PEAK for the current sample
        if ( sampleState == 1 )
            if ( oldState ~= 0 )
                % include current peak in calculation of peak-window 
                [ recentPeakWindows, recentPeakWindowsIdx, peakWindow ] = ...
                    updatePeak( recentPeakWindows, recentPeakWindowsIdx, n, maxLocalPeakIdx, BETA, M );
                deltaToPreviousPeak = n - maxLocalPeakIdx;
                peaks( n ) = norm( an );

                % distance of current peak is further from local max-peak than
                % peak-window => start new local max-peak search.
                % NOTE: assume that local max-peak is maximum within peak-window
                % (see below)
                if ( deltaToPreviousPeak > peakWindow )
                    maxLocalPeakIdx = n;
                    maxLocalPeak = an;

                    
                % current peak is closer to local max peak than peak-window
                else
                    % check if curren peak is larger than local max-peak
                    % if yes => this curren peak becomes the new local max-peak
                    if ( norm( an ) > norm( maxLocalPeak ) )
                        maxLocalPeakIdx = n;
                        maxLocalPeak = an;
                    end
                end

                oldState = 1;
               
            % INITIAL state: started with intermediate
            else
                % store sample as first peak
                maxLocalPeakIdx = n;
                maxLocalPeak = an;
                oldState = 1;
            end

        % detected a VALLEY for the current sample
        elseif ( sampleState == -1 )
            if ( oldState ~= 0 )
                % include current valley in calculation of valley-window
                [ recentValleyWindows, recentValleyWindowsIdx, valleyWindow ] = ...
                    updateValley( recentValleyWindows, recentValleyWindowsIdx, n, minLocalValleyIdx, BETA, M );
                deltaToPreviousValley = n - minLocalValleyIdx;
                valleys( n ) = norm( an );
   
                % distance of current valley is further from local min-valley
                % than valley-window => start new local min-valley search.
                % NOTE: assume that local min-valley is minimum within valley-window
                % (see below)
                if ( deltaToPreviousValley > valleyWindow )
                    % previous state was a local max-peak AND we are starting 
                    % now a new search for a local min-valley => the current 
                    % local min-valley marks a new step
                    
                    % TODO: still not as sophisticated as possible, missing
                    % about half the steps. something is still missing
                    if ( oldState == 1 )
                        stepsIndicator( n ) = 1;
                        stepsCount = stepsCount + 1;
                    end
                    
                    minLocalValleyIdx = n;
                    minLocalValley = an;

                % current valley is closer to local min-valley than valley-window
                else
                    % check if current valley is smaller than local min-valley
                    % if yes => this current valley becomes the new local min-valley
                    if ( norm( an ) < norm( minLocalValley ) )
                        minLocalValleyIdx = n;
                        minLocalValley = an; 
                    end
                end
                
                oldState = -1;  
               
            % INITIAL state: started with intermediate
            else 
                % store sample as first valley
                minLocalValleyIdx = n;
                minLocalValley = an;
                oldState = -1;
            end
        end

%         recentAccSamples( recentAccSamplesIdx ) = norm( an );
%         recentAccSamplesIdx = recentAccSamplesIdx + 1;
%         if ( recentAccSamplesIdx > K )
%             recentAccSamplesIdx = 1;
%         end
%         sigmaA = std( recentAccSamples );
    end
end
