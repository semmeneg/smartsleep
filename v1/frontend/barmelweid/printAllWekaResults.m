%PATIENTS_DATA_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\';
%PATIENTS_DATA_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\CrossValidation\';
%PATIENTS_DATA_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\DBN\';
PATIENTS_DATA_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\DBN\CrossValidation\';

%allResultFiles = dir( [ PATIENTS_DATA_PATH '*WEKARESULT.txt' ] );
%allResultFiles = dir( [ PATIENTS_DATA_PATH 'XValidation_CROSSCLASSIFICATIONRESULT*' ] );
allResultFiles = dir( [ PATIENTS_DATA_PATH '*XValidation_DBN_allpatients_EVENTS_EEG_WEKACLASSIFICATION_CROSSCLASSIFICATIONRESULT.txt' ] );

resultFilesCount = length( allResultFiles );

for i = 1 : resultFilesCount
    result = parseWEKAResult( [ PATIENTS_DATA_PATH allResultFiles( i ).name ] );
    
    fprintf( '----------------------------------------------------------------------------------------------------\n' );
    fprintf( 'Relative CM for %s\n\n', allResultFiles( i ).name );
    fprintf( 'Total Number of Instances: %d\n', result.totalInstances );
    fprintf( 'Correctly Classified Instances: %d, %0.2f%%\n', result.corrAbs, result.corrRel );
    fprintf( 'Incorrectly Classified Instances: %d, %0.2f%%\n', result.incorrAbs, result.incorrRel );
    fprintf( 'Kappa statistic: %0.2f\n\n', result.kappa );
    
    printCMStandard( 1, result.classes, result.cmRel, true );
    fprintf( '----------------------------------------------------------------------------------------------------\n' );
    fprintf( '\n\n' );
end
