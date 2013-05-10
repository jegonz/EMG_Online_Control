%%% EMG_Cortex Parsing Serial Data
function output = EMG_Parsing(serialHandler, DESIRED_DATA_NUM)

    % Define Constants
    PACKAGESIZE = 20;

    % Init variables
    output = zeros(DESIRED_DATA_NUM,10);
    
    % search for the initial value of a package
    startByte=0;
    while (startByte ~= 255)
        startByte = fread(serialHandler, 1);
    end

    % Read serial data
    data = fread(serialHandler, (DESIRED_DATA_NUM*PACKAGESIZE))';
    
    % Retrieve all packages
    for k=0:(DESIRED_DATA_NUM-1)
        % Check for Package integrity
        checkSum = 0;
        for i=1:18
            checkSum = checkSum + data(k+1,i+19*k);
        end
        checkSum = bitand(checkSum, 255);
        % Check with trasnmitted checkSum
        if data(k+1,19+19*k) == checkSum 
            % get the counter
            output(k+1,1) =bitor(bitshift(data(k+1,2+19*k),8),(data(k+1,1+19*k)));
            
            % get the Raw Data
            j = 2;
            for i=3:2:8
                output(k+1,j) =(data(k+1,i+19*k)*100)+(data(k+1,i+19*k+1));
                j = j + 1;
            end
            
            %get the Standard Deviation
            for i=9:3:17
                output(k+1,j) =((data(k+1,i+19*k)*10000)+((data(k+1,i+19*k+1))*100)+(data(k+1,i+19*k+2)))/100;
                j = j + 1;
            end
            
            % get the Neural Network Ouput
            output(k+1, j) = bitshift(bitand(data(k+1,18+19*k),240),-4);
            
            % get the Marker
            output(k+1, j+1) = bitand(data(k+1,18+19*k),15);           
        end
    end
    % clear buffer. 
    %if serialHandler.BytesAvailable > 0 
    %    fread(serialHandler, serialHandler.BytesAvailable);
    %end
end