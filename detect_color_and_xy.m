function [highlighted_img, x_avg, y_avg,distance]= detect_color_and_xy(img, x_center, y_center)
% Function that takes an image and (x,y) pixel center point of picture
% and returns a picture with the detected color highlighted and it also
% returns the (x,y) average pixel center point of the color object
%% Bring up picture
%img=imread("yellow_bright.png");
%figure
%imshow(img);
%% Ping red color and determine threshold values
hI=rgb2hsv(img);
% figure
% imshow(hI);
hImage1=hI(:,:,1);
sImage1=hI(:,:,2);
vImage1=hI(:,:,3);
%d=impixel(hI);
%% Input threshold values for colors and find such color
%  Yellow Sticky Note    
hueTL1 = 0.10; hueTH1 = 0.16;
saturationTL1 = 0.35; saturationTH1 = 0.90;
valueTL1 = 0.60; valueTH1 = 1;

% find yellow color
hueMask1 = (hImage1 >= hueTL1)&(hImage1 <= hueTH1);
saturationMask1 = (sImage1 >= saturationTL1) & (sImage1 <= saturationTH1);
valueMask1 = (vImage1 >= valueTL1) & (vImage1 <= valueTH1);
ObjectsMask1 = hueMask1 & saturationMask1 & valueMask1;

%% Print Black out any other color and make x color white
%figure
%imshow(redObjectsMask1);
%% Fill holes
% Fill holes in image:
out2=imfill(ObjectsMask1,'holes');
% Erosion removes pixels on object boundaries:
out3=bwmorph(out2,'erode',2);
% Dilation adds pixels to the boundaries of objects in an image:
out3=bwmorph(out3,'dilate',3);
% Fill holes in image:
out3=imfill(out3,'holes');
% Display final fill in picture
%figure
%imshow(out3);
%% Display picture with yellowed out color
imgBoth=imoverlay(img,out3);
%figure
%imshow(imgBoth);
%highlighted_img=imgBoth;
%% Pixel Analysis 
% Initialize arrays
x= 0;
y = 0;
% Go through each pixel and store index of pixels with value = 1
[a, b] = size(out3);
if a >= 1 && b >=1
    for i = 1:length(out3(1,:))
        for a = 1:length(out3(:,1))
            if out3(a,i) ==1
            x_step = i;
            y_step = a;
            x = [x;x_step];
            y = [y;-y_step];
            end
        end
    end
end
%% Determine the average (x,y) of pixel values
if length(x) > 100
    % Get average values:
    x_avg = sum(x)/(length(x)-1);
    y_avg = sum(y)/(length(y)-1);
    % Insert filled center avg circle into image:
    final1 = insertShape(imgBoth,'FilledCircle',[round(abs(x_avg)) round(abs(y_avg)) 5],'LineWidth',2, 'Color','blue'); 
    % Insert filled center ext circle into image:
    final2 = insertShape(final1,'FilledCircle',[x_center y_center 5],'LineWidth',2, 'Color','red');   
    
    %Add in Point 4
    x_p4 = max(abs(x(2:end)));
    y_p4 = max(abs(y(2:end)));
    final3 = insertShape(final2,'FilledCircle',[x_p4 y_p4 5],'LineWidth',2, 'Color','magenta');
    %final4 = insertText(final3,[x_p4 y_p4],'Point 4','FontSize', 12,'BoxColor','white','TextColor','black');
    
    %Add in Point 2
    x_p2 = x_p4;
    y_p2 = y_p4 - 2 * (y_p4 - round(abs(y_avg)));
    final5 = insertShape(final3,'FilledCircle',[x_p2 y_p2 5],'LineWidth',2, 'Color','magenta');
    %final6 = insertText(final5,[x_p2 y_p2],'Point 2','FontSize', 12,'BoxColor','white','TextColor','black');
    
    %Add in Point 3
    x_p3 = x_p4 - 2 * (x_p4 - round(abs(x_avg)));
    y_p3 = y_p4;
    final7 = insertShape(final5,'FilledCircle',[x_p3 y_p3 5],'LineWidth',2, 'Color','magenta');
    %final8 = insertText(final7,[x_p3 y_p3],'Point 3','FontSize', 12,'BoxColor','white','TextColor','black');

    % Add in Point 1
    x_p1 = x_p4 - 2 * (x_p4 - round(abs(x_avg)));
    y_p1 = y_p4 - 2 * (y_p4 - round(abs(y_avg)));
    final9 = insertShape(final7,'FilledCircle',[x_p1 y_p1 5],'LineWidth',2, 'Color','magenta');
    %final10 = insertText(final9,[x_p1 y_p1],'Point 1','FontSize', 12,'BoxColor','white','TextColor','black');
    
    % X Difference
    X_Diff = max(abs(x(2:end))) - round(abs(x_avg));
    % Y Difference
    Y_Diff = max(abs(y(2:end))) - round(abs(y_avg));
    % Hypotenuse
    distance = sqrt((X_Diff^2)+(Y_Diff^2));

    % Add in Distance from center of Object
    final11 = insertShape(final9,'Line',[round(abs(x_avg)) round(abs(y_avg)) x_p4 y_p4  ],'LineWidth',2, 'Color','magenta');
    final12 = insertText(final11,[round(abs(x_avg)) round(abs(y_avg))],sprintf('Distance (px): %.2f',distance),'FontSize', 12,'BoxColor','white','TextColor','black');

    % Insert bounding box into image:
    final = insertShape(final12,'Rectangle',[(x_center-100) (y_center-50) 200 100],'LineWidth',2, 'Color','green');   
    % Set final image as output:
    highlighted_img=final;




else
    % Do not draw on image, and just output color detection picture:
    highlighted_img=imgBoth;
    % Zero out averages
    x_avg = 0;
    y_avg = 0;
    distance = 0;
end
%figure
%imshow(final);
end