%% System Parameters
m_w = 0.040;     % wheel mass (kg)
m_b = 0.708;     % body mass (kg)
r   = 0.0325;    % wheel radius(m)
L   = 0.042;     % distance of CoM (m)
g   = 9.81;      % gravity acceleration(m/s^2)
I_b = 0.0014455; % moment of inertia of the body (kg.m^2)

%% Derived Constants
M1 = 3*m_w + m_b;
M2 = m_b * L;
I_t = m_b*L^2 + I_b;
Dt = M1*I_t- M2^2; %determinant

%% State-space Matrices
A = [0 1 0 0; 0 0 -M2*m_b*g*L/Dt 0; 0 0 0 1; 0 0 M1 *m_b*g*L/Dt 0];
B = [0; (I_t/r +M2)/Dt; 0; -(M1+M2/r)/Dt ];
C = eye(4); %identity matrix (create 4x4 matrix)
D = zeros(4,1); % create 4x1 zero matrix
%C and D matrices are output matrices: y = Cq +Du

sys_open = ss(A,B,C,D); % create a continuous-time state-space model 

%% LQR Massive Matrices 
Q = diag([1,1,100,1]); % x,xdot,theta,thetadot
R= 5; % control effort penalty(1 input).Selected from R sweep(R=1...500); R=1 rejected:peak torque exceeded actuator limit 

%% LQR Gain Calculating
[K,S,P] = lqr(A,B,Q,R); % K= 1x4 gain factor [K1,K2,K3,K4] for [x,xdot,theta,thetadot]
                        % S= Solution of the P matrix via Ricatti Equation [4x4]
                        % P= Close-loop eigenvalues 
fprintf( 'LQR Gain Factor K;\n');
fprintf( ' K(x) = %4f\n',K(1));
fprintf( ' K(xdot) = %4f\n',K(2));
fprintf( ' K(theta) = %4f\n',K(3));
fprintf( ' K(thetadot) = %4f\n',K(4));
A_cl_lqr = A-B*K;
eig(A_cl_lqr)

%% Plot and Simulating
theta0 = 5* pi/180; %5 degree(chosen)conveted the radian
x0 = [0;0;theta0;0]; % variables on the system [x,xdot,theta,thetadot]
t = 0:0.01:30; %time from 0 sec to 30 secs, 10ms period

sys_closed_lqr = ss(A_cl_lqr, zeros(4,1), C, D);
[y, t_out] = initial(sys_closed_lqr, x0,t);

figure;
subplot(3,1,1);
plot(t_out,y(:,3)*180/pi,'LineWidth',1.5); %% convert from radian to angle
ylabel('\theta (degrees)');
title('Close-Loop Behaviour via LQR - 5° initial deviation');
grid on;

subplot(3,1,2);
plot(t_out,y(:,1)*100,'LineWidth',1.5); 
ylabel('x (cm)');
grid on;

subplot(3,1,3);
u_t = -(K * y' )'; % Control Torque at per moment
plot(t_out,u_t,'LineWidth',1.5); 
ylabel('\tau (N.m)');
xlabel ('Time (sec)');
title('Applied Control Torque ');
grid on;

%% LQR Performans Units
% y,t_out,u_t,theta0 variables are using

theta_deg = y(:,3) * 180/pi; %convert from radian to degree
%peak|theta|
peak_theta = max(abs(theta_deg));

%Ts,2 percent, settling time
threshold = 0.02 * abs(theta0 * 180/pi); % 2% of the starting point, in degrees
idx_settle = find(abs(theta_deg) > threshold, 1, 'last');
Ts= t_out(idx_settle);

%Tr, from 90% to 10%, rise time
theta0_deg = theta0*180/pi;
idx_90 = find(theta_deg <= 0.9*theta0_deg, 1, 'first');
idx_10 = find(theta_deg <= 0.1*theta0_deg, 1, 'first');
Tr= t_out(idx_10)-t_out(idx_90);

%overshoot,Swinging past zero and in the opposite direction
overshoot_deg = abs(min(theta_deg));
overshoot_percent = (overshoot_deg/theta0_deg)*100;

%peak conrtol torque
peak_torque = max(abs(u_t));

%final position error
final_x_error = y(end,1)*100; %cm

fprintf( 'LQR Performans Units;\n');
fprintf( ' peak|theta| : %3f degree\n',peak_theta);
fprintf( ' Ts : %4f s\n',Ts);
fprintf( ' Tr : %4f s\n',Tr);
fprintf( ' Max overshoot : %3f degree (%%%.2f)\n',overshoot_deg,overshoot_percent);
fprintf( ' Peak control torque : %4f N.m\n',peak_torque);
fprintf( ' Final position error : %4f cm\n',final_x_error);

%% Variable Namesexpected by PID_LQR_METRICS.m 
y_lqr= y;
u_lqr= u_t;
t_lqr=t_out;





