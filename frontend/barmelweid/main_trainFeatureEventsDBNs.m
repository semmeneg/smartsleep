
tic

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

 disp( 'DBN-Training on events EEG ONLY ...' );
 trainPatientsFeatureEventsDBN( 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\', 'allpatients_EVENTS_EEG', 'C:\Program Files\Weka-3-8' );
 disp( 'Finished DBN-Training on events EEG ONLY.' );

% disp( 'DBN-Training on events MSR ONLY ...' );
% trainPatientsFeatureEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_MSR', CONF.WEKA_PATH );
% disp( 'Finished DBN-Training on events MSR ONLY.' );

% disp( 'DBN-Training on events ZEPHYR ONLY ...' );
% trainPatientsFeatureEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_ZEPHYR', CONF.WEKA_PATH );
% disp( 'Finished DBN-Training on events ZEPHYR ONLY.' );

% disp( 'DBN-Training on events MSR & ZEPHYR ...' );
% trainPatientsFeatureEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_MSR_ZEPHYR', CONF.WEKA_PATH );
% disp( 'Finished DBN-Training on events MSR & ZEPHYR.' );
% 
% disp( 'DBN-Training on events EEG & MSR ...' );
% trainPatientsFeatureEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_MSR', CONF.WEKA_PATH );
% disp( 'Finished DBN-Training on events EEG & MSR.' );
% 
% disp( 'DBN-Training on events EEG & ZEPHYR ...' );
% trainPatientsFeatureEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_ZEPHYR', CONF.WEKA_PATH );
% disp( 'Finished DBN-Training on events EEG & ZEPHYR.' );
% 
%disp( 'DBN-Training on events EEG & MSR & ZEPHYR ...' );
%trainPatientsFeatureEventsDBN( CONF.ALL_PATIENTS_DATA_PATH, 'allpatients_EVENTS_EEG_MSR_ZEPHYR', CONF.WEKA_PATH );
%disp( 'Finished DBN-Training on events EEG & MSR & ZEPHYR.' );

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );

toc