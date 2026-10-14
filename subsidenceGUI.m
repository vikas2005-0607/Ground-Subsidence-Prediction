function subsidenceGUI
% SUBSIDENCEGUI
% GUI for the generalized modified influence-function model based on
% Sheorey et al. (2000).
%
% Files required in the same MATLAB folder:
%   subsidenceGUI.m
%   subsidence_model.m
%   point_to_line.m
%   matlab_proj.m
%
% Run:
%   subsidenceGUI

    % =========================
    % DEFAULT PROJECT PARAMETERS
    % =========================
    defaults.H       = 300;
    defaults.W       = 198;
    defaults.L       = 294;
    defaults.drawDeg = 13;
    defaults.NEW     = 0.40;
    defaults.h       = 4.6;
    defaults.e       = 0.66;

    defaults.x0      = 100;
    defaults.y0      = 100;

    defaults.mode    = "Single Seam";
    defaults.T       = 50;
    defaults.goafW   = 198;
    defaults.goafL   = 294;

    lastResult = [];

    % =========================
    % MAIN WINDOW
    % =========================
    fig = uifigure( ...
        'Name','Ground Subsidence Prediction - Modified Influence Function', ...
        'Position',[40 40 1500 850], ...
        'Color',[0.96 0.96 0.96]);

    uilabel(fig, ...
        'Text','GROUND SUBSIDENCE PREDICTION', ...
        'FontSize',24, ...
        'FontWeight','bold', ...
        'HorizontalAlignment','center', ...
        'Position',[400 805 900 35]);

    % =========================
    % INPUT PANEL
    % =========================
    inputPanel = uipanel(fig, ...
        'Title','Model Parameters', ...
        'FontSize',15, ...
        'Position',[20 70 330 720]);

    y = 650;
    dy = 48;

    makeLabel('Depth H (m)',y);
    Hfield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.H,'Limits',[0 Inf], ...
        'Position',[175 y-4 125 30]);

    y=y-dy;
    makeLabel('Panel Width W (m)',y);
    Wfield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.W,'Limits',[0 Inf], ...
        'Position',[175 y-4 125 30]);

    y=y-dy;
    makeLabel('Panel Length L (m)',y);
    Lfield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.L,'Limits',[0 Inf], ...
        'Position',[175 y-4 125 30]);

    y=y-dy;
    makeLabel('Draw Angle (deg)',y);
    drawField = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.drawDeg,'Limits',[0.01 89], ...
        'Position',[175 y-4 125 30]);

    y=y-dy;
    makeLabel('NEW',y);
    NEWfield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.NEW,'Limits',[0.001 Inf], ...
        'Position',[175 y-4 125 30]);

    y=y-dy;
    makeLabel('Seam thickness h (m)',y);
    hfield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.h,'Limits',[0 Inf], ...
        'Position',[175 y-4 125 30]);

    y=y-dy;
    makeLabel('Extraction factor e',y);
    efield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.e,'Limits',[0 1], ...
        'Position',[175 y-4 125 30]);

    y=y-dy;
    makeLabel('Mining condition',y);
    modeField = uidropdown(inputPanel, ...
        'Items',{'Single Seam','Multi-seam'}, ...
        'Value','Single Seam', ...
        'Position',[175 y-4 125 30], ...
        'ValueChangedFcn',@toggleGoafFields);

    y=y-dy;
    makeLabel('Parting T (m)',y);
    Tfield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.T,'Limits',[0 Inf], ...
        'Position',[175 y-4 125 30], ...
        'Enable','off');

    y=y-dy;
    makeLabel('Goaf Width (m)',y);
    goafWfield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.goafW,'Limits',[0 Inf], ...
        'Position',[175 y-4 125 30], ...
        'Enable','off');

    y=y-dy;
    makeLabel('Goaf Length (m)',y);
    goafLfield = uieditfield(inputPanel,'numeric', ...
        'Value',defaults.goafL,'Limits',[0 Inf], ...
        'Position',[175 y-4 125 30], ...
        'Enable','off');

    calcButton = uibutton(inputPanel, ...
        'Text','CALCULATE', ...
        'FontSize',15, ...
        'FontWeight','bold', ...
        'Position',[60 145 210 45], ...
        'ButtonPushedFcn',@calculateSubsidence);

    validateButton = uibutton(inputPanel, ...
        'Text','VALIDATE CSV', ...
        'FontSize',12, ...
        'Position',[60 95 210 35], ...
        'ButtonPushedFcn',@validateCSV);

    exportButton = uibutton(inputPanel, ...
        'Text','EXPORT RESULTS', ...
        'FontSize',12, ...
        'Position',[60 50 210 35], ...
        'ButtonPushedFcn',@exportResults, ...
        'Enable','off');

    statusLabel = uilabel(inputPanel, ...
        'Text','Status: Ready', ...
        'FontSize',11, ...
        'HorizontalAlignment','center', ...
        'Position',[20 18 290 25]);

    % =========================
    % OUTPUT TABS
    % =========================
    tabs = uitabgroup(fig, ...
        'Position',[365 70 1115 720]);

    tab3D = uitab(tabs,'Title','3D Subsidence');
    ax3D = uiaxes(tab3D,'Position',[50 65 1015 590]);
    title(ax3D,'3D Ground Subsidence Prediction');
    xlabel(ax3D,'X (m)');
    ylabel(ax3D,'Y (m)');
    zlabel(ax3D,'Subsidence (m)');
    grid(ax3D,'on');
    view(ax3D,45,30);

    tab3DContour = uitab(tabs,'Title','3D Contour Plot');
    ax3DContour = uiaxes(tab3DContour,'Position',[50 65 1015 590]);
    title(ax3DContour,'3D Ground Subsidence Contour');
    xlabel(ax3DContour,'X (m)');
    ylabel(ax3DContour,'Y (m)');
    zlabel(ax3DContour,'Subsidence (m)');
    grid(ax3DContour,'on');
    view(ax3DContour,45,30);

    tabContour = uitab(tabs,'Title','2D Contour');
    axContour = uiaxes(tabContour,'Position',[50 65 1015 590]);
    title(axContour,'Ground Subsidence Contour');
    xlabel(axContour,'X (m)');
    ylabel(axContour,'Y (m)');
    grid(axContour,'on');

    tabDisp = uitab(tabs,'Title','Horizontal Displacement');
    axDisp = uiaxes(tabDisp,'Position',[50 65 1015 590]);
    title(axDisp,'Horizontal Displacement Field');
    xlabel(axDisp,'X (m)');
    ylabel(axDisp,'Y (m)');
    grid(axDisp,'on');

    tabSlope = uitab(tabs,'Title','Slope');
    axSlope = uiaxes(tabSlope,'Position',[50 65 1015 590]);
    title(axSlope,'Surface Slope Magnitude');
    xlabel(axSlope,'X (m)');
    ylabel(axSlope,'Y (m)');
    grid(axSlope,'on');

    tabStrain = uitab(tabs,'Title','Strain');
    axStrain = uiaxes(tabStrain,'Position',[50 65 1015 590]);
    title(axStrain,'Maximum Principal Strain');
    xlabel(axStrain,'X (m)');
    ylabel(axStrain,'Y (m)');
    grid(axStrain,'on');

    % =========================
    % OUTPUT METRICS
    % =========================
    metricsPanel = uipanel(fig, ...
        'Title','Model Output', ...
        'FontSize',12, ...
        'Position',[20 5 330 58]);

    metricLabel = uilabel(metricsPanel, ...
        'Text','Run CALCULATE to generate results.', ...
        'FontSize',10, ...
        'HorizontalAlignment','center', ...
        'Position',[5 5 320 35]);

    % =========================
    % NESTED FUNCTIONS
    % =========================

    function makeLabel(txt,yy)
        uilabel(inputPanel, ...
            'Text',txt, ...
            'FontSize',11, ...
            'Position',[10 yy 160 25]);
    end

    function toggleGoafFields(~,~)
        isMulti = strcmp(modeField.Value,'Multi-seam');

        if isMulti
            Tfield.Enable = 'on';
            goafWfield.Enable = 'on';
            goafLfield.Enable = 'on';
        else
            Tfield.Enable = 'off';
            goafWfield.Enable = 'off';
            goafLfield.Enable = 'off';
        end
    end

    function calculateSubsidence(~,~)

        calcButton.Enable = 'off';
        validateButton.Enable = 'off';
        statusLabel.Text = 'Status: Calculating...';
        drawnow;

        try
            p.H = Hfield.Value;
            p.W = Wfield.Value;
            p.L = Lfield.Value;
            p.drawDeg = drawField.Value;
            p.NEW = NEWfield.Value;
            p.h = hfield.Value;
            p.e = efield.Value;

            p.x0 = defaults.x0;
            p.y0 = defaults.y0;

            p.mode = string(modeField.Value);
            p.T = Tfield.Value;

            p.goafX0 = p.x0;
            p.goafY0 = p.y0;
            p.goafW = goafWfield.Value;
            p.goafL = goafLfield.Value;

            p.dx = 4;
            p.dy = 5;

            lastResult = subsidence_model(p);

            drawResults(lastResult);

            maxSubs = max(abs(lastResult.Subsidence(:)));
            maxSlope = max(lastResult.slopeMagnitude(:));

            metricLabel.Text = sprintf( ...
                'R = %.2f m | x = %.3f | %s | Smax = %.4f m | Max S = %.4f m | Max slope = %.5g', ...
                lastResult.R, ...
                lastResult.widthRatio, ...
                lastResult.widthClass, ...
                lastResult.Smax, ...
                maxSubs, ...
                maxSlope);

            statusLabel.Text = 'Status: Calculation complete';
            exportButton.Enable = 'on';

        catch ME
            statusLabel.Text = 'Status: Error';
            uialert(fig,ME.message,'Calculation Error');
        end

        calcButton.Enable = 'on';
        validateButton.Enable = 'on';
        drawnow;
    end

    function drawResults(r)

        % -------- 3D surface --------
        cla(ax3D);

        s = surf(ax3D, ...
            r.X,r.Y,r.Subsidence,r.Subsidence);

        s.EdgeColor = 'none';
        shading(ax3D,'interp');

        hold(ax3D,'on');
        plot3(ax3D,r.x_co,r.y_co,zeros(size(r.x_co)), ...
            'r--','LineWidth',2);
        hold(ax3D,'off');

        title(ax3D,'3D Ground Subsidence Prediction');
        xlabel(ax3D,'X (m)');
        ylabel(ax3D,'Y (m)');
        zlabel(ax3D,'Subsidence (m)');
        colorbar(ax3D);
        grid(ax3D,'on');
        view(ax3D,45,30);

        % -------- 3D contour --------
        cla(ax3DContour);

        contour3(ax3DContour, ...
            r.X,r.Y,r.Subsidence,25, ...
            'LineWidth',1.0);

        hold(ax3DContour,'on');
        plot3(ax3DContour, ...
            r.x_co,r.y_co,zeros(size(r.x_co)), ...
            'r--','LineWidth',2);
        hold(ax3DContour,'off');

        title(ax3DContour,'3D Ground Subsidence Contour');
        xlabel(ax3DContour,'X (m)');
        ylabel(ax3DContour,'Y (m)');
        zlabel(ax3DContour,'Subsidence (m)');
        colorbar(ax3DContour);
        grid(ax3DContour,'on');
        view(ax3DContour,45,30);

        % -------- 2D contour --------
        cla(axContour);

        contourf(axContour, ...
            r.X,r.Y,r.Subsidence,25, ...
            'LineColor','none');

        hold(axContour,'on');
        plot(axContour,r.x_co,r.y_co, ...
            'r--','LineWidth',2);
        hold(axContour,'off');

        title(axContour,'Ground Subsidence Contour');
        xlabel(axContour,'X (m)');
        ylabel(axContour,'Y (m)');
        colorbar(axContour);
        grid(axContour,'on');

        % -------- horizontal displacement --------
        cla(axDisp);

        step = max(1,round(size(r.X,1)/20));

        quiver(axDisp, ...
            r.X(1:step:end,1:step:end), ...
            r.Y(1:step:end,1:step:end), ...
            r.Ux(1:step:end,1:step:end), ...
            r.Uy(1:step:end,1:step:end), ...
            'AutoScale','on');

        hold(axDisp,'on');
        plot(axDisp,r.x_co,r.y_co, ...
            'r--','LineWidth',2);
        hold(axDisp,'off');

        title(axDisp,'Horizontal Displacement Field');
        xlabel(axDisp,'X (m)');
        ylabel(axDisp,'Y (m)');
        axis(axDisp,'equal');
        grid(axDisp,'on');

        % -------- slope --------
        cla(axSlope);

        contourf(axSlope, ...
            r.X,r.Y,r.slopeMagnitude,25, ...
            'LineColor','none');

        hold(axSlope,'on');
        plot(axSlope,r.x_co,r.y_co, ...
            'r--','LineWidth',2);
        hold(axSlope,'off');

        title(axSlope,'Surface Slope Magnitude');
        xlabel(axSlope,'X (m)');
        ylabel(axSlope,'Y (m)');
        colorbar(axSlope);
        grid(axSlope,'on');

        % -------- strain --------
        cla(axStrain);

        contourf(axStrain, ...
            r.X,r.Y,r.principal1,25, ...
            'LineColor','none');

        hold(axStrain,'on');
        plot(axStrain,r.x_co,r.y_co, ...
            'r--','LineWidth',2);
        hold(axStrain,'off');

        title(axStrain,'Maximum Principal Strain');
        xlabel(axStrain,'X (m)');
        ylabel(axStrain,'Y (m)');
        colorbar(axStrain);
        grid(axStrain,'on');
    end

    function exportResults(~,~)

        if isempty(lastResult)
            uialert(fig,'Run CALCULATE first.','No Results');
            return;
        end

        [file,path] = uiputfile( ...
            'subsidence_results.csv', ...
            'Save subsidence grid as CSV');

        if isequal(file,0)
            return;
        end

        T = table( ...
            lastResult.X(:), ...
            lastResult.Y(:), ...
            lastResult.Subsidence(:), ...
            lastResult.Ux(:), ...
            lastResult.Uy(:), ...
            lastResult.slopeMagnitude(:), ...
            lastResult.principal1(:), ...
            lastResult.principal2(:), ...
            'VariableNames', ...
            {'X','Y','Subsidence','Ux','Uy', ...
             'Slope','PrincipalTensileStrain', ...
             'PrincipalCompressiveStrain'});

        writetable(T,fullfile(path,file));

        uialert(fig, ...
            'Results exported successfully.', ...
            'Export Complete');
    end

    function validateCSV(~,~)

        if isempty(lastResult)
            uialert(fig,'Run CALCULATE first.','No Model Results');
            return;
        end

        [file,path] = uigetfile( ...
            {'*.csv','CSV files'}, ...
            'Select validation CSV');

        if isequal(file,0)
            return;
        end

        try
            obs = readtable(fullfile(path,file));

            names = lower(string(obs.Properties.VariableNames));

            ix = find(names=="x",1);
            iy = find(names=="y",1);
            iz = find(names=="observed" | ...
                      names=="observedsubsidence" | ...
                      names=="observed_subsidence",1);

            if isempty(ix) || isempty(iy) || isempty(iz)
                error(['CSV must contain columns named X, Y and ', ...
                    'Observed (or ObservedSubsidence).']);
            end

            xobs = obs{:,ix};
            yobs = obs{:,iy};
            zobs = obs{:,iz};

            valid = isfinite(xobs) & ...
                    isfinite(yobs) & ...
                    isfinite(zobs);

            xobs = xobs(valid);
            yobs = yobs(valid);
            zobs = zobs(valid);

            % Subsidence is compared as magnitude.
            zobs = abs(zobs);

            zpredSigned = interp2( ...
                lastResult.X,lastResult.Y, ...
                lastResult.Subsidence, ...
                xobs,yobs,'linear');

            zpred = abs(zpredSigned);

            valid2 = isfinite(zpred) & isfinite(zobs);

            zpred = zpred(valid2);
            zobs = zobs(valid2);

            if numel(zobs) < 2
                error(['At least two valid observed points inside ', ...
                    'the model grid are required.']);
            end

            residual = zobs-zpred;

            RMSE = sqrt(mean(residual.^2));
            MAE = mean(abs(residual));

            SSres = sum((zobs-zpred).^2);
            SStot = sum((zobs-mean(zobs)).^2);

            if SStot > 0
                R2 = 1-SSres/SStot;
            else
                R2 = NaN;
            end

            figure('Name','Observed vs Predicted Subsidence');

            scatter(zobs,zpred,45,'filled');
            hold on;

            mn = min([zobs;zpred]);
            mx = max([zobs;zpred]);

            plot([mn mx],[mn mx], ...
                'k--','LineWidth',1.5);

            hold off;

            xlabel('Observed Subsidence Magnitude (m)');
            ylabel('Predicted Subsidence Magnitude (m)');

            title(sprintf( ...
                'Validation: RMSE = %.4f m, MAE = %.4f m, R^2 = %.4f', ...
                RMSE,MAE,R2));

            grid on;
            axis equal;

            uialert(fig,sprintf( ...
                ['Validation complete.\n\n', ...
                 'Points used: %d\n', ...
                 'RMSE: %.6f m\n', ...
                 'MAE: %.6f m\n', ...
                 'R^2: %.6f'], ...
                numel(zobs),RMSE,MAE,R2), ...
                'Validation Results');

        catch ME
            uialert(fig,ME.message,'Validation Error');
        end
    end
end
