% Call only Weka training with paths to already existing data (from DBN)

setenv('JAVA_HOME','C:\Program Files\Java\jdk1.8.0_101');
setenv('PATH','C:\Program Files\Java\jdk1.8.0_101\bin');

fileNamePathPrefix = [ CONF.ALL_PATIENTS_DBN_OUTPUT_PATH 'allpatients_EVENTS_' CONF.MSR ];
trainWEKAModel( CONF.WEKA_PATH , [ fileNamePathPrefix '_DBNFEATURES.arff' ], [ fileNamePathPrefix '_DBNFEATURES.model' ], ...
        [ fileNamePathPrefix '_DBNFEATURES_WEKARESULT.txt' ] );
    
 