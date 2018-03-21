IMPORT $ AS File_Management;
Task := File_Management.Task;
/**
 * The record layout for the file list.
 */
EXPORT Layout := RECORD
  /**
   * The name of fhe logical file to be managed.
   */
  STRING logicalFile;
  /**
   * The name of the Super File holding the current definition, that is,
   * the name or names of the logical files that are current.
   */
  STRING aliasCurrent;
  /**
   * The name of the Super FIle holding the previous definitions.
   */
  STRING aliasPrevious;
  /**
   * The name of the Super File holding the past previous definitions.
   */
  STRING aliasPastPrevious;
  /**
   * The name of the Super File that temporarily holds the names of the
   * files to be deleted from the past previous.
   */
  STRING aliasDeleted;
  /**
   * The directive to attempt to delete the logical files.
   */
  BOOLEAN deleteDeleted;
  /**
   * The action requested.  @see Task definition.
   */
  Task action;
END;
