% Run GridWatch-D anomaly detection algorithm. 
% INPUT: 
% - Ir, Ii, Vr, Vi: Current (I) and voltage (V) time series in their real
% (r) and imaginary (i) components.  E.g. Ir is a (num_ticks x num_edges) 
% matrix containing real currents at each time and edge. 
% - M: power grid graph, in Matpower format
% - cur_sensors: the sensor set we are allowed to use

% OUTPUT: 
% scores: anomalousness score for each time tick

function scores = detectanom_gridwatch(Ir, Ii, Vr, Vi, M, cur_sensors)

X = compute_features(M, Ir, Ii, Vr, Vi);
incidence_mat = abs(get_incidence_matrix(M)); 
Xd = X(:, 2:end,:) - X(:, 1:end-1, :);
Xp = permute(Xd, [2 1 3]);
Xp = bsxfun(@minus, Xp, median(Xp, 1));
Xz = bsxfun(@rdivide, Xp, iqr(Xp, 1)+1e-6);

Xsensors = [];
for sensor_idx = 1:length(cur_sensors)
    sensor_node = cur_sensors(sensor_idx);
    sensor_edges = incidence_mat(:, sensor_node);
    Xi = Xz(:,:,sensor_edges == 1);
    
    Xedge = max(abs(Xi), [], 3); % single edge anomaly
    Xave = mean(Xi, 3); % group anomaly
    Xdev = std(Xi, [], 3); % group diversion anomaly
    Xsensors = [Xsensors Xedge Xave Xdev];
end

E = abs(Xsensors');
E = bsxfun(@minus, E, median(E, 2));
Eadj = bsxfun(@rdivide, E, iqr(E, 2)+1e-6);
ET = max(Eadj, [], 1);

scores0 = [ET -inf];
scores = [-inf min(scores0(1:end-1), scores0(2:end))];

end