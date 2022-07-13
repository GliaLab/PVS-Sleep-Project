function sendSupportReport()
    filePath = fullfile(tempdir(),'SIReport.zip');
    try
        scanimage.util.generateSIReport(false,filePath);
    catch ME
        message = sprintf('Failed to generate support report:\n%s',ME.message);
        msgbox(message,'Error','error');
        rethrow(ME);
    end
    
    hLM = scanimage.util.private.LM();
    collect = hLM.collectUsageData;
    hLM.collectUsageData = true;
    success = hLM.log(filePath,'Support report submitted.');
    hLM.collectUsageData = collect;
    
    if ~success
        msgbox('Failed to send support report','Error','error');
        error('Failed to send support report.');
    end
end

%--------------------------------------------------------------------------%
% sendSupportReport.m                                                      %
% Copyright © 2020 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2020 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
