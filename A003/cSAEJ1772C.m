classdef cSAEJ1772C < handle
    %CSAEJ1772C Summary of this class goes here
    %   Detailed explanation goes here

    properties(Access = private)
        cApp
        cModel
        cView
    end

    methods
        function obj = cSAEJ1772C()
            %CSAEJ1772C Construct an instance of this class
            %   Detailed explanation goes here
        end

    end

    %% 0. 공통
    methods(Access = public)% init, delete, update

        function delete(obj)
            %
            % obj.deleteLeft();
            % obj.deleteCenter();
            % obj.deleteRight();
            % obj.deleteBottom();
            %
            % obj.deleteCallbackFlag();
        end

        function init(obj, app, view, model)
            obj.cApp = app;
            obj.cView = view;
            obj.cModel = model;

            % obj.initCallbackFlag();
            % obj.initLeft();
            % obj.initCenter();
            % obj.initRight();
            % obj.initBottom();
        end

        function update(obj)
            % obj.updateLeft();
            % obj.updateCenter();
            % obj.updateRight();
            % obj.updateBottom();
        end

    end


    %%
    properties(Access = private)

    end

    methods(Access = public)

        function clickSimulationInitialize(obj)
            Model = obj.cModel;
            View = obj.cView;

            Model.simulationInitizlize();
            View.update();
        end

        function clickSimulationStart(obj)
            Model = obj.cModel;
            View = obj.cView;

            Model.simulationStart();
            View.update();
        end

        function clickSimulationStep(obj)
            Model = obj.cModel;
            View = obj.cView;

            Model.simulationStep();
            View.update();
        end

        function clickSimulationPause(obj)
            Model = obj.cModel;
            View = obj.cView;

            Model.simulationPause();
            View.update();
        end

        function clickSimulationResume(obj)
            Model = obj.cModel;
            View = obj.cView;

            Model.simulationResume();
            View.update();
        end

        function clickSimulationStop(obj)
            Model = obj.cModel;
            View = obj.cView;

            Model.simulationStop();
            View.update();
        end

        function clickSimulationTerminate(obj)
            Model = obj.cModel;
            View = obj.cView;

            Model.simulationTerminate();
            View.update();
        end


    end


    methods(Access = public)

        function setStepSize(obj, val)
            Model = obj.cModel;
            View = obj.cView;

            Model.setStepSize(val);
            View.update();
        end

        function setInputParameter(obj, item, value)
            Model = obj.cModel;
            View = obj.cView;

            switch item
                case "PilotV"
                    Model.setPilotV(value);
                case "ProxV"
                    Model.setProxV(value);
                case "DutyCycle"
                    Model.setDutyCycle(value);
                case "EVReady"
                    Model.setEVReady(value);
                case "BatteryC"
                    Model.setBatteryC(value);
                otherwise
            end
            View.update();
        end

    end

end
