IMPORT $ AS FIle_Management;

Task := File_Management.Task;
Layout := File_Management.Layout;
Manage := File_Management.Manage;

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
