% DRAW_POSE visualize the pose in a single frame of a gesture.
% Usage: 
%       draw_pose(frame);
% Example:
%       draw_pose(gestures{1}{1}(:,1));
%
function draw_pose(frame)

head = frame(1:3);
neck = frame(4:6);
left_shoulder = frame(7:9);
left_elbow = frame(10:12);
left_hand = frame(13:15);
right_shoulder = frame(16:18);
right_elbow = frame(19:21);
right_hand = frame(22:24);
torso = frame(25:27);
left_hip = frame(28:30);
right_hip = frame(31:33);

plot3([head(1) neck(1)],[head(3) neck(3)],[-head(2) -neck(2)],'LineWidth',4);
hold on;
plot3([neck(1) left_shoulder(1)],[neck(3) left_shoulder(3)],[-neck(2) -left_shoulder(2)],'LineWidth',4);
plot3([left_elbow(1) left_shoulder(1)],[left_elbow(3) left_shoulder(3)],[-left_elbow(2) -left_shoulder(2)],'LineWidth',4);
plot3([left_elbow(1) left_hand(1)],[left_elbow(3) left_hand(3)],[-left_elbow(2) -left_hand(2)],'LineWidth',4);

plot3([neck(1) right_shoulder(1)],[neck(3) right_shoulder(3)],[-neck(2) -right_shoulder(2)],'LineWidth',4);
plot3([right_elbow(1) right_shoulder(1)],[right_elbow(3) right_shoulder(3)],[-right_elbow(2) -right_shoulder(2)],'LineWidth',4);
plot3([right_elbow(1) right_hand(1)],[right_elbow(3) right_hand(3)],[-right_elbow(2) -right_hand(2)],'LineWidth',4);

plot3([torso(1) left_shoulder(1)],[torso(3) left_shoulder(3)],[-torso(2) -left_shoulder(2)],'LineWidth',4);
plot3([torso(1) right_shoulder(1)],[torso(3) right_shoulder(3)],[-torso(2) -right_shoulder(2)],'LineWidth',4);

plot3([torso(1) left_hip(1)],[torso(3) left_hip(3)],[-torso(2) -left_hip(2)],'LineWidth',4);
plot3([torso(1) right_hip(1)],[torso(3) right_hip(3)],[-torso(2) -right_hip(2)],'LineWidth',4);
plot3([left_hip(1) right_hip(1)],[left_hip(3) right_hip(3)],[-left_hip(2) -right_hip(2)],'LineWidth',4);

grid on;
hold off;

xlabel('x axis');
ylabel('z axis');
zlabel('y axis');

s = 0.5;
axis([-s s -s s -s s]);
%camorbit(0,0);