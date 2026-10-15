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
%C and D matrices are output matrixes: y = Cq +Du

sys_open = ss(A,B,C,D); % create a continuous-time state-space model 
disp('Open-Loop eigenvalues:') % open-loop eigenvalues		
disp(eig(A))% Show matrix A's eigenvalues		

%% Initial Condition
theta0 = 5* pi/180; %5 degree(chosen)conveted the radian
x0 = [0;0;theta0;0]; % variables on the system [x,xdot,theta,thetadot]
t = 0:0.01:2; %time from 0 sec to 2 secs, 10ms period

%% Working on Simulation
[y, t_out, xout] = initial(sys_open,x0,t);

%% Plot results
figure;
subplot(2,1,1);
plot(t_out,y(:,3)*180/pi,'LineWidth',1.5); %% convert from radian to angle
ylabel('\theta (degrees)');
xlabel('time(s)');
title('Open-Loop Behaviour - 5^\circ initial deviation');
grid on;

subplot(2,1,2);
plot(t_out, y(:,1)*100, 'LineWidth', 1.5);
ylabel('x(cm)');
xlabel('time(s)');
grid on;
     