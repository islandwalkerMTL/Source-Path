%%%%%%%%%%%%%%%%%%%%%%%%
%Description: Script pour afficher le path de la source de HDR sur des
%images d'un anneau et calculer l'ecart entre la centre de l'anneau et 
%chaque position d'arret de la source.
%
%Auteur: Ellis Mitrou (ellis.mitrou.chum@ssss.gouv.qc.ca)
%Date: 31 juillet 2015
%
%
%%%%%%%%%%%%%%%%%%%%%%%%



%Select the images to analyze
% 
[filenames,Path]=uigetfile('*.dcm','Select file','Multiselect','on');

prompt = {'How many trials will you like to average over?'};
dlg_title = 'Attempts';
num_lines = 1;
def = {'3','hsv'};
num_attempt= str2double(inputdlg(prompt,dlg_title,num_lines,def));

%num_attempt=3;
%initialize coordinate vectors
x=zeros(length(filenames),num_attempt);
y=x;



%digitilize num_attempt times to reduce uncertainty in digitilization

for attempt= 1:num_attempt
    
    for n=1:length(filenames)
        
        dcminfo_temp=dicominfo(char(filenames(n)));
        IM_TEMP=dicomread(dcminfo_temp);
        imshow(IM_TEMP);
        set(gca, 'CLim', [0, max(max(IM_TEMP))/2]);  %I found a good window level had the max around 0.5 times the image max
        % Zoom in on the ring
       
        if n==1 && attempt==1
            waitfor(msgbox('Please select ROI'));
            %msgbox('Please select ROI')
            rectangle=imrect; 
            rectDATA=rectangle.getPosition;
            delete(rectangle)
            xlim([rectDATA(1) (rectDATA(1)+rectDATA(3))])
            ylim([rectDATA(2) (rectDATA(2)+rectDATA(4))])
            waitfor(msgbox('Start Digitizing'));
            %msgbox('START DIGITIZING')
        
        else
            xlim([rectDATA(1) (rectDATA(1)+rectDATA(3))])
            ylim([rectDATA(2) (rectDATA(2)+rectDATA(4))])
        
        end
 
        %user defined coordinates
        
        
        [x(n,attempt),y(n,attempt)]=ginput;
    end
    
end
%average out the results
if num_attempt==1
    x_mean=x;
    y_mean=y;
else
    x_mean=mean(x')';
    y_mean=mean(y')';
end


hold on
%superimpose the results on the last image analyzed
plot(x_mean,y_mean,'o','color','m')

step_x=zeros(length(x_mean)-1,1);
step_y=zeros(length(x_mean)-1,1);
pixel_spacing=dcminfo_temp.ImagePlanePixelSpacing(1); %mm
delta=zeros(length(x_mean)-1,1);

imagerdistance=dcminfo_temp.XRayImageReceptorTranslation(3);
table=dcminfo_temp.TableTopVerticalPosition;
imager=dcminfo_temp.XRayImageReceptorTranslation(3);
SAD=dcminfo_temp.RadiationMachineSAD;
mag=((SAD-table)-imager)/(SAD-table);




for i=1:length(y_mean)-1
    delta(i)=pixel_spacing/mag*sqrt((x_mean(i+1)-x_mean(i))^2+(y_mean(i+1)-y_mean(i))^2);
    text((x_mean(i+1)+x_mean(i))/2,(y_mean(i+1)+y_mean(i))/2,sprintf('%.1f',delta(i)),'color','g');

    
    
end


%Draw the ring
waitfor(msgbox('Please Draw Center of the Ring'));


ring=imellipse;

h = uicontrol('Position',[20 20 200 40],'String','Done Drawing',...
              'Callback','uiresume(gcbf)');
uiwait(gcf); 
delete(h);




% Calculate the error
pos=ring.getPosition; %get ring position

ra=pos(3)/2;
rb=pos(4)/2;
xc=pos(1)+0.5*pos(3);
yc=pos(2)+0.5*pos(4);


%Calculate the distance between each point and center of the ring
RingError=pixel_spacing/mag*distancePointToEllipse(x,y,ra,rb,xc,yc);
figure
hist(RingError)














