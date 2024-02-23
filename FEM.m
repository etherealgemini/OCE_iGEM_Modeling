% 定义模型参数
SPACE_R = 1.5; % 世界半径
R = 1; % 凝胶小球半径
k = 0.05; % 降解速率常数
points_num = 50; % 有限元网格点数
min_concentration = 1e-11; % 边界条件：甲醛最小意义浓度值

% 定义米氏方程参数（自定义参数，可根据需要调整）
V_max = 0.08; % 最大反应速率
K_m = 0.025; % 米氏常数

% 定义空间依赖的扩散系数
D_A = ones(size(X)) * 0.1; % 初始扩散系数，可根据需要调整
D_A(X.^2 + Y.^2 + Z.^2 <= R^2) = 0.05; % 小球内部扩散系数较小，表示阻尼作用

% 定义空间范围和指示函数
[I, X, Y, Z, z_values] = initializeSpace(SPACE_R,R,points_num);

% 定义时间步长和总时长
dt = 10;
timesteps = 1000;

% 初始化甲醛浓度分布和矢量场
grad_x = X;
grad_y = Y;
grad_z = Z;

C_A = zeros(size(X));
C_A(X.^2 + Y.^2 + Z.^2 > R^2) = 1;

% 创建图窗
figure;

% 绘制甲醛扩散和降解模型的矢量场（上方）
subplot(1, 2, 1);
q = quiver3(X, Y, Z, grad_x, grad_y, grad_z);
xlabel('X轴');
ylabel('Y轴');
zlabel('Z轴');
title('甲醛扩散和降解模型的矢量场');
colormap("jet");
colorbar;
axis equal;

% 绘制二维平面图，x、y轴表示小球内垂直于z轴且平分小球的平面上的坐标，z轴表示甲醛浓度（下方）
subplot(1, 2, 2);
x_plane = linspace(-SPACE_R, SPACE_R, points_num);
C_A_x_plane = squeeze(C_A(round(points_num/2), :, :)); % 取平面上的甲醛浓度数据
[X_plane, Z_plane] = meshgrid(x_plane, z_values);
contour_plot = contourf(X_plane, Z_plane, C_A_x_plane,'ZDataSource','C_A_x_plane');
xlabel('X轴');
ylabel('Z轴');
title('对称面上的甲醛浓度分布');
colormap("jet");
colorbar;
axis equal;
% 使用有限元方法模拟甲醛扩散和降解的动态过程
for t = 1:timesteps
    % 计算扩散项
    laplacian_C_A = del2(C_A, R, R, R);

    % 计算代谢速率，遵循米氏方程
%     metabolism = V_max * C_A  ./ (K_m + C_A);
    metabolism = 0;

    % 通过空间指示矩阵限制代谢仅发生在小球内部
%     metabolism = metabolism .* I;

    % 更新甲醛浓度，考虑代谢
    C_A = C_A + (D_A .* laplacian_C_A - metabolism) .* dt;

    % 边界条件：确保甲醛浓度不会降至零以下
    C_A(C_A < min_concentration) = min_concentration;

    % 更新矢量场数据
    [grad_x, grad_y, grad_z] = gradient(C_A, R, R, R);

    % 计算甲醛浓度的大小，用于设置矢量颜色
%     C_A_magnitude = sqrt(grad_x.^2 + grad_y.^2 + grad_z.^2);

    mags = C_A;

    % below are to assign the color to vector according to the value of "mags"
    % Get the current colormap
    currentColormap = colormap(gcf);

    % Now determine the color to make each arrow using a colormap
    [~, ~, ind] = histcounts(mags, size(currentColormap, 1));

    % Now map this to a colormap to get RGB
    cmap = uint8(ind2rgb(ind(:), currentColormap) * 255);
    cmap(:,:,4) = 255;
    cmap = permute(repmat(cmap, [1 3 1]), [2 1 3]);

    % We repeat each color 3 times (using 1:3 below) because each arrow has 3 vertices
    set(q.Head, ...
        'ColorBinding', 'interpolated', ...
        'ColorData', reshape(cmap(1:3,:,:), [], 4).');   %'

    %// We repeat each color 2 times (using 1:2 below) because each tail has 2 vertices
    set(q.Tail, ...
        'ColorBinding', 'interpolated', ...
        'ColorData', reshape(cmap(1:2,:,:), [], 4).');

    set(q, 'UData', -grad_x/4, 'VData', -grad_y/4, 'WData', -grad_z/4);

    % 更新小球内平分平面上的甲醛浓度分布
    C_A_x_plane = squeeze(C_A(round(points_num/2), :, :)); % 取平面上的甲醛浓度数据
    
    % 更新图窗
    drawnow;
    refreshdata;
end

% 初始化空间范围函数
function [I, X, Y, Z, z_values] = initializeSpace(SPACE_R,R,points_num)


    % 定义空间范围
    x_values = linspace(-SPACE_R, SPACE_R, points_num);
    y_values = linspace(-SPACE_R, SPACE_R, points_num);
    z_values = linspace(-SPACE_R, SPACE_R, points_num);

    % 生成坐标网格
    [X, Y, Z] = meshgrid(x_values, y_values, z_values);

    % 定义空间指示函数，1表示在凝胶小球内部，0表示在凝胶小球外部
    I = zeros(size(X));
    I(X.^2 + Y.^2 + Z.^2 <= R^2) = 1;
end
