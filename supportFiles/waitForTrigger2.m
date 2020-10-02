function trigTime = waitForTrigger2(trigKeys)

% This function makes use of KbQueue functions to start the kidWriting.m
% after receiving a 'trigger' from the scanner. The 'trigger' is `.

deviceID=-1;

% List of vendor IDs. My Mac is 1492. Isobel is 1452. Commercial tablet is 1636.
vendorIDs = [1003 1492 1452];

% Get all devices.
devices = PsychHID('Devices');

% Loop through all KEYBOARD devices with the vendorID of FORP's vendor:
for i=1:size(devices,2)
    if (strcmp(devices(i).usageName,'Keyboard') && ismember(devices(i).vendorID, vendorIDs))
        deviceID=i;
        break;
    end
end

% Wait for trigger. Note: This function doesn't respond to ctrl+. !
trigTime = KbTriggerWait(KbName(trigKeys), deviceID);

