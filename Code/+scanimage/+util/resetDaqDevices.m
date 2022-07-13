function resetDaqDevices()
hSys = dabs.ni.daqmx.System();
devNames = strsplit(hSys.devNames,', ');

success = true;
fprintf('Resetting all NI-DAQ devices... \n');
for idx = 1:length(devNames)
    devname = devNames{idx};
    try
        hDev = dabs.ni.daqmx.Device(devname);
        hDev.reset();
    catch ME
        success = false;
        most.ErrorHandler.logAndReportError(ME);
    end
end

if success
    fprintf('\bDone!\n');
end
end

%--------------------------------------------------------------------------%
% resetDaqDevices.m                                                        %
% Copyright © 2020 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2020 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
