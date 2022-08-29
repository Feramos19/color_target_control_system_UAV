%% REU UAS - Color Detection with FPV Camera - and Mapping
%% Fenando E. Ramos Siguenza - Matt Caulfield
%% Summer 2022
%% 06/16/2022
%% Clear Workspace
clear
clc
%% Connection to Drone
parrotObj = parrot; 

%% Take off 
takeoff(parrotObj);

%% Move Up
moveup(parrotObj,1);

%% Connection to camera
camObj = camera(parrotObj,'FPV');

%% Set Center of picture values
disp('READY')
x_center = 320;
y_center = 180;

%% Create a GoogLeNET neural network object	                      
%nnet = googlenet;

%% Flying Logic
tOuter= tic;
nFrames = 0;
while(toc(tOuter)<=100 && parrotObj.BatteryLevel>10 && nFrames < 400)
   tInner = tic;
   % Perform image processing:
   picture = snapshot(camObj);                                             % Capture image from drone's FPV camera
   [pic_color, x,y,dist] = detect_color_and_xy(picture,x_center,y_center);                        % Detect color yellow in image, as well as the avg (x,y) center of yellow object
   imshow(pic_color);  % Show the picture
   % Resize the picture
   %resizedPicture = imresize(picture,[224,224]);  
   % Classify the picture
   %label = classify(nnet,resizedPicture);
   %title(char(label))          % Title of picture
   drawnow;

   %% Proportional Controller
   % Determine offsets from the center of the image:
   % Compare offset to determine the movement of the drone 
   x_off = (x-x_center);
   y_off = (y+y_center);
   
   % Get the distance from the center of the detected object from the screen
   propdist = sqrt(((x_off)^2)+((y_off)^2));

   % Create if statements with a multiplying variable attached the movements of the drone
   if propdist < 80
       z = 0.5;
       disp(('Slow Movement'))
   elseif 80 < propdist && propdist < 150
       z = 1;
       disp(('Normal Movement'))
   elseif 150 > propdist 
       z = 1.5;
       disp(('Fast Movement'))
   end

   %% Movement Left, Right, Up, and Down
   if (x_off>100) && (abs(y_off)<50) &&  toc(tOuter)>5                % if x offset from center is more than 100 pixels to the right (+), move right
        %move(parrotObj,'Roll', deg2rad(1.5*z),'Pitch',deg2rad(0.5*z))
        %disp('right');
   elseif (x_off<-100) && (abs(y_off)<50) && toc(tOuter)>5              % if x offset from center is more than 100 pixels to the left (-), move left
        %move(parrotObj,'Roll', deg2rad(-0.5*z))
        %disp('left');
   elseif (abs(x_off)<100) && (y_off>50) && toc(tOuter)>5            % if y offset from center is more than 100 pixels above (+), move up
        %move(parrotObj,0.5,'VerticalSpeed',-0.1*z) 
        %disp('up');
   elseif (abs(x_off)<100) && (y_off<-50)  && toc(tOuter)>5            % if y offset from center is more than 100 pixels below (-), move down
        %move(parrotObj,0.5,'VerticalSpeed',0.1*z)
        %disp('down');
   elseif (abs(x_off)<100) && (abs(y_off)<50) && ( 18 > dist) &&  toc(tOuter)>5
        move(parrotObj,'Pitch',deg2rad(-0.5),'Roll', deg2rad(0.77))
        disp('move foward')
   elseif (abs(x_off)<100) && (abs(y_off)<50) && (dist > 23) &&  toc(tOuter)>5
       move(parrotObj,'Pitch',deg2rad(1),'Roll', deg2rad(0.64))
       disp('move backward')
   else
        disp('hover');
   end

   %% Rotate the drone
   % turn(parrotObj,deg2rad(90));  % Turn the drone by pi/2 radians
nFrames = nFrames + 1;
end
disp('Video Has ended: Landing the drone')

%% Land the drone
land(parrotObj);
%% Create the command window and workspace 
clear parrotObj;
clear camObj;
clear;