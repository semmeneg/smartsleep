ALL_PATIENTS_DATA_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\';
WEKA_PATH = 'C:\Program Files\Weka-3-6';

RATIO = 0.4;

tic

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

disp( 'DBN-Training on events EEG ONLY ...' );
trainPatientsFeatureEventsDBNCrossVal( ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG', WEKA_PATH, RATIO );
disp( 'Finished DBN-Training on events EEG ONLY.' );

disp( 'DBN-Training on events MSR ONLY ...' );
trainPatientsFeatureEventsDBNCrossVal( ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_MSR', WEKA_PATH, RATIO );
disp( 'Finished DBN-Training on events MSR ONLY.' );

disp( 'DBN-Training on events ZEPHYR ONLY ...' );
trainPatientsFeatureEventsDBNCrossVal( ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_ZEPHYR', WEKA_PATH, RATIO );
disp( 'Finished DBN-Training on events ZEPHYR ONLY.' );

disp( 'DBN-Training on events MSR & ZEPHYR ...' );
trainPatientsFeatureEventsDBNCrossVal( ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_MSR_ZEPHYR', WEKA_PATH, RATIO );
disp( 'Finished DBN-Training on events MSR & ZEPHYR.' );

disp( 'DBN-Training on events EEG & MSR ...' );
trainPatientsFeatureEventsDBNCrossVal( ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_MSR', WEKA_PATH, RATIO );
disp( 'Finished DBN-Training on events EEG & MSR.' );

disp( 'DBN-Training on events EEG & ZEPHYR ...' );
trainPatientsFeatureEventsDBNCrossVal( ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_ZEPHYR', WEKA_PATH, RATIO );
disp( 'Finished DBN-Training on events EEG & ZEPHYR.' );

disp( 'DBN-Training on events EEG & MSR & ZEPHYR ...' );
trainPatientsFeatureEventsDBNCrossVal( ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_MSR_ZEPHYR', WEKA_PATH, RATIO );
disp( 'Finished DBN-Training on events EEG & MSR & ZEPHYR.' );

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

toc