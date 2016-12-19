WEKA_PATH = 'C:\Program Files\Weka-3-6';
PATIENTS_DATA_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\';

RATIO = 0.6;

tic

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

% EEG only
disp( 'Crossvalidation on events EEG ONLY ...' );
trainAllPatientsXVal( PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG.mat', WEKA_PATH, RATIO );
disp( 'Finished crossvalidation on events EEG ONLY.' );

% MSR only
disp( 'Crossvalidation on events MSR ONLY ...' );
trainAllPatientsXVal( PATIENTS_DATA_PATH, 'allpatients_EVENTS_MSR.mat', WEKA_PATH, RATIO );
disp( 'Finished crossvalidation on events MSR ONLY.' );

% ZEPHYR only
disp( 'Crossvalidation on events ZEPHYR ONLY ...' );
trainAllPatientsXVal( PATIENTS_DATA_PATH, 'allpatients_EVENTS_ZEPHYR.mat', WEKA_PATH, RATIO );
disp( 'Finished crossvalidation on events ZEPHYR ONLY.' );
 
% MSR & ZEPHYR
disp( 'Crossvalidation on events MSR & ZEPHYR ...' );
trainAllPatientsXVal( PATIENTS_DATA_PATH, 'allpatients_EVENTS_MSR_ZEPHYR.mat', WEKA_PATH, RATIO );
disp( 'Finished crossvalidation on events MSR & ZEPHYR.' );

% EEG & MSR
disp( 'Crossvalidation on events EEG & MSR ...' );
trainAllPatientsXVal( PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_MSR.mat', WEKA_PATH, RATIO );
disp( 'Finished crossvalidation on events EEG & MSR.' );

% EEG & ZEPHYR
disp( 'Crossvalidation on events EEG & ZEPHYR ...' );
trainAllPatientsXVal( PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_ZEPHYR.mat', WEKA_PATH, RATIO );
disp( 'Finished crossvalidation on events EEG & ZEPHYR.' );

% EEG & MSR & ZEPHYR
disp( 'Crossvalidation on events EEG & MSR & ZEPHYR ...' );
trainAllPatientsXVal( PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_MSR_ZEPHYR.mat', WEKA_PATH, RATIO );
disp( 'Finished crossvalidation on events EEG & MSR & ZEPHYR.' );

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

toc