% Call only Weka training with paths to already existing data (from DBN)

CONF.setup();

subfolder = '2016-10-18_00-02-23_PatientsGrouped_DNBRatio90-10-00/';

fileNamePathPrefix = [ CONF.getOutputPath '\' subfolder 'allpatients_EVENTS_' CONF.EEG ];
trainWEKAModel( CONF.WEKA_PATH , [ fileNamePathPrefix '_DBNFEATURES.arff' ], [ fileNamePathPrefix '____test________DBNFEATURES.model' ], ...
        [ fileNamePathPrefix '____test________DBNFEATURES_WEKARESULT.txt' ] );
    
 