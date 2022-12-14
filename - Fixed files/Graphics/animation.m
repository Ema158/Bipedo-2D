function GlobalSupportfoot = animation(stored,Nsteps,name,framerate,alpha)
% Modified: 25-jul-2018 -> Victor 
% alpha -> Orientation of the robot in the plane X-Y

%ANIMATION of a robot given the joints values
% stored : configuration et vitesse articulaire g?n?r? dans le reportoire
% motion sim; Nsteps doit ?tre inf?rieur ou egal au nombre de pas simul?
% nom du fichier avi

if nargin == 4
    alpha = 0;
end

robot=genebot();
fig = figure('Position',[0 0 1000 1000]);
subplot(2,2,1);
axis([-0.3,0.3,-0.3,0.3,0,0.2]);
grid on;
set(gcf,'Renderer','zbuffer')
hold on;
subplot(2,2,2);
axis([-0.3,0.3,-0.3,0.3,0,0.2]);
grid on;
view(0,0);
set(gcf,'Renderer','zbuffer')
hold on;
subplot(2,2,3);
axis([-0.3,0.3,-0.3,0.3,0,0.2]);
grid on;
view(0,90);
set(gcf,'Renderer','zbuffer')
hold on;
subplot(2,2,4);
axis([-0.3,0.3,-0.3,0.3,0,0.2]);
grid on;
view(90,0);
set(gcf,'Renderer','zbuffer')
hold on;
writerobj = VideoWriter(strcat(name,'.avi'));
writerobj.FrameRate = framerate; % The smaller FrameRate the slower the video (Frames per second) 
open(writerobj);
reverse=-1;
x0=0;
y0=0;
COM_trace = [];
global GlobalCoMX GlobalCoMY
index = 1;
GlobalSupportfoot = zeros(3,Nsteps);  % X_s, Y_s and Psi_s
GlobalSupportfoot(1,1) = x0;
GlobalSupportfoot(2,1) = y0;
GlobalSupportfoot(3,1) = alpha;
for k = 1:Nsteps
    % stored a et? stock? pas par pas : qs : vecteur articulaire pour le
    % pas k : qs =matrice de dimension n (31) par le nombre d'?chantillon
    qs=stored{k,1};
    n=numel(qs(1,:));
    for i = 1:n        
        robot=robot_move(robot,qs(:,i));        
        if reverse==1
            RotZ_01_3x3 = [cos(alpha), -sin(alpha), 0; sin(alpha), cos(alpha), 0; 0 0 1];
            CoM_Rotated = RotZ_01_3x3*robot.CoM;
            COM_trace = [COM_trace,CoM_Rotated + [x0;y0;0]];
            GlobalCoMX = COM_trace(1,index);
            GlobalCoMY = COM_trace(2,index);
            for l=1:4
                subplot(2,2,l);
                cla;
                robot_draw(robot,x0,y0);
                plot3(COM_trace(1,:),COM_trace(2,:),COM_trace(3,:),'k','LineWidth',2);
                if l==3
                    axis([GlobalCoMX-0.3, GlobalCoMX+0.3,GlobalCoMY-0.3, GlobalCoMY+0.3, 0 0.6]);
                end
            end
        else
            RotZ_01_3x3 = [cos(-alpha), -sin(-alpha), 0; sin(-alpha), cos(-alpha), 0; 0 0 1];            
            CoM_Rotated = RotZ_01_3x3*robot.CoM;
            tempo = CoM_Rotated+[x0;-y0;0];
            tempo(2)=-tempo(2);
            COM_trace = [COM_trace,tempo];                      
            GlobalCoMX = COM_trace(1,index);
            GlobalCoMY = COM_trace(2,index);
            for l=1:4
                subplot(2,2,l);
                cla;
                robot_draw_reverse(robot,x0,y0);
                plot3(COM_trace(1,:),COM_trace(2,:),COM_trace(3,:),'k','LineWidth',2);
                if l==3
                    axis([GlobalCoMX-0.3, GlobalCoMX+0.3,GlobalCoMY-0.3, GlobalCoMY+0.3, 0 0.6]);
                end
            end
        end
        writeVideo(writerobj,getframe(fig));
        if (k==1 && i==1) || (k==Nsteps && i==n)
            for cont = 1:framerate   % Recording of the initial and final position ("framerate" times)
                                     %  in order to see the initial and final configuration of the Robot
                writeVideo(writerobj,getframe(fig));
            end
        end
        index = index + 1;
    end
    % for the next step...
    foot = RotZ_01_3x3*robot.T(1:3,4,7);
    frameFoot = RotZ_01_3x3*robot.T(1:3,1:3,8)*robot.Tconst(1:3,1:3,8); %DEbido a que el marco 14 no esta aliniado al marco del mundo
    YawFootRotation = atan2(frameFoot(2,1),frameFoot(1,1));  %Se alinea al marco del mundo en posicion 0
    if mod(k,2)==0
        alpha = - YawFootRotation;
    else
        alpha = YawFootRotation;
    end

    x0 = x0+foot(1);
    y0 = y0+reverse*foot(2);
    
    reverse = -reverse;
    GlobalSupportfoot(1,k+1) = x0;
    GlobalSupportfoot(2,k+1) = y0;
    GlobalSupportfoot(3,k+1) = alpha;
end
close(writerobj);