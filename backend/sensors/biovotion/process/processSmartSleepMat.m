function [ ] = processSmartSleepMat( inputFileName, outputFileName, genXCovPlotsFlag, genArffsFlag, genEdgeDetectFlag )
    fprintf( 'Processing %s ...\n', inputFileName );
        
    % calculate the path of the outputFileName
    outputPath = outputFileName( 1 : find( outputFileName == '\', 1, 'last' ) );
    
    % load .mat file into workspace -> creates DSout struct-variable
    load( inputFileName );
    
    % kernel width for smoothing
    SMOOTHING_KERNEL_WIDTH = 25;
    
    % start with original data to clean
    DSoutCleaned = DSout;
    % remove NaNs and outliers
    for i = 1 : size( DSout.Sensors.data, 2 )
        % removing outliers could result again in NaNs due to interpolation
        % -> remove NaNs again (dont worry, its fast)
        DSoutCleaned = removeNan( removeOutliers( removeNan( DSoutCleaned, i ), i ), i );
    end
    
    % smoothed values are based upon the cleaned values
    DSoutSmoothed = DSoutCleaned;
    % apply moving average-filter with a kernel width of SMOOTHING_KERNEL_WIDTH samples
    for i = 1 : size( DSout.Sensors.data, 2 )
        DSoutSmoothed = smooth( DSoutSmoothed, i, SMOOTHING_KERNEL_WIDTH );
    end
    
    % normalized values are based upon the cleaned values
    DSoutNormalized = DSoutCleaned;
    % apply normalization to move mean to 0.0 and std to 1.0
    for i = 1 : size( DSout.Sensors.data, 2 )
        DSoutNormalized = normalize( DSoutNormalized, i );
    end
    
    cleanedOutputFileName = sprintf( '%s_cleaned.mat', outputFileName( 1 : end - 4 ) );
    smoothedOutputFileName = sprintf( '%s_smoothed.mat', outputFileName( 1 : end - 4 ) );
    normedOutputFileName = sprintf( '%s_normalized.mat', outputFileName( 1 : end - 4 ) );
    
    % store cleaned .mat data 
    save( cleanedOutputFileName, 'DSoutCleaned' );
    % store smoothed .mat data
    save( smoothedOutputFileName, 'DSoutSmoothed' );
    % store normed .mat data 
    save( normedOutputFileName, 'DSoutNormalized' );
    
    if ( genEdgeDetectFlag && strcmp( outputFileName( end - 9: end ), 'DS_res.mat' ) )
        data = DSoutCleaned;
        
        for i = 3 : 5
            genEdgeDetectFigures( data, i, sprintf( '%sEdgeDetect_%s', outputPath, data.Sensors.vnames{ :, i } ) );
        end
    end
    
    % generate .arff-files if required
    if ( genArffsFlag )
        cleanedArffFileName = sprintf( '%s_cleaned.arff', outputFileName( 1 : end - 4 ) );
        smoothedArffFileName = sprintf( '%s_smoothed.arff', outputFileName( 1 : end - 4 ) );
        normedArffFileName = sprintf( '%s_normalized.arff', outputFileName( 1 : end - 4 ) );

        genArff( DSoutCleaned, cleanedArffFileName );
        genArff( DSoutSmoothed, smoothedArffFileName );
        genArff( DSoutNormalized, normedArffFileName );
    end
    
     % generate correlation plots if required (only for DS_res.arff)
    if ( genXCovPlotsFlag && strcmp( outputFileName( end - 9: end ), 'DS_res.mat' ) )
        xCovOutputFilePath = sprintf( '%sXCOV_NORM', outputPath );
        
        % generate png-files of xcov plots
        genXCovPlots( DSoutNormalized, xCovOutputFilePath );
    end
end
