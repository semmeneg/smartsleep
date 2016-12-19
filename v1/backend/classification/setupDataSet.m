function [ dataSet ] = setupDataSet( dataSetParams )
%CALCTRAININGSETCOMBINED Summary of this function goes here
%   Detailed explanation goes here

    activitiesInfo = [];
    
    % need to pre-allocate all sensors because otherwise indexing of
    % component-definition would not work. 
    % 1: MSR-WRIST
    % 2: MSR-ANKLE
    % 3: BASIS
    % 4: MOBILE-ACCELEROMETER
    % 5: MOBILE-SPEED
    % 6: MOBILE-GYRO
    allSensors = { [], [], [], [], [], [] };
    
    componentIdx = [];
    compNames = [];
    compFeat = [];
    
    classNames = { 'lying_general', 'lying_reading', 'lying_meditation', 'lying_sleeping', ...
        'sitting_general', 'sitting_reading', 'sitting_tv', 'sitting_pcwork', 'sitting_meditation', 'sitting_car_passive', 'sitting_car_driving' 'sitting_bus', 'sitting_train', ...
        'standing_general', 'standing_bus', 'standing_train', ...
        'walking_general', 'walking_stairs_up', 'walking_stairs_down', ...
        'housework', ...
        'running_general', ...
        'sports_jogging', 'sports_cycling', 'sports_hiking', ...
        'user_class_A', 'user_class_B', 'user_class_C' };
    
    % the functions of the features
    featureFuncs = { @meanFeature, @skewnessFeature, @rootMeanSquareFeature, ...
            @stdFeature, @energyFeature, @entropyFeature, @maxFreqFeature, ...
            @vecNormFeature, @sumFeature, @corrCoefMeanFeature };
    % allows to input the given number of past features into the current
   
    % holds the names of all features 
    featureNames = { 'mean', 'skewness', 'rms', 'std', 'energy', ...
        'entropy', 'maxFreq', 'norm', 'sum', 'corrCoefMean' };
    % holds the feature-calculation informations
    featureInfo = struct( 'funcs', { featureFuncs }, ...
        'names', { featureNames }, ...
        'windowTime', 6700, ...
        'overlapTime', 3350, ...
        'dbnSampling', 20 );

    accelerationRanges = { [-2.0 2.0], [-2.0 2.0], [-2.0 2.0] };
    
    % no sensors-field specified - error, we cannot process further
    if ( ~isfield( dataSetParams, 'sensors' ) )
        error( 'ERROR: no sensors in data-set parameters specified - exit.' );
    end
    
     % activities are specified, treat as training-set
    % if not specified, just export data without labels
    if ( isfield( dataSetParams, 'activities' ) )
        activitiesFileName = dataSetParams.activities;
        [ pathstr, name, ext ] = fileparts( activitiesFileName ); 
    
        if ( strcmpi( '.csv', ext ) )
            activitiesInfo = importActivityCSV( classNames, activitiesFileName );
        elseif ( strcmpi( '.mat', ext ) )
            % creates activitiesInfo in Workspace
            load( activitiesFileName );
        else
            error( 'Unknown activities file-format - exit' );
        end
    end
    
    % attach classes in activities
    activitiesInfo.classes = classNames;
    
    % MSR-sensor(s) specified
    if ( isfield( dataSetParams.sensors, 'msr' ) )
        % msr wrist-sensor specified
        if ( isfield( dataSetParams.sensors.msr, 'wrist' ) )
            % defines the components where each component is defined by a matrix
            % where the 
            componentIdx = { 
                [ 1 1 ], ...                % x-achsis  MSR WRIST
                [ 1 2 ], ...                % y-achsis  MSR WRIST
                [ 1 3 ], ...                % z-achsis  MSR WRIST
                [ 1 1; 1 2; 1 3; ]          % vector    MSR WRIST
            };

             % define the names of the features
            compNames = { 'x_MSR_WRIST', 'y_MSR_WRIST', 'z_MSR_WRIST', 'vec_MSR_WRIST' };

            % for each component, define a vector of indices specifying the
            % features to be calculated for this component
            compFeat = { 1 : 7, 1 : 7, 1 : 7, 8 };

            msrSensorWrist = struct( 'fileName', dataSetParams.sensors.msr.wrist, ...
                'name', 'MSR_WRIST', ...
                'channels', struct( 'names', { { 'ACC_x', 'ACC_y', 'ACC_z' } }, ...
                    'ranges', { accelerationRanges }, ...
                    'negative', { { true, true, true } } ), ...
                'data', [] );

            msrSensorWrist = preprocessMSR( msrSensorWrist );

            allSensors{ 1 } = msrSensorWrist;
        end

        % msr ankle-sensor specified
        if ( isfield( dataSetParams.sensors.msr, 'ankle' ) )
            % defines the components where each component is defined by a matrix
            % where the 
            componentIdx{ end + 1 } = [ 2 1 ];                % x-achsis  MSR ANKLE
            componentIdx{ end + 1 } = [ 2 2 ];                % y-achsis  MSR ANKLE
            componentIdx{ end + 1 } = [ 2 3 ];                % z-achsis  MSR ANKLE
            componentIdx{ end + 1 } = [ 2 1; 2 2; 2 3; ];     % vector    MSR ANKLE

             % define the names of the features
            compNames{ end + 1 } = 'x_MSR_ANKLE';
            compNames{ end + 1 } = 'y_MSR_ANKLE';
            compNames{ end + 1 } = 'z_MSR_ANKLE';
            compNames{ end + 1 } = 'vec_MSR_ANKLE';

            % for each component, define a vector of indices specifying the
            % features to be calculated for this component
            compFeat{ end + 1 } = 1 : 7;
            compFeat{ end + 1 } = 1 : 7;
            compFeat{ end + 1 } = 1 : 7;
            compFeat{ end + 1 } = 8;

            msrSensorAnkle = struct( 'fileName', dataSetParams.sensors.msr.ankle, ...
                'name', 'MSR_ANKLE', ...
                'channels', struct( 'names', { { 'ACC_x', 'ACC_y', 'ACC_z' } }, ...
                    'ranges', { accelerationRanges }, ...
                    'negative', { { true, true, true } } ), ...
                'data', [] );

            msrSensorAnkle = preprocessMSR( msrSensorAnkle );

            % both msr-sensors specified
            if ( ~isempty( allSensors{ 1 } ) )
                % defines the components where each component is defined by a matrix
                % where the 
                componentIdx{ end + 1 } = [ 1 1; 1 2; 1 3; 2 1; 2 2; 2 3; ];      % vector    MSR WRIST and MSR ANKLE

                % define the names of the features
                compNames{ end + 1 } = 'vec_2_MSRK_WRIST_ANKLE';

                % NOTE: if both sensors are put on we assume that both are
                % started from the same PC and will have (about) the same local
                % time (differing maybe in milliseconds). thus if markers are
                % present in the wrist MSR then copy them to ankle MSR IF THERE
                % ARE NO MARKERS PRESENT IN ankle MSR!
                msrSensorAnkle = generateMSRMarkersFromOther( msrSensorAnkle, msrSensorWrist );

                compFeat{ end + 1 } = 10;
            end

            allSensors{ 2 } = msrSensorAnkle;
        end
    end
    
    % specified a basis-sensor file-name, specify additional info
    if ( isfield( dataSetParams.sensors, 'basis' ) )
        componentIdx{ end + 1 } = [ 3 1 ];  % heartrate BASIS
        componentIdx{ end + 1 } = [ 3 2 ];  % steps BASIS
        
        compNames{ end + 1 } = 'hr_BASIS';
        compNames{ end + 1 } = 'steps_BASIS';
        
        compFeat{ end + 1 } = 1;
        compFeat{ end + 1 } = 1;

        basisSensorWrist = struct( 'fileName', dataSetParams.sensors.basis, ...
            'name', 'BASIS_WRIST', ...
            'channels', struct( 'names', { { 'heartrate', 'steps' } }, ...
                'ranges', { { [40 180], [0 200] } }, ...
                'negative', { { false, false } } ), ...
            'data', [] );
        
        % TODO: do not rely on other sensor. need to define the correct day
        startTime = msrSensorWrist.time( end, 1 );
        dayStr = datestr( unixTimeToMatlabTime( startTime / 1000 ), 'yyyy-mm-dd' );
    
        % NOTE: no need for markers to detect start because sampling rate
        % is so low (60seconds) which will make no difference even if we
        % differ by 10 seconds
        
        basisSensorWrist = preprocessBASIS( basisSensorWrist, dayStr );
    
        allSensors{ 3 } = basisSensorWrist;
    end
    
    % specified a mobile accelerometer-sensor
    if ( isfield( dataSetParams.sensors, 'mobile' ) )
        if ( isfield( dataSetParams.sensors.mobile, 'acc' ) )
            componentIdx{ end + 1 } = [ 4 1 ];                % x-achsis  MOBILE ACC
            componentIdx{ end + 1 } = [ 4 2 ];                % y-achsis  MOBILE ACC
            componentIdx{ end + 1 } = [ 4 3 ];                % z-achsis  MOBILE ACC
            componentIdx{ end + 1 } = [ 4 1; 4 2; 4 3; ];     % vector    MOBILE ACC

             % define the names of the features
            compNames{ end + 1 } = 'x_MOBILE_ACC';
            compNames{ end + 1 } = 'y_MOBILE_ACC';
            compNames{ end + 1 } = 'z_MOBILE_ACC';
            compNames{ end + 1 } = 'vec_MOBILE_ACC';

            % for each component, define a vector of indices specifying the
            % features to be calculated for this component
            compFeat{ end + 1 } = 1 : 7;
            compFeat{ end + 1 } = 1 : 7;
            compFeat{ end + 1 } = 1 : 7;
            compFeat{ end + 1 } = 8;

            mobileAccelerometer = struct( 'fileName', dataSetParams.sensors.mobile.acc, ...
                'name', 'MOBILE_ACC', ...
                'channels', struct( 'names', { { 'x', 'y', 'z' } }, ...
                    'ranges', { accelerationRanges }, ...
                    'negative', { { true, true, true } } ), ...
                'data', [] );

            mobileAccelerometer = preprocessMobileAcc( mobileAccelerometer );
            mobileAccelerometer = generateMobileMarkers( mobileAccelerometer, activitiesInfo );

            allSensors{ 4 } = mobileAccelerometer;
        end

        % specified a mobile speed-sensor
        if ( isfield( dataSetParams.sensors.mobile, 'speed' ) )
            componentIdx{ end + 1 } = [ 5 1 ];  % speed MOBILE 

            compNames{ end + 1 } = 'speed_MOBILE';

            compFeat{ end + 1 } = 1;

            mobileSpeed = struct( 'fileName', dataSetParams.sensors.mobile.speed, ...
                'name', 'MOBILE_SPEED', ...
                'channels', struct( 'names', { { 'm/s' } }, ...
                    'ranges', { { [ 0 50 ] } }, ...
                    'negative', { { false } } ), ...
                'data', [] );

            mobileSpeed = preprocessMobileSpeed( mobileSpeed );
            mobileSpeed = generateMobileMarkers( mobileSpeed, activitiesInfo );

            allSensors{ 5 } = mobileSpeed;
        end

        % specified a mobile gyroscope-sensor
        if ( isfield( dataSetParams.sensors.mobile, 'gyro' ) )
            componentIdx{ end + 1 } = [ 6 1 ];  % gyro MOBILE 

            compNames{ end + 1 } = 'gyro_MOBILE';

            compFeat{ end + 1 } = 1;

            % TODO: i don't know the ranges of a gyroscope, adjust

            mobileGyro = struct( 'fileName', dataSetParams.sensors.mobile.gyro, ...
                'name', 'MOBILE_GYRO', ...
                'channels', struct( 'names', { { 'x', 'y', 'z' } }, ...
                    'ranges', { accelerationRanges }, ...
                    'negative', { { true, true, true } } ), ...
                'data', [] );

            mobileGyro = preprocessMobileGyro( mobileGyro );
            mobileGyro = generateMobileMarkers( mobileGyro, activitiesInfo );

            allSensors{ 6 } = mobileGyro;
        end
    end
    
    componentInfo = struct( 'components', { componentIdx }, ...
        'names', { compNames' }, 'features', { compFeat } ); 
    
    dataSet = struct( 'sensors', { allSensors }, ...           
        'featureInfo', featureInfo, ...
        'activitiesInfo', activitiesInfo, ...
        'componentInfo', componentInfo, ...
        'info', { struct( 'name', dataSetParams.name ) } );
end
