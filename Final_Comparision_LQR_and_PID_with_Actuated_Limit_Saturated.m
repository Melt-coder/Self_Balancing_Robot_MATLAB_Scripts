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

%% for PID
A_aug =[A zeros(4,1); -1 0 0 0 0];
B_aug =[B;0];

%%Controller Gains (K_PID and K_LQR) Constants
K_pid = [-0.304472, -0.138352, -0.317058, -0.026825, 0.315673];
K_lqr = [-0.447214, -1.036294, -5.170126, -0.523897]; %R=5

%% Common Test Conditions
theta0 = 5* pi/180; %5 degree(chosen)conveted the radian
theta0_deg =theta0*180/pi;
x0_lqr = [0;0;theta0;0]; % variables on the system [x,xdot,theta,thetadot](4x4 matrix)
x0_pid = [0;0;theta0;0;0]; % variables on the system [x,xdot,theta,thetadot,z](5x5 matrix)
t = 0:0.01:30; %time from 0 sec to 3 secs, 10ms period
tau_max_actual = 0.6374;

%% Simulations(saturated)

[Y_lqr_st, U_lqr_st] = simulate_saturated(A, B, K_lqr, x0_lqr, t, tau_max_actual);
[Y_pid_st, U_pid_st] = simulate_saturated(A_aug, B_aug, K_pid, x0_pid, t, tau_max_actual);

%% Metrics

[Ts_lqr,Tr_lqr,~,Mp_lqr, rms_theta_lqr,rms_tau_lqr, peak_tau_lqr] = sweep_metrics(Y_lqr_st( :,3)*180/pi, U_lqr_st, t, theta0_deg);
x_final_lqr =Y_lqr_st(end,1)*100;

[Ts_pid,Tr_pid,~,Mp_pid, rms_theta_pid,rms_tau_pid, peak_tau_pid] = sweep_metrics(Y_pid_st( :,3)*180/pi, U_pid_st, t, theta0_deg);
x_final_pid = Y_pid_st(end,1)*100;

%% Comparision Table

fprintf('\n%-22s %12s %12s\n', 'Metrics', 'LQR', 'PID');
fprintf('\n%-22s %12.4f %12.4f\n', 'Ts(sec)', Ts_lqr, Ts_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'Tr(sec)', Tr_lqr, Tr_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'Mp(%%)', Mp_lqr, Mp_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'RMS theta(deg)', rms_theta_lqr, rms_theta_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'RMS torque(N.m)', rms_tau_lqr, rms_tau_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'Peak torque(N.m)', peak_tau_lqr, peak_tau_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'x_final(cm)', x_final_lqr, x_final_pid);

%% Comparision Graphs

figure;
subplot(3,1,1);
plot(t, Y_lqr_st(:,3)*180/pi,'LineWidth',1.5); %% convert from radian to angle
hold on;
plot(t, Y_pid_st(:,3)*180/pi,'LineWidth',1.5);
ylabel('\theta (deg)');
title('Comparision : LQR (R=5) vs Model-Based Parallel PID - Actuator limited(\theta_0=5°)');
legend('LQR','PID');
grid on;

subplot(3,1,2);
plot(t, Y_lqr_st(:,1)*100,'LineWidth',1.5);
hold on;
plot(t, Y_pid_st(:,1)*100,'LineWidth',1.5); 
ylabel('x (cm)');
legend('LQR','PID');
grid on;

subplot(3,1,3);
plot(t, U_lqr_st,'LineWidth',1.5);
hold on;
plot(t, U_pid_st,'LineWidth',1.5);
plot([t(1) t(end)],[tau_max_actual tau_max_actual],':r','LineWidth',1);
plot([t(1) t(end)],[-tau_max_actual -tau_max_actual],':r','LineWidth',1);
ylabel('\tau (N.m)');
xlabel ('Time (sec)');
legend('LQR', 'PID', '\tau_{max_actual}');
grid on;

%% Functions

function [Y,U] = simulate_saturated(A, B, K, x0, t, tau_max)
 [~,Y] = ode45(@(tt,x) sat_dynamics(x, A, B, K, tau_max), t, x0);
 U=zeros(length(t),1);
 
 for k= 1:length(t)
    tau_cmd = -K* Y(k,:)';
    U(k)= max(-tau_max, min(tau_max, tau_cmd));
 end
end

function dx = sat_dynamics(x, A, B, K, tau_max)
 tau_cmd = -K* x;
 tau_act= max(-tau_max, min(tau_max, tau_cmd));
 dx= A*x +B*tau_act;
end

function [Ts, Tr, overshoot, overshoot_pct, rms_theta, rms_torque, peak_torque] = sweep_metrics(theta_deg, u, t, theta0_deg)

thr= 0.02*theta0_deg;
idx_settle = find(abs(theta_deg) > thr);
if isempty(idx_settle)
    Ts = NaN;
else
    Ts = t(idx_settle(end));
end

idx90 = find(theta_deg <=0.9*theta0_deg, 1, 'first');
idx10 = find(theta_deg <=0.1*theta0_deg, 1, 'first');
Tr = t(idx10)- t(idx90);

overshoot = abs(min(theta_deg));
overshoot_pct = (overshoot/theta0_deg)*100;
rms_theta = sqrt(mean(theta_deg.^2));
rms_torque = sqrt(mean(u.^2));
peak_torque = max(abs(u));
end

