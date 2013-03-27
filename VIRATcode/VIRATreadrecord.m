function rec = VIRATreadrecord(path)

if length(path)<4
    error('unable to determine format: %s',path);
end

if strcmp(path(end-3:end),'.txt')
    rec=VIRATreadannotation(path);
else
    rec=VOCreadrecxml(path);
end
