function network = trainMyFeaturesANN(Class1Points,Class2Points,Class3Points,Class4Points,Class5Points)
%%%%%%%%%%%%%%%%%%%%%%%%%%FEATURE EXTRACTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%PREPARE TRAIN & TEST DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Feature Training Data P and Class Value D All class combined
P(  1:100,:) = Class1Points([1:25 51:75 126:150 176:200],:);
P(101:200,:) = Class2Points([1:25 51:75 126:150 176:200],:);
P(201:300,:) = Class3Points([1:25 51:75 126:150 176:200],:);
P(301:400,:) = Class4Points([1:25 51:75 126:150 176:200],:);
P(401:500,:) = Class5Points([1:25 51:75 126:150 176:200],:);

D = ones(500,5)*(-1);
D(  1:100,1) = 1;
D(101:200,2) = 1;
D(201:300,3) = 1;
D(301:400,4) = 1;
D(401:500,5) = 1;

%%Feature Test Data Q and Class Value R All class combined
Q(  1:100,:) = Class1Points([26:50 76:125 151:175],:);
Q(101:200,:) = Class2Points([26:50 76:125 151:175],:);
Q(201:300,:) = Class3Points([26:50 76:125 151:175],:);
Q(301:400,:) = Class4Points([26:50 76:125 151:175],:);
Q(401:500,:) = Class5Points([26:50 76:125 151:175],:);


R = D;


% %Normalize data
% P = P*50;
% Q = Q*50;
% X = X*50;

% P = P/100;
% Q = Q/100;
% X = X/100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ANN TRAIN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%TRAINING

%%
InVecMidPoints=(max(P)+min(P))/2;
InVecRanges=(max(P)-min(P))/2;

% With this code, you can study different learning algorithms
NETINDIM  = 3;
HID       = 5;
NETOUTDIM = 5;

% Determine the range of the data
PR = [min(P)'  max(P)'];

% Form the network - Levenberg Marquardt Training Law
net = newff(PR,[HID NETOUTDIM],{'tansig' 'purelin'},'trainlm');


% Loop for 100 epoches
net.trainParam.epochs    = 1.5*1e2;
% Memory reduction rate
net.trainParam.mem_reduc = 1;
% Show after every iteration
net.trainParam.show      = 1;
% Stopping MSE level
net.trainParam.goal      = 1e-10;

% %Validation Data
% VV.P=X';
% VV.T=Y';

% Test Data
HH.P=Q';
HH.T=R';


% Train the network
% [net,tr,Y2,E2,Pf2,Af2] = train(net,P',D',[],[],VV,HH);
[net,tr,Y2,E2,Pf2,Af2] = train(net,P',D');

% Print the results on the screen
Tau = sim(net,P');
% Print the error E
E = D'-Tau;
figure(2)
plot([1:length(D)],D,'-r',[1:length(Tau)],Tau,'-k')
% Save your network weights etc.

TAVTEST = sign(sim(net,Q')); 
RES = TAVTEST'; z = RES == -1; RES(z) = 0;
fprintf(  'Class1 Test Result %d  %d  %d  %d  %d\n',  sum(RES(1:100,:))     );
fprintf(  'Class2 Test Result %d  %d  %d  %d  %d\n',  sum(RES(101:200,:))   );
fprintf(  'Class3 Test Result %d  %d  %d  %d  %d\n',  sum(RES(201:300,:))  );
fprintf(  'Class4 Test Result %d  %d  %d  %d  %d\n',  sum(RES(301:400,:))  );
fprintf(  'Class5 Test Result %d  %d  %d  %d  %d\n',  sum(RES(401:500,:))  );
disp('End of Trainign Process');
network = net;


