function out = filterOnline(d,option)
%  notch and band-pass filtering
persistent zNotch zBPF;
if isempty(zNotch)&&isempty(zBPF)
    [temp,zNotch] = filter(option.bNotch,option.aNotch, d,[],1);
    [out,zBPF] = filter(option.bBPF,option.aBPF, temp, [],1);
else
    [temp,zNotch] = filter(option.bNotch,option.aNotch, d,zNotch,1);
    [out,zBPF] = filter(option.bBPF,option.aBPF, temp, zBPF,1);
end


end