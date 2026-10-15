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

%% LQR Massive Matrices 
Q = diag([1,1,100,1]); % x,xdot,theta,thetadot
R= 1; % only 1 input [1x1].The penalty for the control effort.
K_lqr = lqr(A, B, Q, R);
A_cl_lqr = A - B*K_lqr;

%% PARALLEL PID DESIGN

A_aug =[A zeros(4,1); -1 0 0 0 0];
B_aug =[B;0];

%Desired transient specifications
Ts_des= 1.93; % desired settling time[s]
zeta= 0.7;% damping ratio

wn=4/(zeta*Ts_des);
wd= wn*sqrt(1-zeta^2);

%Dominant poles
p1= -(zeta*wn) +1j*wd;
p2= -(zeta*wn) -1j*wd;

%Additional faster poles(assumed)they will have been changed in the future
p3= -5;
p4= -6;
p5= -8;

p_des= [p1 p2 p3 p4 p5];

%pole placement based PID(5x5 matrices)

K_pid= place(A_aug,B_aug,p_des);
A_cl_pid= A_aug - B_aug*K_pid;

%% Common Initial Conditions and Time
theta0 = 5* pi/180; %5 degree(chosen)conveted the radian
t = 0:0.01:30; %time from 0 sec to 3 secs, 10ms period
x0_lqr = [0;0;theta0;0]; % variables on the system [x,xdot,theta,thetadot](4x4 matrix)
x0_pid = [0;0;theta0;0;0]; % variables on the system [x,xdot,theta,thetadot,z](5x5 matrix)

%% Simulations
sys_lqr = ss(A_cl_lqr, zeros(4,1), eye(4), zeros(4,1));
[y_lqr, t_lqr] = initial(sys_lqr, x0_lqr,t);
u_lqr = -(K_lqr * y_lqr')';

sys_pid = ss(A_cl_pid, zeros(5,1), eye(5), zeros(5,1));
[y_pid, t_pid] = initial(sys_pid, x0_pid,t);
u_pid = -(K_pid * y_pid')';

%% Graphics

figure;
subplot(3,1,1);
plot(t_lqr, y_lqr(:,3)*180/pi,'LineWidth',1.5); %% convert from radian to angle
hold on;
plot(t_pid, y_pid(:,3)*180/pi,'LineWidth',1.5);
ylabel('\theta (deg)');
title('LQR vs Model-Based Parallel PID - Comparision (\theta_0=5°)');
legend('LQR','PID(poles)');
grid on;

subplot(3,1,2);
plot(t_lqr, y_lqr(:,1)*100,'LineWidth',1.5);
hold on;
plot(t_pid, y_pid(:,1)*100,'LineWidth',1.5); 
ylabel('x (cm)');
legend('LQR','PID');
grid on;

subplot(3,1,3);
plot(t_lqr, u_lqr,'LineWidth',1.5);
hold on;
plot(t_pid, u_pid,'LineWidth',1.5); 
ylabel('\tau (N.m)');
xlabel ('Time (sec)');
legend('LQR', 'PID');
grid on;




