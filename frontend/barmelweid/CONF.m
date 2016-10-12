classdef CONF
    % Encapsulates some common configuration parameters
    %   
    
    properties(Constant)
        ALL_PATIENTS_DATA_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\';
        WEKA_PATH = 'C:\Program Files\Weka-3-8';
        ALL_PATIENTS_DBN_OUTPUT_PATH = [ CONF.ALL_PATIENTS_DATA_PATH 'DBN\' ];
        
        %data sources and combinations
        EEG = 'EEG';
        MSR = 'MSR';
        ZEPHYR = 'ZEPHYR';
        MSR_ZEPHYR = 'MSR_ZEPHYR';
        EEG_MSR = 'EEG_MSR';
        EEG_ZEPHYR = 'EEG_ZEPHYR';
        EEG_MSR_ZEPHYR = 'EEG_MSR_ZEPHYR';
    end

end
