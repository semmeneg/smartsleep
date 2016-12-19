function [ dataSet ] = generateDataSet( dataSetParams )
    % NOTE: this function generates the data-set from the given parameters 
    % each function processes the incoming dataset and adds/removes data
    % from the dataset and returns the new dataset as output

    % NOTE: this whole process works also for data-sets without activities
    % (unlabeled data). In the case that activities are absent, then
    % serveral data will be missing. The case when activities are absent
    % will be used for unlabeled test-data, the case where activities are
    % present will be used for labeled training-data for supervised
    % learning. The trained data-set can then be used to classify and
    % extract features from the unlabeled test-data
    
    % creates and sets up the basic data-set with sensor-definition,
    % loading and preprocessing of sensor-data, feature-definition and
    % component-setup, activities loading and parsing
	[ dataSet ] = setupDataSet( dataSetParams );
    
    % NOTE: the following assumptions about data are made
    % 1. in the sensors-cell array entries can be empty which means the
    %    corresponding sensor is not specified in the params
    % 2. sensors which are specified have non-empty data
    % 3. data of all sensors which have non-empty data overlap with a
    %    minimum of 1 sample
    
    % synchronize the data of the sensors: find the overlapping time-ranges
    % and discharge the non-overlapping data. when markers are specified
    % then the time in each sensor is synchronized using the first sensor
    % with markers as absolute reference point (master)
    [ dataSet ] = syncSensors( dataSet );

    % create labels for each data-point in the timeseries of each sensor by
    % iterating over all activities and matching the start/end to the
    % time-samples of the sensors. Unknown activities are ignored AND THEIR
    % CORRESPONDING DATA SAMPLES TOO => if there is a unknown label for a
    % given sample in the time-series this sample is removed from the
    % timeseries
    [ dataSet ] = processActivities( dataSet );
    
    % creates DBN-Data. Note if there are no labels persent then only the
    % raw-data is generated which would be fed to the DBN.
    [ dataSet ] = generateDBNData( dataSet );

    % trains a DBN using the previously generated DBN-Data
    % Note: it is only done if labels are present, otherwise it can't be 
    % trained (backpropagation). 
    % If labels are present, then the raw-data with the
    % labels are fed into 2 different DBN: one for feature-extraction and
    % one for classification. Both DBN will be stored in the
    % dataSet-structure and can be used later for
    % classification/feature-extraction of unlabeled data
    [ dataSet ] = trainDBN( dataSet, dataSetParams );
    
    % extracts features using the predefined components and functions
    % set-up in the function setupDataSet.  if no labels are present then
    % the features are extracted anyway but no labels are assigned.
    [ dataSet ] = extractFeatures( dataSet );
end