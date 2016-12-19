ALL_PATIENTS_DATA_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\';

disp( 'DBN-Training on RAW-events of MSR ONLY ...' );
trainPatientsRawEventsDBNToolbox( ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_MSR' );
disp( 'Finished DBN-Training on RAW-events of MSR ONLY.' );

disp( 'DBN-Training on RAW-events of ZEPHYR ONLY ...' );
trainPatientsRawEventsDBNToolbox( ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_ZEPHYR' );
disp( 'Finished DBN-Training on RAW-events of ZEPHYR ONLY.' );

disp( 'DBN-Training on RAW-events of MSR & ZEPHYR ...' );
trainPatientsRawEventsDBNToolbox( ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_MSR_ZEPHYR' );
disp( 'Finished DBN-Training on RAW-events of MSR & ZEPHYR.' );

% NOTE: ignoring all EEG-related data because EEG causes extreme huge
% amount of data due to lots of channels and high sample rate (most of the
% channels are sampled at 200Hz)
% disp( 'DBN-Training on RAW-events of EEG ONLY ...' );
% trainPatientsRawEventsDBNToolbox( ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_EEG' );
% disp( 'Finished DBN-Training on RAW-events of EEG ONLY.' );
% 
% disp( 'DBN-Training on RAW-events of EEG & MSR ...' );
% trainPatientsRawEventsDBNToolbox( ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_EEG_MSR' );
% disp( 'Finished DBN-Training on RAW-events of EEG & MSR.' );
% 
% disp( 'DBN-Training on RAW-events of EEG & ZEPHYR ...' );
% trainPatientsRawEventsDBNToolbox( ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_EEG_ZEPHYR', WEKA_PATH );
% disp( 'Finished DBN-Training on RAW-events of EEG & ZEPHYR.' );
% 
% disp( 'DBN-Training on RAW-events of EEG & MSR & ZEPHYR ...' );
% trainPatientsRawEventsDBNToolbox( ALL_PATIENTS_DATA_PATH, 'allpatients_RAWEVENTS_EEG_MSR_ZEPHYR', WEKA_PATH );
% disp( 'Finished DBN-Training on RAW-events of EEG & MSR & ZEPHYR.' );