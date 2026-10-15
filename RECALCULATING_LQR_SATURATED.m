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
C = eye(4); %identity matrix (create 4x4 matrix
D = zeros(4,1); % create 4x1 zero matrix
%C and D matrices are output matrices: y = Cq +Du


%% R Scanning on LQR ( depending on Actuator saturation Limit)
% Q is kept constant ( degree>>position)
Q= diag([1,1,100,1]);
theta0=5*pi/180;
x0_lqr= [0;0;theta0;0];
t=0:0.01:30;
tau_max_actual= 0.6374;% calculated before
R_values = [1,2,5,10,20,50,100,200,500];
n_R = length(R_values);

Ts_ideal = zeros(n_R,1);
Mp_ideal= zeros(n_R,1);
rms_theta_ideal = zeros(n_R,1);
peak_tau_ideal = zeros(n_R,1);
rms_tau_ideal = zeros(n_R,1);

Ts_sat = zeros(n_R,1);
Mp_sat= zeros(n_R,1);
rms_theta_sat = zeros(n_R,1);
peak_tau_sat = zeros(n_R,1);
rms_tau_sat = zeros(n_R,1);

theta0_deg =theta0*180/pi; %% convert from radian to angle

for i= 1:n_R
    R_i = R_values(i);
    K_i = lqr(A,B,Q,R_i);
    
    % Ideal(linear,no saturation) simulation
    A_cl_i= A - B*K_i;
    sys_i = ss(A_cl_i, zeros(4,1), C, D);
    [y_i, t_i] = initial(sys_i, x0_lqr,t);
    u_i = -(K_i*y_i')';
    [Ts_ideal(i),~,~,Mp_ideal(i), rms_theta_ideal(i),rms_tau_ideal(i), peak_tau_ideal(i)] = sweep_metrics(y_i( :,3)*180/pi,u_i, t_i, theta0_deg);
    
    %saturation simulation
    [y_sat, u_sat] = simulate_saturated(A,B,K_i,x0_lqr,t,tau_max_actual);
    [Ts_sat(i),~,~,Mp_sat(i), rms_theta_sat(i), rms_tau_sat(i), peak_tau_sat(i)] = sweep_metrics(y_sat( :,3)*180/pi,u_sat, t, theta0_deg);
end

fprintf('\n%-6s | %-30s | %-30s\n', 'R','IDEAL','SATURATED');
fprintf('\n%-6s | %-6s %-6s %-8s %-8s | %-6s %-6s %-8s %-8s\n','', 'Ts','Mp%','tau_pk','rmsth','Ts','Mp%','tau_pk','rmsth');

for i=1:n_R
    fprintf('\n%-6.0f | %-6.2f %-6.1f %-8.4f %-8.3f | %-6.2f %-6.1f %-8.4f %-8.3f\n', R_values(i),Ts_ideal(i),Mp_ideal(i),peak_tau_ideal(i),rms_theta_ideal(i),Ts_sat(i),Mp_sat(i),peak_tau_sat(i),rms_theta_sat(i));
end

function [Y,U] = simulate_saturated(A,B,K,x0,t,tau_max)
 [~,Y] = ode45(@(tt,x)sat_dynamics(x,A,B,K,tau_max),t,x0);
  U=zeros(length(t),1);
 
 for k= 1:length(t)
    tau_cmd = -K* Y(k,:)';
    U(k)= max(-tau_max, min(tau_max, tau_cmd));
 end
end

function dx = sat_dynamics(x,A,B,K,tau_max)
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



