
%% Performance Metrics
assert(abs(K(3)+5.170126)<1e-3,'The results do not match the value R=5.Run the LQR design script(R=5)again');%Security line
theta0_deg = theta0* 180/pi;

[Ts_lqr, Tr_lqr, overshoot_lqr, overshoot_pct_lqr, rms_theta_lqr, rms_torque_lqr, peak_torque_lqr] = calc_metrics(y_lqr( :,3)*180/pi,u_lqr, t_lqr, theta0_deg);
[Ts_pid, Tr_pid, overshoot_pid, overshoot_pct_pid, rms_theta_pid, rms_torque_pid, peak_torque_pid] = calc_metrics(y_pid( :,3)*180/pi,u_pid, t_pid, theta0_deg); 

%% Comparision Table

fprintf('\n%-22s %12s %12s\n', 'Metrics', 'LQR', 'PID');
fprintf('\n%-22s %12.4f %12.4f\n', 'Ts(sec)', Ts_lqr, Ts_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'Tr(sec)', Tr_lqr, Tr_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'Overshoot(deg)', overshoot_lqr, overshoot_pid);
fprintf('\n%-22s %12.2f %12.2f\n', 'Overshoot(%)', overshoot_pct_lqr, overshoot_pct_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'RMS theta(deg)', rms_theta_lqr, rms_theta_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'RMS torque(N.m)', rms_torque_lqr, rms_torque_pid);
fprintf('\n%-22s %12.4f %12.4f\n', 'Peak torque(N.m)', peak_torque_lqr, peak_torque_pid);

function [Ts, Tr, overshoot, overshoot_pct, rms_theta, rms_torque, peak_torque] = calc_metrics(theta_deg, u, t, theta0_deg)

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


