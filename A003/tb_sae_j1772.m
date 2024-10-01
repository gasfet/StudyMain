% function tb_sae_j1772()

    sName = "sae_j1772";
    simIn = Simulink.SimulationInput(sName);
    sm = simulation(simIn);
    sm.setModelParameter(EnablePacing="on");
    sm.setModelParameter(PacingRate="2");
    if strcmp(sm.Status, "inactive")
        sm.initialize();
    end
    for idx=1:10
        sm.step();
        % log 데이터 확인
        sm.SimulationOutput.logsout{6}.Values.Time(end)
        sm.SimulationOutput.logsout{6}.Values.Data(end)
    end
    sm.stop();
    % sm.terminate();
    clear sm  simIn
% end

H = MIMOChamber;
if isdeployed()
    T = H.app;
    if isa(T, 'MIMOChamberD') && isvalid(T)
        uiwait(T.UIFigure);
    end
    delete(H);
    clear("H");
end

% if exist('bp', 'var'), delete(bp); clear('bp');  end; bp = cSAEJ1772();
