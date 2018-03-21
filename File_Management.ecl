IMPORT Std;
IMPORT Std.File AS FS;
//  Manage one of more files or keys as a group.  There are three levels kept:
//Current, Previous, and the Past Previous.  There is one additional level needed
//as a scratchpad named Deleted.
//  The attribute drops and optionally deletes the Past Previous super file entries;
//moves the Previous entries to Past PRevious; moves the Current entries to
//Previous; and creates the new Current entry from the logical file name and
//optionally the original current entries.
//  The obsolete files are deleted if directed.
//  The attribute supllies a Test function that can be run to examine how the
//attributes behave.  The test function accepts a string as the name prefix and
//a record count.  The record count can make it easier for an observer to see
//which files are in a super file by looking at the record counts alone in ECL watch.

/**
 * File Management.  Definitions for the control file, the management action, and the
 * test attribute.
 */
EXPORT File_Management := MODULE
  EXPORT Task := ENUM(UNSIGNED1, NoOp=0, Replace, Add);
  EXPORT Layout := RECORD
    STRING logicalFile;
    STRING aliasCurrent;
    STRING aliasPrevious;
    STRING aliasPastPrevious;
    STRING aliasDeleted;
    BOOLEAN deleteDeleted;
    Task action;
  END;
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
  /**
   * Test the attribute.  Manages a single collection of files.
   * @param prefix the prefix string for the file and superfile names
   * @param t the task, Add and incremental file or replace the current file
   * @param rec_count the number of records to generate in the test data as
   *        a convenience to the tester to discern the super file content by
   *        looking only at the reported record total on ECL Watch
   * @return the action
   */
  EXPORT Test(STRING prefix, Task t=Task.Replace, UNSIGNED2 rec_count=20) := FUNCTION
    Test_Layout := RECORD
      UNSIGNED4 seq;
    END;
    ds := DISTRIBUTE(DATASET(rec_count, TRANSFORM(Test_Layout, SELF.seq:=COUNTER-1)), seq);
    names := DATASET([{Prefix+WORKUNIT, Prefix+'CURRENT', Prefix+'LAST', Prefix+'PREV',
                       Prefix+'DELETED', TRUE, t}], Layout);
    test_action := SEQUENTIAL(OUTPUT(ds,,prefix+WORKUNIT), Manage(names));
    RETURN test_action;
  END;
END;