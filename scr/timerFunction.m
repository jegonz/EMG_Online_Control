function timerFunction(serialHandler)
%global elapsedTime;
%toc(elapsedTime)
%elapsedTime = tic;

% define constants
DESIRED_DATA_NUM = 1;
FEATURES_NUMBER = 3;
WINDOW_SIZE = 100;
RECORDING_TIME = 0.4;

%% define variables
persistent timeCounter;
persistent classColor;
persistent firstPass;
persistent dataCounter;
persistent dataWindow;
persistent training;
persistent prevTestClass;
global network;
global newinfo;
global class1;
global class2;
global class3;
global class4;
global class5;

%% init variables

plotOn = 1; % to display the plots it should be 1
emgData = zeros(DESIRED_DATA_NUM,10); % this will store the raw data
emgFeatures = zeros(DESIRED_DATA_NUM,FEATURES_NUMBER); % this will store the raw data

if isempty(timeCounter) || newinfo == 0
    timeCounter = 0;
end

if isempty(classColor) || newinfo == 0
    classColor = 1;
end

if isempty(firstPass) || newinfo == 0
    firstPass = 1;
end

if isempty(dataCounter) || newinfo == 0
    dataCounter = 1;
end

if isempty(dataWindow) || newinfo == 0
    dataWindow = zeros(WINDOW_SIZE, 3);
end

if isempty(training) || newinfo == 0
    training = 1; % when training the NN it should be 1
end

newinfo = 1;

%% Main Program
if training == 1
    % just for first pass
    if firstPass == 1
        firstPass = 0;
        disp ('Start Recording with Class');
        disp ('0');
        waitforbuttonpress
        % clear buffer.
        if serialHandler.BytesAvailable > 0
            fread(serialHandler, serialHandler.BytesAvailable)
        end
        %flushinput(serialHandler);
        % start reading
        fwrite(serialHandler,'s');
    end

    if classColor <= 5
        % get data point
        emgData = EMG_Parsing(serialHandler, DESIRED_DATA_NUM);
        % only records valid data.
        if (emgData(1,1) > 0)
            % get features
            if dataCounter > 99
                % add the new value
                dataWindow(100, :) = emgData(1,2:4);
                % get features
                emgFeatures = std(dataWindow);
                %emgFeatures = mean(dataWindow);
                % shift the window one space left.
                for i=1:WINDOW_SIZE-1
                    dataWindow(i,:)=dataWindow(i+1,:);
                end

                % store data
                if classColor == 1
                    class1(timeCounter, :) = emgFeatures;
                elseif classColor == 2
                    class2(timeCounter, :) = emgFeatures;
                elseif classColor == 3
                    class3(timeCounter, :) = emgFeatures;
                elseif classColor == 4
                    class4(timeCounter, :) = emgFeatures;
                elseif classColor == 5
                    class5(timeCounter, :) = emgFeatures;
                end

            else
                dataWindow(dataCounter,:) = emgData(1,2:4);
                dataCounter = dataCounter + 1;
            end

            % check time
            if dataCounter > 99
                if timeCounter > (RECORDING_TIME/0.002) % it will record around 100 datapoints
                    % stop reading
                    fwrite(serialHandler,'s');

                    disp ('Next Class is:');
                    classColor = classColor + 1

                    waitforbuttonpress

                    % clear buffer.
                    if serialHandler.BytesAvailable > 0
                        fread(serialHandler, serialHandler.BytesAvailable)
                    end
                    %flushinput(serialHandler);
                    fwrite(serialHandler,'s');
                    dataCounter = 1;
                    timeCounter = 0;
                else
                    timeCounter = timeCounter + 1;
                end
            end
        end
    else
        % train NN

        while true
            network = trainMyFeaturesANN(class1,class2,class3,class4,class5);
            checkresult = input('Enter 0 to quit training');
            if checkresult == 0
                training = 0;
                break;
            end
        end
    end
else
    % get data point
    emgData = EMG_Parsing(serialHandler, DESIRED_DATA_NUM);
    % only records valid data.
    if (emgData(1,1) > 0)
        % get features
        if dataCounter > 99
            % add the new value
            dataWindow(100, :) = emgData(1,2:4);
            % get features
            
            emgFeatures = std(dataWindow);
            %emgFeatures = mean(dataWindow);
            % shift the window one space left.
            for i=1:WINDOW_SIZE-1
                dataWindow(i,:)=dataWindow(i+1,:);
            end
            % RUN NN
            classResult = (sign(sim(network,emgFeatures')))';
            [v,ind] = find(classResult == 1);            
            if length(ind) == 1
                disp(ind);
                prevTestClass = ind;
            else
                ind
                fprintf('\n\n');
                
                try
                    [v,testInd] = find(ind == prevTestClass);
                    prevTestClass = ind(testInd);
                    disp(prevTestClass);
                catch
                    disp('Undefined Classification Result');
                end
            end
        else
            dataWindow(dataCounter,:) = emgData(1,2:4);
            dataCounter = dataCounter + 1;
        end
    end
end

%% plot data
if plotOn == 1 && timeCounter > 1
    for k=1:DESIRED_DATA_NUM
        if classColor == 1
            scatter3(emgFeatures(k,1),emgFeatures(k,2),emgFeatures(k,3), 'or');
        elseif classColor == 2
            scatter3(emgFeatures(k,1),emgFeatures(k,2),emgFeatures(k,3), '*b');
        elseif classColor == 3
            scatter3(emgFeatures(k,1),emgFeatures(k,2),emgFeatures(k,3), '+g');
        elseif classColor == 4
            scatter3(emgFeatures(k,1),emgFeatures(k,2),emgFeatures(k,3), 'vk');
        elseif classColor == 5
            scatter3(emgFeatures(k,1),emgFeatures(k,2),emgFeatures(k,3), 'xm');
        else
            gg=1;
        end
        hold on
        pause(0.001);
    end
end

end