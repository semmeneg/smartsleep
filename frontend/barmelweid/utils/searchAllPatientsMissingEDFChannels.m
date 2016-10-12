% % NOTE: this are all channels
% REQUIRED_EDF_SIGNALS = { 'Re Bein', 'EKG', 'Li Bein', 'Kinn 1', 'REF', ...
%     'E1-M2', 'E2-M1', 'C3-M2', 'C4-M1', 'O1-M2', 'O2-M1', 'F3-M2', ...
%     'F4-M1', 'Thermistor', 'Thorax', 'Abdomen', 'SpO2', 'Flow_DR', ...
%     'Snore_DR', 'Position_DR' };

% NOTE: this are the polysomnography-only channels
REQUIRED_EDF_SIGNALS = { 'Kinn 1', 'Re Bein', 'Li Bein', 'E1-M2', ...
    'E2-M1', 'C3-M2', 'C4-M1', 'O1-M2', 'O2-M1', 'F3-M2', 'F4-M1' };

ALL_PATIENTS_PATH = 'E:\FH\Job\SmartSleep Data\Barmelweid\SmartSleepPatienten\';

files = dir( [ ALL_PATIENTS_PATH 'Patient*' ] );
dirFlags = [ files.isdir ];
allPatientFolders = files( dirFlags );

patientCount = length( allPatientFolders );
    
allMissingChannels = cell( patientCount, 1 );
allEdfFileNames = cell( patientCount, 1 );

for i = 1 : patientCount
    edfFile = dir( [ ALL_PATIENTS_PATH allPatientFolders( i ).name '\EDF\*.edf' ] );
    edfFileName = [ ALL_PATIENTS_PATH allPatientFolders( i ).name '\EDF\' edfFile.name ];
    
    fprintf( 'Checking %s... ', edfFileName );
    allMissingChannels{ i } = listMissingEDFChannels( edfFileName, REQUIRED_EDF_SIGNALS );
    allEdfFileNames{ i } = edfFileName;
    fprintf( 'finished.\n' );
end