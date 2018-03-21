IMPORT Std;
IMPORT Std.File AS FS;
IMPORT $ AS File_Management;

Layout := File_Management.Layout;
Task := File_Management.Task;

/**
 * Manage the promition of this collection of files.
 * @param files the list of files to promote as a group
 * @return the sequential action.
 */
EXPORT Manage(DATASET(Layout) files) := FUNCTION
  AddSet := [Task.Replace, Task.Add];
  ac := SEQUENTIAL(
     NOTHOR(APPLY(files
                  ,IF(NOT FS.SuperFileExists(aliasCurrent), FS.CreateSuperFile(aliasCurrent))
                  ,IF(NOT FS.SuperFileExists(aliasPrevious), FS.CreateSuperFile(aliasPrevious))
                  ,IF(NOT FS.SuperFileExists(aliasPastPrevious), FS.CreateSuperFile(aliasPastPrevious))
                  ,IF(NOT FS.SuperFileExists(aliasDeleted), FS.CreateSuperFile(aliasDeleted))
                  ,FS.ClearSuperFile(aliasDeleted)))
    ,IF(EXISTS(files(action=Task.Add)),
        NOTHOR(APPLY(files(action=Task.Add)
                  ,FS.AddSuperFile(aliasDeleted, aliasCurrent, 0, TRUE))))
    ,FS.StartSuperFileTransaction()
    ,NOTHOR(APPLY(files
                  ,FS.SwapSuperFile(aliasPastPrevious,aliasDeleted)
                  ,FS.SwapSuperFile(aliasPrevious, aliasPastPrevious)
                  ,FS.SwapSuperFIle(aliasCurrent, aliasPrevious)))
    ,IF(EXISTS(files(action IN AddSet)),
        NOTHOR(APPLY(files(action IN AddSet)
                  ,FS.AddSuperFile(aliasCurrent, logicalFile))))
    ,FS.FinishSuperFileTransaction()
    ,NOTHOR(APPLY(files
                  ,FS.RemoveOwnedSubFiles(aliasDeleted, deleteDeleted)
                  ,FS.ClearSuperFile(aliasDeleted)))
    ,OUTPUT(files, NAMED('File_List'))
  );
  RETURN ac;
END;
