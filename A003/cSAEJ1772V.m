classdef cSAEJ1772V < handle
    %CSAEJ1772V Summary of this class goes here
    %   Detailed explanation goes here

    properties(Access = private)
        cApp
        cModel
        cControl
    end

    methods
        function obj = cSAEJ1772V()
            %CSAEJ1772V Construct an instance of this class
            %   Detailed explanation goes here
        end
    end

     methods(Access = public)% init, delete, update

        function delete(obj)

            % obj.deletePanelTop();
            % obj.deletePanelBottom();
            % obj.deletePanelLeft();
            % obj.deletePanelRight();
            % obj.deletePanelCenter();
            %
            % % 클래스 종료시 한번 실행
            % for idx=1:length(obj.els)
            %     obj.els(idx).Enabled = 0;
            % end
            % delete(obj.els);
        end

        function init(obj, app, control, model)
            obj.cApp = app;
            obj.cModel = model;
            obj.cControl = control;

            % obj.initPanelTop();
            % obj.initPanelBottom();
            % obj.initPanelLeft();
            % obj.initPanelRight();
            % obj.initPanelCenter();

            % centerfig(app.UIFigure);
        end

        function update(obj)
            % obj.updatePanelTop();
            % obj.updatePanelBottom();
            % obj.updatePanelLeft();
            % obj.updatePanelRight();
            % obj.updatePanelCenter();
            obj.updateStatesField();
            obj.updateTimeField();
            obj.updateStatusLabel();
            obj.updateStepSize();
            obj.updateInputParameter();
            obj.updateOutputParameter();
        end

     end


     methods(Access = private)

         function updateTimeField(obj)
            Model = obj.cModel;
            App = obj.cApp;

            t = Model.getSimulationTime();
            if isnan(t)
                App.slTimeEditField.Value = 0;
            else
                App.slTimeEditField.Value = t;
            end

         end

         function updateStatesField(obj)
            Model = obj.cModel;
            App = obj.cApp;

            App.slStatesEditField.Value = Model.getSimulationState();
         end

         function updateStatusLabel(obj)
            Model = obj.cModel;
            App = obj.cApp;

            lo = Model.getSimulationLogoutStatus();
            if ~isempty(lo) && numel(lo.Data) > 0
                App.statusLabel.Text = char(lo.Data(end));
            else
                App.statusLabel.Text = 'No State';
            end
         end

         function updateStepSize(obj)
            Model = obj.cModel;
            App = obj.cApp;

            App.stepsizeEditField.Value = Model.getStepSize();
         end


         function updateInputParameter(obj)
            Model = obj.cModel;
            App = obj.cApp;

            App.pilotVEditField.Value = Model.getPilotV();
            App.proxVEditField.Value = Model.getProxV();
            App.dutyEditField.Value = Model.getDutyCycle();
            if Model.getEVReady()
                App.switchEVReady.Value = 'On';
            else
                App.switchEVReady.Value = 'Off';
            end
            App.batteryCurrentEditField.Value = Model.getBatteryC();
         end

         function updateOutputParameter(obj)
            Model = obj.cModel;
            App = obj.cApp;

            lo = Model.getSimulationLogoutHLC();
            if ~isempty(lo) && numel(lo.Data) > 0 && lo.Data(end) == true
                App.enHLCLamp.Color = [ 0 1 0];
            else
                App.enHLCLamp.Color = [0.8 0.8 0.8];
            end

            lo = Model.getSimulationLogoutReady();
            if ~isempty(lo) && numel(lo.Data) > 0 && lo.Data(end) == 1
                App.evReadyLamp.Color = [ 0 1 0];
            else
                App.evReadyLamp.Color = [0.8 0.8 0.8];
            end

            lo = Model.getSimulationLogoutMaxCurrent();
            if ~isempty(lo) && numel(lo.Data) > 0
                App.maxCurrentEditField.Value = double(lo.Data(end));
            else
                App.maxCurrentEditField.Value = 0;
            end

         end

     end


end
