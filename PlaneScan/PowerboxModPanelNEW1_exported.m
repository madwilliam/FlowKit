classdef PowerboxModPanelNEW1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        ChannelEditField              matlab.ui.control.EditField
        ChannelEditFieldLabel         matlab.ui.control.Label
        numberoflinestoskipEditField  matlab.ui.control.EditField
        numberoflinestoskipLabel      matlab.ui.control.Label
        ApplyPowerBoxSettingsButton   matlab.ui.control.Button
        SelectPO2RegionButton         matlab.ui.control.Button
        SelectVesselRegionButton      matlab.ui.control.Button
        UIAxes                        matlab.ui.control.UIAxes
    end

    
    properties (Access = public)
        hSI
        image
        nx
        ny
        mask
        power_box
    end
    
    methods (Access = private)
        
        function update_plot(app)
            C = imfuse(app.image,app.mask,'falsecolor','Scaling','independent','ColorChannels',[1 2 0]);
            imagesc(app.UIAxes,C)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           app.hSI = evalin('base', 'hSI');
           app.image = app.hSI.hDisplay.lastAveragedFrame{3};
           [app.ny,app.nx] = size(app.image);
           imagesc(app.UIAxes,app.image)
           xlim(app.UIAxes,[0 app.nx])
           ylim(app.UIAxes,[0 app.ny])
           app.mask = zeros(app.ny,app.nx);
        end

        % Button pushed function: SelectVesselRegionButton
        function select_vessel_region(app, event)
            [startx,starty] = getpts(app.UIAxes);
            [endx,endy] = getpts(app.UIAxes);
            rect = [startx/app.nx,starty/app.ny,(endx-startx)/app.nx,(endy-starty)/app.ny];
            app.power_box{1}.rect = rect;
            app.mask(app.mask==1)=0;
            app.mask = add_rectangle_to_mask(rect,app.mask,1);
            app.update_plot()
        end

        % Callback function
        function select_po2_region(app, event)
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Average Image')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [26 38 448 406];

            % Create SelectVesselRegionButton
            app.SelectVesselRegionButton = uibutton(app.UIFigure, 'push');
            app.SelectVesselRegionButton.ButtonPushedFcn = createCallbackFcn(app, @select_vessel_region, true);
            app.SelectVesselRegionButton.Position = [500 182 129 22];
            app.SelectVesselRegionButton.Text = 'Select Vessel Region';

            % Create SelectPO2RegionButton
            app.SelectPO2RegionButton = uibutton(app.UIFigure, 'push');
            app.SelectPO2RegionButton.Position = [501 135 126 23];
            app.SelectPO2RegionButton.Text = 'Select PO2 Region';

            % Create ApplyPowerBoxSettingsButton
            app.ApplyPowerBoxSettingsButton = uibutton(app.UIFigure, 'push');
            app.ApplyPowerBoxSettingsButton.Position = [487 88 154 25];
            app.ApplyPowerBoxSettingsButton.Text = 'Apply Power Box Settings';

            % Create numberoflinestoskipLabel
            app.numberoflinestoskipLabel = uilabel(app.UIFigure);
            app.numberoflinestoskipLabel.HorizontalAlignment = 'center';
            app.numberoflinestoskipLabel.Position = [469 381 72 28];
            app.numberoflinestoskipLabel.Text = {'number of'; ' lines to skip'};

            % Create numberoflinestoskipEditField
            app.numberoflinestoskipEditField = uieditfield(app.UIFigure, 'text');
            app.numberoflinestoskipEditField.Position = [550 387 77 22];
            app.numberoflinestoskipEditField.Value = '1';

            % Create ChannelEditFieldLabel
            app.ChannelEditFieldLabel = uilabel(app.UIFigure);
            app.ChannelEditFieldLabel.HorizontalAlignment = 'right';
            app.ChannelEditFieldLabel.Position = [479 341 50 22];
            app.ChannelEditFieldLabel.Text = 'Channel';

            % Create ChannelEditField
            app.ChannelEditField = uieditfield(app.UIFigure, 'text');
            app.ChannelEditField.Position = [544 341 83 22];
            app.ChannelEditField.Value = '3';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PowerboxModPanelNEW1_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end