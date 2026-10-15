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

%% PARALLEL PID DESIGN

%Augmented state matrices:
%qa= [x; x_dot; theta, theta_dot; z];
%z_dot=-x;
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

%Additional faster poles(assumed, kept unchanged in all experiments)
p3= -5;
p4= -6;
p5= -8;

p_des= [p1 p2 p3 p4 p5];

%pole placement based PID(5x5 matrices)

K_pid= place(A_aug,B_aug,p_des);

fprintf( 'Modeled Parallel PID Gains;\n');
fprintf( ' Kx = %4f\n',K_pid(1));
fprintf( ' Kv = %4f\n',K_pid(2));
fprintf( ' Kp = %4f\n',K_pid(3));
fprintf( ' Kd = %4f\n',K_pid(4));
fprintf( ' Ki = %4f\n',K_pid(5));

%Close_Loop system

A_cl_pid= A_aug - B_aug*K_pid;
fprintf( '\n PID Close Loop Eigenvalues:\n');
eig(A_cl_pid)

%Inýtial Conditions

theta0 = 5* pi/180; %5 degree(chosen)conveted the radian
theta0_deg= theta0*180/pi;
x0_pid = [0;0;theta0;0;0]; % variables on the system [x,xdot,theta,thetadot,z]
t = 0:0.01:30; %time from 0 sec to 30 secs, 10ms period

sys_closed_pid = ss(A_cl_pid, zeros(5,1), eye(5), zeros(5,1));
[y_pid, t_pid] = initial(sys_closed_pid, x0_pid,t);

%Control Torque
u_pid = -(K_pid*y_pid')'; % Control Torque at per moment

%Parameters Metrics
[Ts_pid, Tr_pid, overshoot_pid, overshoot_pct_pid, rms_theta_pid, rms_torque_pid, peak_torque_pid] = calc_metrics(y_pid( :,3)*180/pi,u_pid, t_pid, theta0_deg);%call
fprintf('PID: Ts=%.2f  Tr=%.2f  Mp=%.1f%%  Peak_tau=%.4f  RMS_tau=%.4f\n', Ts_pid, Tr_pid, overshoot_pct_pid, peak_torque_pid, rms_torque_pid);


%plotting and simulation

figure;
subplot(3,1,1);
plot(t_pid,y_pid(:,3)*180/pi,'LineWidth',1.5); %% convert from radian to angle
ylabel('\theta (deg)');
title('Close-Loop Behaviour via Parallel PID - 5° initial deviation');
grid on;

subplot(3,1,2);
plot(t_pid,y_pid(:,1)*100,'LineWidth',1.5); 
ylabel('x (cm)');
grid on;

subplot(3,1,3);
plot(t_pid,u_pid,'LineWidth',1.5); 
ylabel('\tau (N.m)');
xlabel ('Time (sec)');
grid on;

function [Ts, Tr, overshoot, overshoot_pct, rms_theta, rms_torque, peak_torque] = calc_metrics(theta_deg, u, t, theta0_deg)%definition

thr= 0.02*theta0_deg;
idx_settle = find(abs(theta_deg) > thr);
if isempty(idx_settle)
    Ts = NaN;
else
    Ts = t(idx_settle(end));
end

idx90 = find(theta_deg <=0.9*theta0_deg, 1, 'first');%theta_deg comes from calc_metris function
idx10 = find(theta_deg <=0.1*theta0_deg, 1, 'first');
Tr = t(idx10)- t(idx90);

overshoot = abs(min(theta_deg)); %calculate as degree
overshoot_pct = (overshoot/theta0_deg)*100; %calculate percent
rms_theta = sqrt(mean(theta_deg.^2));
rms_torque = sqrt(mean(u.^2));
peak_torque = max(abs(u));
end




