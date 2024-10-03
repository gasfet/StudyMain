classdef cSAEJ1772M < handle
    %CSAEJ1772M Summary of this class goes here
    %   Detailed explanation goes here

    properties(Access = private)
        cApp
        cControl
        cView
    end

    methods
        function obj = cSAEJ1772M()
            %CSAEJ1772M Construct an instance of this class
            %   Detailed explanation goes here
        end
    end

    methods(Access = public)% init, delete, update => 전체 프로젝트

        function delete(obj)
            % delete(obj.gObj);

            % obj.deletePanelTop();
            % obj.deletePanelBottom();
            % obj.deletePanelLeft();
            % obj.deletePanelRight();
            % obj.deletePanelCenter();

            % 모든 핸들 삭제
            % obj.deleteDutHandle();
            % obj.deleteAmplifierHandle();
            % obj.deleteFixtureHandle();
            % obj.deleteTcpRTDHandle();
            % obj.deleteTemperatureHandle();
            obj.deleteSimulink();
        end

        function init(obj, app, view, control)
            obj.cApp = app;
            obj.cView = view;
            obj.cControl = control;

            % 모든 핸들 초기화
            % obj.initDutHandle();
            % obj.initAmplifierHandle();
            % obj.initFixtureHandle();
            % obj.initTcpRTDHandle();
            % obj.initTemperatureHandle();
            %
            % obj.initPanelTop();
            % obj.initPanelBottom();
            % obj.initPanelLeft();
            % obj.initPanelRight();
            % obj.initPanelCenter();
            %
            % obj.gCancel = DF.FALSE;
            % obj.gObj = gobjects(0);
            obj.initSimulink();
        end

        function update(obj)
            obj.updateSimulink();
        end

    end


    % Simulink control
    properties(Access = private)
        slName
        slIn Simulink.SimulationInput
        sl simulink.Simulation
        stepSize double
        pilotV double
        proxV double
        dutyCycle double
        evReady logical
        batteryCurrent double
    end

    methods(Access = private)

        function initSimulink(obj)
            obj.slName = "sae_j1772";
            simIn = Simulink.SimulationInput(obj.slName);
            sm = simulation(simIn);
            % vars = sm.TunableVariables;

            if ~isdeployed()
                sm.setModelParameter(EnablePacing="on");
                sm.setModelParameter(PacingRate="2");
            end
            % sm.initialize();

            p =  keys(sm.TunableVariables);
            % 위의 keys를 먼저 실행하지 않으면, 아래의 코드 에러 발생함.
            obj.pilotV = sm.getVariable('PilotVolt').Value;
            obj.proxV = sm.getVariable('ProxVolt').Value;
            obj.dutyCycle = sm.getVariable('DutyCycle').Value;
            obj.evReady = sm.getVariable('VehOk').Value;
            obj.batteryCurrent = sm.getVariable('BattCurr').Value;

            obj.slIn = simIn;
            obj.sl = sm;
            obj.stepSize = 1;
        end

        function deleteSimulink(obj)
            obj.simulationStop();
            delete(obj.sl);
        end

        function updateSimulink(obj)

        end

        function updateSimulinkInput(obj)
            % in{1} = obj.pilotV;
            % in{2} = obj.proxV;
            % in{3} = obj.dutyCycle;
            % in{4} = obj.evReady;
            % in{5} = obj.batteryCurrent;
            % obj.slIn = obj.slIn.setExternalInput(in);
            obj.sl = obj.sl.setVariable('BattCurr',obj.batteryCurrent);
            obj.sl = obj.sl.setVariable('DutyCycle',obj.dutyCycle);
            obj.sl = obj.sl.setVariable('PilotVolt',obj.pilotV);
            obj.sl = obj.sl.setVariable('ProxVolt',obj.proxV);
            obj.sl = obj.sl.setVariable('VehOk',obj.evReady);
      end
    end


    methods(Access = public)

        % "inactive" | "initializing" | "initialized" | "paused" | "running" | "stopping" | "terminating" | "restarting"
        function simulationInitizlize(obj)
            if any(strcmp(obj.sl.Status, ["inactive"]))
                obj.sl.initialize();
                % disp("initialize");
            end
        end

        function simulationStart(obj)
            if any(strcmp(obj.sl.Status, ["inactive", "initialized"]))
                obj.sl.start();
                % disp("start");
            end
        end

        function simulationStep(obj)
            %  ["Inactive" "Initialized" "Paused"].
            if any(strcmp(obj.sl.Status, ["inactive", "initialized", "paused"]))
                obj.sl.step("NumberOfSteps", obj.stepSize);
                % disp("step");
            end
        end

        function simulationPause(obj)
            if any(strcmp(obj.sl.Status, ["running"]))
                obj.sl.pause();
                % disp("pause");
            end
        end

        function simulationResume(obj)
            if any(strcmp(obj.sl.Status, ["paused"]))
                obj.sl.resume();
                % disp("resume");
            end
        end

        function simulationStop(obj)
            if any(strcmp(obj.sl.Status, ["initialized", "running", "paused"]))
                obj.sl.stop();
                % disp("stop");
            end
        end

        function simulationTerminate(obj)
            if any(strcmp(obj.sl.Status, ["initialized" "running" "paused"]))
                obj.sl.terminate();
                % disp("terminate");
            end
        end

    end

    methods(Access = private)

        function o = getSimulationLogout(obj, index)
            arguments
                obj
                index (1,1) double
            end
            % Invalid call to SimulationOutput function for simulation status Running. To use the
            % SimulationOutput function, simulation status must be one of these: ["Initialized" "Paused"
            % "Inactive"].
            if ~any(strcmp(obj.sl.Status, ["initialized" "paused" "inactive"]))
                o = [];
                return;
            end
            lo = obj.sl.SimulationOutput.logsout;
            if ~isempty(lo) && lo.numElements >= index
                o = lo{index}.Values;
            else
                o = [];
            end
        end

    end

    methods(Access = public)

        function o = getSimulationLogoutStatus(obj)
            o = obj.getSimulationLogout(6);
        end

        function o = getSimulationLogoutHLC(obj)
            o = obj.getSimulationLogout(2);
        end

        function o = getSimulationLogoutReady(obj)
            o = obj.getSimulationLogout(3);
        end

        function o = getSimulationLogoutMaxCurrent(obj)
            o = obj.getSimulationLogout(4);
        end

        function st = getSimulationState(obj)
            st = obj.sl.Status;
        end

        function t = getSimulationTime(obj)
            t = obj.sl.Time;
        end

        function setStepSize(obj, v)
            arguments
                obj
                v (1,1) double {mustBeGreaterThan(v, 0), mustBeLessThanOrEqual(v, 100), mustBeNonNan, mustBeInteger} = 1
            end
            v = round(v);
            obj.stepSize = v;
        end

        function v = getStepSize(obj)
            v = obj.stepSize;
        end

        function setPilotV(obj, v)
            obj.pilotV = v;
            % inBlk = obj.slName + "/Constant";
            % obj.slIn = setExternalInput(obj.slIn,inBlk, v);
            % obj.slIn = setVariable(obj.slIn, inBlk, v);
            obj.updateSimulinkInput();
        end

        function v = getPilotV(obj)
            v= obj.pilotV;
        end

        function setProxV(obj, v)
            obj.proxV = v;
            obj.updateSimulinkInput();
        end

        function v = getProxV(obj)
            v= obj.proxV;
        end

        function setDutyCycle(obj, v)
            obj.dutyCycle = v;
            obj.updateSimulinkInput();
        end

        function v = getDutyCycle(obj)
            v = obj.dutyCycle;
        end

        function setEVReady(obj, v)
            if strcmp(v, 'Off')
                obj.evReady = false;
            else
                obj.evReady = true;
            end
            obj.updateSimulinkInput();
        end

        function v = getEVReady(obj)
            v = obj.evReady;
        end

        function setBatteryC(obj, v)
            obj.batteryCurrent = v;
            obj.updateSimulinkInput();
        end

        function v = getBatteryC(obj)
            v = obj.batteryCurrent;
        end

    end

end
