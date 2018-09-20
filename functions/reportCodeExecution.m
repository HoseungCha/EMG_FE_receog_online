function out = reportCodeExecution(pathSaveDB)
if nargin<1
    idSaveBackup = false;
else
    idSaveBackup = true;
end
% Demonstration information
[out.FilePath,out.FileName,out.Ext]  = fileparts(matlab.desktop.editor.getActiveFilename);
out.ExecuteTime = datetime('now','format','yy-MM-dd_hhmm');
out.Author = 'Hoseung Cha';
out.AuthorContact = 'hoseungcha@gmail.com';
out.CodeSummary =  help(out.FileName);
out.newbackup=sprintf('%sBackup_%s.m',out.FileName,out.ExecuteTime);
out.currentfile =  strcat(out.FileName,out.Ext);
if idSaveBackup
    copyfile(out.currentfile,fullfile(pathSaveDB,out.newbackup));
end

end