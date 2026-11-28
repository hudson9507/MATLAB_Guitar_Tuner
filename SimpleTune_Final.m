classdef SimpleTune_Final < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        GridLayout          matlab.ui.container.GridLayout
        LeftPanel           matlab.ui.container.Panel
        NoneLabel           matlab.ui.control.Label
        HtzLabel_2          matlab.ui.control.Label
        UnknownLabel        matlab.ui.control.Label
        WaitingLabel        matlab.ui.control.Label
        Switch              matlab.ui.control.Switch
        SuggestionLabel     matlab.ui.control.Label
        FrequencydiffLabel  matlab.ui.control.Label
        TargetpitchLabel    matlab.ui.control.Label
        SamplePitchLabel    matlab.ui.control.Label
        SimpleTuneLabel     matlab.ui.control.Label
        RightPanel          matlab.ui.container.Panel
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: Switch
        function SwitchValueChanged(app, event)
            %listen for input
            fs = 44100
            rec = audiorecorder(fs, 16, 1);

            recordblocking(rec, 2);   % start listening
            % ...later:          
            audio = getaudiodata(rec);
            

            [cleansound] = processAudio (audio, fs)
            
            [quantSound] =  measurePitch(cleansound, fs)

            disp(quantSound)
            [nearestNote, frequency, status, recom_action] = checkTuning(quantSound)    

            FrequencyData= (frequency + " " + status)

            app.WaitingLabel.Text = ("analyzed")
            app.UnknownLabel.Text = string(nearestNote)
            app.HtzLabel_2.Text = string(FrequencyData)
            app.NoneLabel.Text = string(recom_action)
        end

        % Button down function: LeftPanel
        function LeftPanelButtonDown(app, event)
            
           
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {335, 335};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {317, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 330 335];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {317, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.ButtonDownFcn = createCallbackFcn(app, @LeftPanelButtonDown, true);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create SimpleTuneLabel
            app.SimpleTuneLabel = uilabel(app.LeftPanel);
            app.SimpleTuneLabel.HorizontalAlignment = 'center';
            app.SimpleTuneLabel.FontSize = 24;
            app.SimpleTuneLabel.Position = [59 291 225 33];
            app.SimpleTuneLabel.Text = 'SimpleTune';

            % Create SamplePitchLabel
            app.SamplePitchLabel = uilabel(app.LeftPanel);
            app.SamplePitchLabel.Position = [47 206 79 30];
            app.SamplePitchLabel.Text = 'Sample Pitch:';

            % Create TargetpitchLabel
            app.TargetpitchLabel = uilabel(app.LeftPanel);
            app.TargetpitchLabel.Position = [47 161 76 30];
            app.TargetpitchLabel.Text = 'Target pitch: ';

            % Create FrequencydiffLabel
            app.FrequencydiffLabel = uilabel(app.LeftPanel);
            app.FrequencydiffLabel.Position = [48 116 87 30];
            app.FrequencydiffLabel.Text = 'Frequency diff.';

            % Create SuggestionLabel
            app.SuggestionLabel = uilabel(app.LeftPanel);
            app.SuggestionLabel.Position = [46 73 68 22];
            app.SuggestionLabel.Text = 'Suggestion:';

            % Create Switch
            app.Switch = uiswitch(app.LeftPanel, 'slider');
            app.Switch.ValueChangedFcn = createCallbackFcn(app, @SwitchValueChanged, true);
            app.Switch.Position = [74 255 45 20];

            % Create WaitingLabel
            app.WaitingLabel = uilabel(app.LeftPanel);
            app.WaitingLabel.Position = [177 210 79 22];
            app.WaitingLabel.Text = 'Waiting...';

            % Create UnknownLabel
            app.UnknownLabel = uilabel(app.LeftPanel);
            app.UnknownLabel.Position = [177 165 97 22];
            app.UnknownLabel.Text = 'Unknown';

            % Create HtzLabel_2
            app.HtzLabel_2 = uilabel(app.LeftPanel);
            app.HtzLabel_2.Position = [177 120 79 22];
            app.HtzLabel_2.Text = '___Htz';

            % Create NoneLabel
            app.NoneLabel = uilabel(app.LeftPanel);
            app.NoneLabel.Position = [177 73 107 22];
            app.NoneLabel.Text = 'None';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SimpleTune_Final

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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