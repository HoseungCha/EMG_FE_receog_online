% window extraction
function [windowDB,idx_trg_as_window] =  getWindows(filteredDB,nWinSize,nWinInc)
nWindows = floor((length(filteredDB) - nWinSize)/nWinInc)+1;
windowDB = cell(nWindows,1); idx_trg_as_window = zeros(nWindows,1);
st = 1;
en = nWinSize;
for i = 1: nWindows
    idx_trg_as_window(i) = en;
    curr_win = filteredDB(st:en,:);
    windowDB{i} = curr_win;
        
    % moving widnow
    st = st + nWinInc;
    en = en + nWinInc;                 
end

end