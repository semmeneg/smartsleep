CLASSIFICATION_TEST_FOLDER = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\ClassificationTests\';

patientUnclassifiedArffFile = [ CLASSIFICATION_TEST_FOLDER 'Patient06 ShLi_EXTRACTEDWINDOWS_30_EDF.arff' ];

trainedModelFileAllEvents_EXCLUDINGPATIENT = [ MODEL_FILES_PATH 'allpatients_NOPATIENT06_TRAINEDEVENTS_EDF.model' ];
trainedModelFile30SecsEvents_EXCLUDINGPATIENT = [ MODEL_FILES_PATH 'allpatients_NOPATIENT06_ONLY30SECEVENTS_TRAINEDEVENTS_EDF.model' ];

trainedModelFileAllEvents_INCLUDINGPATIENT = [ MODEL_FILES_PATH 'allpatients_TRAINEDEVENTS_EDF.model' ];
trainedModelFile30SecsEvents_INCLUDINGPATIENT = [ MODEL_FILES_PATH 'allpatients_ONLY30SECEVENTS_TRAINEDEVENTS_EDF.model' ];

wekaPath = 'C:\Program Files\Weka-3-6';
windowLength = 30;

[ classifiedLabelsAllEventsExcludingPatient, errorsAllEventsExcludingPatient ] = classifyPatient( patientUnclassifiedArffFile, trainedModelFileAllEvents_EXCLUDINGPATIENT, wekaPath, windowLength );
[ classifiedLabels30SecEventsExcludingPatient, errors30SecEventsExcludingPatient ] = classifyPatient( patientUnclassifiedArffFile, trainedModelFile30SecsEvents_EXCLUDINGPATIENT, wekaPath, windowLength );

[ classifiedLabelsAllEventsIncludingPatient, errorsAllEventsIncludingPatient ] = classifyPatient( patientUnclassifiedArffFile, trainedModelFileAllEvents_INCLUDINGPATIENT, wekaPath, windowLength );
[ classifiedLabels30SecEventsIncludingPatient, errors30SecEventsIncludingPatient ] = classifyPatient( patientUnclassifiedArffFile, trainedModelFile30SecsEvents_INCLUDINGPATIENT, wekaPath, windowLength );

figure;
plot( classifiedLabelsAllEventsExcludingPatient )
axis( [ 0 inf 2 8 ] );
figure;
plot( classifiedLabels30SecEventsExcludingPatient )
axis( [ 0 inf 2 8 ] );

figure;
plot( classifiedLabelsAllEventsIncludingPatient )
axis( [ 0 inf 2 8 ] );
figure;
plot( classifiedLabels30SecEventsIncludingPatient )
axis( [ 0 inf 2 8 ] );

patientEventsMatFile = [ CLASSIFICATION_TEST_FOLDER 'Patient06 ShLi_TRAINEDEVENTS_EDF.mat' ];
load( patientEventsMatFile );

figure;
plot( patient.combinedLabels )
axis( [ 0 inf 0 8 ] );

only30SecEventsIdx = find( patient.combinedLabels >= 3 );
only30SecEvents = patient.combinedLabels( only30SecEventsIdx );

figure;
plot( only30SecEvents )
axis( [ 0 inf 2 8 ] );