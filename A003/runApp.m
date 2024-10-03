H = cSAEJ1772;
if isdeployed()
    T = H.app;
    if isa(T, 'sae_j1772_app2') && isvalid(T)
        uiwait(T.UIFigure);
    end
    delete(H);
    clear("H");
end

% if exist('bp', 'var'), delete(bp); clear('bp');  end; bp = cSAEJ1772();
